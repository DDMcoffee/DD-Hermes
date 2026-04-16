#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
worktree=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
worktree=${worktree:-"$repo"}
contract="$repo/workspace/contracts/$task_id.md"
handoff=$(find "$repo/workspace/handoffs" -maxdepth 1 -type f -name "$task_id-*.md" | head -n 1 || true)
dirty=$(git -C "$worktree" status --porcelain 2>/dev/null || true)

payload=$(python3 - <<'PY' "$dirty" "$contract" "$handoff"
import json
import sys

dirty, contract, handoff = sys.argv[1:]
files = [line[3:] for line in dirty.splitlines() if line]
print(json.dumps({
    "clean": len(files) == 0,
    "dirty_files": files,
    "linked_contract": contract if contract else "",
    "linked_handoff": handoff if handoff else "",
}, ensure_ascii=False))
PY
)
json_out "$payload"

