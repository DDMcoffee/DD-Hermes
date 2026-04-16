#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
decision_id=""
policy="3-explorer-then-execute"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --decision-id) decision_id="$2"; shift 2 ;;
    --policy) policy="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" || -z "$decision_id" ]]; then
  json_out '{"error":"task_id and decision_id are required"}'
  exit 3
fi

repo=$(repo_root)
decision_dir="$repo/workspace/decisions/$decision_id"
mkdir -p "$decision_dir"
for role in architecture delivery curriculum; do
  target="$decision_dir/$role.md"
  if [[ ! -f "$target" ]]; then
    cp "$repo/.codex/templates/DECISION-EXPLORER.md" "$target"
    update_frontmatter_field "$target" "decision_id" "$decision_id"
    update_frontmatter_field "$target" "task_id" "$task_id"
    update_frontmatter_field "$target" "role" "$role"
  fi
done

synthesis="$decision_dir/synthesis.md"
if [[ ! -f "$synthesis" ]]; then
  cp "$repo/.codex/templates/DECISION-SYNTHESIS.md" "$synthesis"
  update_frontmatter_field "$synthesis" "decision_id" "$decision_id"
  update_frontmatter_field "$synthesis" "task_id" "$task_id"
fi

if [[ -f "$repo/workspace/state/$task_id/state.json" ]]; then
  printf '%s' "$(python3 - <<'PY' "$policy" "$decision_id" "$decision_dir" "$synthesis"
import json
import sys

policy, decision_id, decision_dir, synthesis = sys.argv[1:]
print(json.dumps({
    "discussion_policy": policy,
    "decision_id": decision_id,
    "explorer_queue": ["architecture", "delivery", "curriculum"],
    "explorer_findings": [
        f"{decision_dir}/architecture.md",
        f"{decision_dir}/delivery.md",
        f"{decision_dir}/curriculum.md",
    ],
    "synthesis_path": synthesis,
}, ensure_ascii=False))
PY
)" | "$SCRIPT_DIR/state-update.sh" --task-id "$task_id" >/dev/null || true
fi

payload=$(python3 - <<'PY' "$decision_dir" "$synthesis"
import json
import sys

decision_dir, synthesis = sys.argv[1:]
print(json.dumps({
    "decision_dir": decision_dir,
    "explorer_paths": [
        f"{decision_dir}/architecture.md",
        f"{decision_dir}/delivery.md",
        f"{decision_dir}/curriculum.md",
    ],
    "synthesis_path": synthesis,
}, ensure_ascii=False))
PY
)
json_out "$payload"
