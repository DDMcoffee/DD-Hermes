---
status: archived
owner: lead
scope: dd-hermes-backlog-truth-hygiene-v1
decision_log:
  - Treat stale candidate truth as a bounded governance task instead of promoting a new feature mainline.
  - Archive absorbed docs work and the paused two-expert experiment, then return the repo to an honest `no active mainline` state.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1
  - ./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416
  - ./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-backlog-truth-hygiene-v1.md
  - workspace/handoffs/dd-hermes-backlog-truth-hygiene-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-backlog-truth-hygiene-v1-lead-to-lead-archive.md
  - workspace/exploration/exploration-lead-dd-hermes-backlog-truth-hygiene-v1.md
  - workspace/state/dd-hermes-backlog-truth-hygiene-v1/state.json
  - openspec/archive/dd-hermes-commander-doc-consolidation-v1.md
  - openspec/archive/dd-hermes-s5-2expert-20260416.md
  - workspace/handoffs/dd-hermes-s5-2expert-20260416-lead-to-lead-archive.md
  - 指挥文档/04-任务重校准与线程策略.md
---

# Archive

## Result

`dd-hermes-backlog-truth-hygiene-v1` closes a bounded governance slice: the repo candidate pool no longer confuses maintainers with an absorbed docs proposal or a paused experiment that still looks like live execution.

## Deviations

- This task does not choose a new phase-2 feature mainline.
- The latest phase-2 proof task remains `dd-hermes-explicit-gate-verdicts-v1`; this archive only cleans backlog truth around candidate selection.

## Risks

- Cleaning stale candidate truth does not itself answer what the next real successor mainline should be.
- Future candidate drift should happen under a new task id, not by reopening this governance cleanup.

## Acceptance

- Absorbed docs work is archived as absorbed, not left as a live proposal.
- The paused two-expert experiment is archived as bootstrap/dispatch evidence, not left as a fake active execution task.
- Commander triage still honestly says there is no active mainline.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1`
- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/demo-entry.sh`
