#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
expert=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --expert) expert="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" || -z "$expert" ]]; then
  json_out '{"error":"task_id and expert are required"}'
  exit 3
fi

repo=$(repo_root)
context_path="$repo/workspace/state/$task_id/context.json"
handoff_path="$repo/workspace/handoffs/$task_id-lead-to-$expert.md"
worktree_path="$repo/.worktrees/$task_id-$expert"
payload=$(python3 - <<'PY' "$task_id" "$expert" "$context_path" "$handoff_path" "$worktree_path"
import json
import sys

task_id, expert, context_path, handoff_path, worktree_path = sys.argv[1:]
prompt = "\n".join([
    f"Task ID: {task_id}",
    f"Role: execution thread for {expert}",
    f"Worktree: {worktree_path}",
    f"Context packet: {context_path}",
    f"Handoff: {handoff_path}",
    "",
    "Instructions:",
    "- Read the context packet and handoff first.",
    "- Work only inside the assigned worktree.",
    "- Do not change policy or commander-side files unless explicitly required by the handoff.",
    "- After coding, write back verification evidence and handoff updates.",
])
print(json.dumps({
    "task_id": task_id,
    "expert": expert,
    "worktree_path": worktree_path,
    "context_path": context_path,
    "handoff_path": handoff_path,
    "prompt": prompt,
}, ensure_ascii=False))
PY
)
json_out "$payload"
