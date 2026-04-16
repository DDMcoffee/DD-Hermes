#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
owner="lead"
experts=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --owner) owner="$2"; shift 2 ;;
    --experts) experts="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" || -z "$experts" ]]; then
  json_out '{"error":"task_id and experts are required"}'
  exit 3
fi

repo=$(repo_root)
mkdir -p "$repo/workspace/contracts" "$repo/workspace/handoffs" "$repo/workspace/exploration" "$repo/workspace/state" "$repo/openspec/proposals" "$repo/openspec/designs" "$repo/openspec/tasks" "$repo/openspec/archive"
contract_path="$repo/workspace/contracts/$task_id.md"
exploration_path="$repo/workspace/exploration/exploration-lead-$task_id.md"
proposal_path="$repo/openspec/proposals/$task_id.md"

IFS=',' read -r -a expert_list <<< "$experts"

cat > "$contract_path" <<EOF
---
task_id: $task_id
owner: $owner
experts:
$(for expert in "${expert_list[@]}"; do printf "  - %s\n" "$expert"; done)
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing repo facts or missing verification.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/$task_id.md
---

# Sprint Contract

## Context

Initialize the sprint and bind all collaboration artifacts.

## Scope

- In scope: contract, handoffs, exploration log, openspec proposal.
- Out of scope: implementation details outside this sprint.

## Acceptance

- All artifacts exist and are linked by task id.

## Verification

- Run \`scripts/test-workflow.sh --task-id $task_id\`
EOF

handoff_paths=()
for expert in "${expert_list[@]}"; do
  handoff_path="$repo/workspace/handoffs/$task_id-lead-to-$expert.md"
  handoff_paths+=("$handoff_path")
  cat > "$handoff_path" <<EOF
---
from: $owner
to: $expert
scope: $task_id
files:
  - TBD
decisions:
  - Follow the sprint contract and spec-first rule.
risks:
  - Do not change policy through memory writes.
next_checks:
  - Run verification before completion.
---

# Lead Handoff

## Context

Expert $expert owns a bounded slice under sprint $task_id.
EOF
done

cat > "$exploration_path" <<EOF
# Exploration Log

## Context

- Task: $task_id
- Role: $owner
- Status: IN_PROGRESS

## Facts

- Sprint initialized.
EOF

cat > "$proposal_path" <<EOF
---
status: proposed
owner: $owner
scope: $task_id
decision_log: []
checks: []
links: []
---

# Proposal

## What

Initialize sprint $task_id.

## Why

Create the minimum coordination artifacts before implementation.

## Non-goals

- Runtime implementation details outside the sprint bootstrap.

## Acceptance

- Contract, handoffs, exploration log, and proposal all exist.

## Verification

- Run scripts/test-workflow.sh.
EOF

handoff_json=$(python3 - "${handoff_paths[@]}" <<'PY'
import json
import sys

print(json.dumps(sys.argv[1:], ensure_ascii=False))
PY
)
state_json=$("$SCRIPT_DIR/state-init.sh" --task-id "$task_id" --owner "$owner" --experts "$experts")
payload=$(python3 - <<'PY' "$contract_path" "$exploration_path" "$proposal_path" "$handoff_json" "$state_json"
import json
import sys

contract_path, exploration_path, proposal_path, handoff_json, state_json = sys.argv[1:]
print(json.dumps({
    "contract_path": contract_path,
    "handoff_paths": json.loads(handoff_json),
    "exploration_path": exploration_path,
    "openspec_path": proposal_path,
    "state_path": json.loads(state_json)["state_path"],
}, ensure_ascii=False))
PY
)
json_out "$payload"
