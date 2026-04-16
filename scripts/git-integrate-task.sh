#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
expert=""
worktree=""
message=""
delete_branch="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --expert) expert="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --message) message="$2"; shift 2 ;;
    --delete-branch) delete_branch="true"; shift ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
if [[ -z "$worktree" ]]; then
  if [[ -z "$expert" ]]; then
    json_out '{"error":"expert is required when worktree is omitted"}'
    exit 3
  fi
  worktree="$repo/.worktrees/$task_id-$expert"
fi
worktree=$(abs_path "$worktree")

if [[ "$worktree" == "$(abs_path "$repo")" ]]; then
  json_out '{"error":"cannot integrate primary worktree into itself","blocked":true}'
  exit 2
fi
if [[ ! -d "$worktree" ]]; then
  json_out "{\"error\":\"worktree not found\",\"worktree\":\"$worktree\"}"
  exit 3
fi

branch=$(git -C "$worktree" branch --show-current 2>/dev/null || true)
if [[ -z "$branch" ]]; then
  json_out '{"error":"worktree has no branch","blocked":true}'
  exit 2
fi

payload=$(REPO="$repo" WORKTREE="$worktree" BRANCH="$branch" TASK_ID="$task_id" EXPERT="${expert:-unknown}" python3 - <<'PY'
import json
import os
import subprocess
from pathlib import Path

repo = os.environ["REPO"]
worktree = os.environ["WORKTREE"]
branch = os.environ["BRANCH"]
task_id = os.environ["TASK_ID"]
expert = os.environ["EXPERT"]

handoff_path = Path(repo) / "workspace" / "handoffs" / f"{task_id}-{expert}-to-lead.md"
state_path = Path(repo) / "workspace" / "state" / task_id / "state.json"

warnings = []
if not handoff_path.exists():
    alt = list((Path(repo) / "workspace" / "handoffs").glob(f"{task_id}*to-lead*"))
    if not alt:
        warnings.append(f"handoff not found: {handoff_path.name}")

if state_path.exists():
    state = json.loads(state_path.read_text(encoding="utf-8"))
    verification = state.get("verification", {})
    if not verification.get("last_pass"):
        warnings.append("state.verification.last_pass is not true")
    if not verification.get("verified_steps"):
        warnings.append("state.verification.verified_steps is empty")
else:
    warnings.append("state.json not found")

dirty = subprocess.check_output(
    ["git", "-C", worktree, "status", "--porcelain"], text=True
).strip()
if dirty:
    warnings.append(f"worktree has uncommitted changes ({len(dirty.splitlines())} files)")

print(json.dumps({
    "branch": branch,
    "warnings": warnings,
    "handoff_found": not any("handoff not found" in w for w in warnings),
    "verification_pass": not any("last_pass" in w for w in warnings),
    "clean": not dirty,
}, ensure_ascii=False))
PY
)

pre_check_ok=$(PAYLOAD="$payload" python3 -c 'import json,os; print("1" if json.loads(os.environ["PAYLOAD"])["warnings"] == [] else "0")')
if [[ "$pre_check_ok" == "0" ]]; then
  warnings_text=$(PAYLOAD="$payload" python3 -c 'import json,os; [print(f"  ⚠ {w}") for w in json.loads(os.environ["PAYLOAD"])["warnings"]]')
  echo "$warnings_text" >&2
fi

message=${message:-"integrate($task_id): merge $branch into main"}
git -C "$repo" merge --no-ff "$branch" -m "$message" >/dev/null 2>&1

snapshot=$("$SCRIPT_DIR/git-snapshot.sh" --worktree "$repo")

if [[ -f "$repo/workspace/state/$task_id/state.json" ]]; then
  state_update=$(SNAPSHOT="$snapshot" python3 - <<'PY'
import json
import os

snap = json.loads(os.environ["SNAPSHOT"])
print(json.dumps({
    "commit_sha": snap["head"],
    "commit_branch": snap["branch"],
    "commit_upstream": snap["upstream"],
    "commit_remote_urls": snap["remote_urls"],
    "note": "integration commit merged",
}, ensure_ascii=False))
PY
)
  printf '%s' "$state_update" | "$SCRIPT_DIR/state-update.sh" --task-id "$task_id" >/dev/null || true
fi

result=$(SNAPSHOT="$snapshot" PRE="$payload" python3 - <<'PY' "$task_id" "$branch" "$message" "$delete_branch"
import json
import os
import sys

task_id, branch, message, delete_branch = sys.argv[1:]
snap = json.loads(os.environ["SNAPSHOT"])
pre = json.loads(os.environ["PRE"])
print(json.dumps({
    "task_id": task_id,
    "integrated_branch": branch,
    "commit_sha": snap["head"],
    "message": message,
    "pre_check_warnings": pre["warnings"],
    "handoff_found": pre["handoff_found"],
    "verification_pass": pre["verification_pass"],
    "worktree_clean": pre["clean"],
    "branch_deleted": False,
}, ensure_ascii=False))
PY
)

if [[ "$delete_branch" == "true" ]]; then
  git -C "$repo" branch -D "$branch" >/dev/null 2>&1 || true
  result=$(RESULT="$result" python3 - <<'PY'
import json, os
r = json.loads(os.environ["RESULT"])
r["branch_deleted"] = True
print(json.dumps(r, ensure_ascii=False))
PY
)
fi

json_out "$result"
