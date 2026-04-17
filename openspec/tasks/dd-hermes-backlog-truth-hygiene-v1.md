---
status: active
owner: lead
scope: dd-hermes-backlog-truth-hygiene-v1
decision_log:
  - Clean stale candidate truth before attempting another successor selection.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1
  - ./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416
  - ./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416
  - ./scripts/demo-entry.sh
links:
  - openspec/designs/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/archive/dd-hermes-explicit-gate-verdicts-v1.md
  - openspec/proposals/dd-hermes-commander-doc-consolidation-v1.md
  - openspec/proposals/dd-hermes-s5-2expert-20260416.md
---

# Task

## Steps

1. Archive `dd-hermes-commander-doc-consolidation-v1` as absorbed docs work.
2. Archive `dd-hermes-s5-2expert-20260416` as a paused experiment and refresh its state accordingly.
3. Update candidate-pool truth in `指挥文档/04-任务重校准与线程策略.md`.
4. Verify the cleanup without changing `latest_proof_task_id` or inventing a successor mainline.

## Dependencies

- `workspace/contracts/dd-hermes-backlog-truth-hygiene-v1.md`
- `openspec/archive/dd-hermes-explicit-gate-verdicts-v1.md`
- `workspace/state/dd-hermes-s5-2expert-20260416/state.json`

## Done Definition

- A maintainer can distinguish archived absorbed work, archived experiments, and real future candidates without reading chat history.
- The repo still truthfully says there is no active mainline.

## Acceptance

- The task stays bounded to backlog/candidate truth cleanup.
- No new feature mainline is fabricated during cleanup.
- Archived evidence remains readable and linked.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1`
- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/demo-entry.sh`
