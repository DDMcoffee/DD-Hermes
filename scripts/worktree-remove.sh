#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
expert=""
worktree=""
delete_branch="false"
strict="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --expert) expert="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --delete-branch) delete_branch="true"; shift ;;
    --strict) strict="true"; shift ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(shared_repo_root)
if [[ -z "$worktree" ]]; then
  if [[ -z "$task_id" || -z "$expert" ]]; then
    json_out '{"error":"task_id and expert are required when worktree is omitted"}'
    exit 3
  fi
  worktree="$repo/.worktrees/$task_id-$expert"
fi

worktree=$(abs_path "$worktree")
if [[ "$worktree" == "$repo" ]]; then
  json_out '{"error":"refusing to remove primary worktree","blocked":true}'
  exit 2
fi
if [[ ! -d "$worktree" ]]; then
  json_out "{\"error\":\"worktree not found\",\"worktree\":\"$worktree\"}"
  exit 3
fi

pre_warnings=$(REPO="$repo" WORKTREE="$worktree" TASK_ID="$task_id" EXPERT="$expert" python3 - <<'PY'
import json
import os
import subprocess
from pathlib import Path

repo = Path(os.environ["REPO"])
worktree = os.environ["WORKTREE"]
task_id = os.environ.get("TASK_ID", "")
expert = os.environ.get("EXPERT", "")
warnings = []

if task_id and expert:
    handoff = repo / "workspace" / "handoffs" / f"{task_id}-{expert}-to-lead.md"
    if not handoff.exists():
        warnings.append(f"handoff missing: {handoff.name}")

if task_id:
    state_path = repo / "workspace" / "state" / task_id / "state.json"
    if state_path.exists():
        state = json.loads(state_path.read_text(encoding="utf-8"))
        v = state.get("verification", {})
        if not v.get("last_pass"):
            warnings.append("verification.last_pass is not true")
    else:
        warnings.append("state.json not found for task")

dirty = subprocess.check_output(
    ["git", "-C", worktree, "status", "--porcelain"], text=True
).strip()
if dirty:
    warnings.append(f"dirty worktree ({len(dirty.splitlines())} uncommitted files)")

print(json.dumps(warnings, ensure_ascii=False))
PY
)

if [[ "$strict" == "true" && "$pre_warnings" != "[]" ]]; then
  json_out "{\"error\":\"pre-remove validation failed\",\"warnings\":$pre_warnings,\"blocked\":true}"
  exit 2
fi

branch=$(git -C "$worktree" branch --show-current 2>/dev/null || true)
git -C "$repo" worktree remove "$worktree" >/dev/null
if [[ "$delete_branch" == "true" && -n "$branch" ]]; then
  git -C "$repo" branch -D "$branch" >/dev/null
fi

payload=$(PRE_WARNINGS="$pre_warnings" python3 - <<'PY' "$worktree" "$branch" "$delete_branch"
import json
import os
import sys

worktree, branch, delete_branch = sys.argv[1:]
print(json.dumps({
    "removed_worktree": worktree,
    "branch": branch,
    "deleted_branch": delete_branch == "true" and bool(branch),
    "pre_remove_warnings": json.loads(os.environ.get("PRE_WARNINGS", "[]")),
}, ensure_ascii=False))
PY
)
json_out "$payload"
