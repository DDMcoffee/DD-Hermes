---
status: design
owner: lead
scope: dd-hermes-backlog-truth-hygiene-v1
decision_log:
  - Treat stale candidate truth as a bounded governance slice instead of promoting a new feature mainline.
  - Prefer archive notes and state corrections over deleting historical evidence.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1
  - ./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/proposals/dd-hermes-commander-doc-consolidation-v1.md
  - openspec/proposals/dd-hermes-s5-2expert-20260416.md
  - 指挥文档/04-任务重校准与线程策略.md
---

# Design

## Summary

Close stale candidate ambiguity by archiving one absorbed docs proposal and one paused experiment, then refresh the commander truth source so maintainers can trust the candidate pool without inventing a successor mainline.

## Interfaces

- `openspec/archive/dd-hermes-commander-doc-consolidation-v1.md`
  - New archive note marking the docs proposal as absorbed by the current `指挥文档/` surface.
- `openspec/archive/dd-hermes-s5-2expert-20260416.md`
  - New archive note marking S5 as a paused experiment with bootstrap evidence only.
- `workspace/handoffs/dd-hermes-s5-2expert-20260416-lead-to-lead-archive.md`
  - Archive checkpoint linking experiment evidence to its final frozen state.
- `workspace/state/dd-hermes-s5-2expert-20260416/state.json`
  - Update status/mode/archive fields so the experiment no longer presents itself as a live execution task.
- `指挥文档/04-任务重校准与线程策略.md`
  - Refresh the candidate-pool narrative: stale candidates were cleaned, but no new mainline was chosen.

## Data Flow

1. Read current candidate evidence from proposals, archived proof tasks, and paused experiment state.
2. Separate absorbed work from true still-open candidates.
3. Write archive notes for the absorbed docs proposal and paused experiment.
4. Refresh the paused experiment state so its runtime truth matches the archive.
5. Update task-triage docs to reflect the cleaned candidate pool while keeping `no active mainline` truth.

## Edge Cases

- `dd-hermes-s5-2expert-20260416` should not suddenly claim an execution slice; its closeouts remain placeholders and the archive must say so explicitly.
- `dd-hermes-commander-doc-consolidation-v1` has no task state; its archive must therefore describe absorption into current docs rather than a full task lifecycle.
- Cleaning the candidate pool must not change `latest_proof_task_id`; the latest phase-2 proof remains `dd-hermes-explicit-gate-verdicts-v1`.

## Acceptance

- Stale absorbed/proposal-only artifacts are no longer indistinguishable from live successor candidates.
- The paused S5 experiment no longer reads like an unfinished mainline execution task.
- Commander docs still honestly report that there is no active mainline after cleanup.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1`
- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/demo-entry.sh`
