#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
expert=""
worktree=""
delete_branch="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --expert) expert="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --delete-branch) delete_branch="true"; shift ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
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

branch=$(git -C "$worktree" branch --show-current 2>/dev/null || true)
git -C "$repo" worktree remove "$worktree" >/dev/null
if [[ "$delete_branch" == "true" && -n "$branch" ]]; then
  git -C "$repo" branch -D "$branch" >/dev/null
fi

payload=$(python3 - <<'PY' "$worktree" "$branch" "$delete_branch"
import json
import sys

worktree, branch, delete_branch = sys.argv[1:]
print(json.dumps({
    "removed_worktree": worktree,
    "branch": branch,
    "deleted_branch": delete_branch == "true" and bool(branch),
}, ensure_ascii=False))
PY
)
json_out "$payload"
