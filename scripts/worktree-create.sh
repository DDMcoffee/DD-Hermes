#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
branch=""
base="HEAD"
expert=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --branch) branch="$2"; shift 2 ;;
    --base) base="$2"; shift 2 ;;
    --expert) expert="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" || -z "$expert" ]]; then
  json_out '{"error":"task_id and expert are required"}'
  exit 3
fi

repo=$(shared_repo_root)
if ! git -C "$repo" rev-parse --verify HEAD >/dev/null 2>&1; then
  json_out '{"error":"repository needs at least one commit before git worktree can be created","blocked":true}'
  exit 2
fi

mkdir -p "$repo/.worktrees"
branch=${branch:-"$task_id-$expert"}
worktree_path="$repo/.worktrees/$task_id-$expert"
if [[ -e "$worktree_path" ]]; then
  json_out "{\"error\":\"worktree path already exists\",\"worktree_path\":\"$worktree_path\"}"
  exit 2
fi
git -C "$repo" worktree add --quiet -b "$branch" "$worktree_path" "$base" >/dev/null

payload=$(python3 - <<'PY' "$worktree_path" "$branch" "$base"
import json
import sys

worktree_path, branch, base = sys.argv[1:]
print(json.dumps({
    "worktree_path": worktree_path,
    "branch": branch,
    "checkout_ref": base,
    "next_commands": [
        f"cd {worktree_path}",
        "git status --short",
    ],
}, ensure_ascii=False))
PY
)
json_out "$payload"
