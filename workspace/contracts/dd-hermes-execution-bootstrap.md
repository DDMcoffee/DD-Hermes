---
task_id: dd-hermes-execution-bootstrap
owner: lead
experts:
  - expert-a
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing repo facts or missing verification.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-execution-bootstrap.md
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

- Run `scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap`
