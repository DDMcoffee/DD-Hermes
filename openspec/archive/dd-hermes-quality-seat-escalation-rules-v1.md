---
status: archived
owner: lead
scope: dd-hermes-quality-seat-escalation-rules-v1
decision_log:
  - Closed the escalation-rules mainline after landing both the initial T0-T4 matrix and the bounded `T2` manual-escalation rule set.
  - Chose to archive the task without inventing a fake successor mainline; DD Hermes should say "no active mainline" until the next task is explicitly defined.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1
  - ./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander
  - ./scripts/state-read.sh --task-id dd-hermes-quality-seat-escalation-rules-v1
  - ./scripts/dispatch-create.sh --task-id dd-hermes-quality-seat-escalation-rules-v1
  - ./hooks/thread-switch-gate.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --target execution
  - ./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-quality-seat-escalation-rules-v1/state.json
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-quality-seat-escalation-rules-v1
  - ./scripts/demo-entry.sh
  - bash tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/handoffs/dd-hermes-quality-seat-escalation-rules-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-quality-seat-escalation-rules-v1-expert-a-to-lead.md
  - workspace/handoffs/dd-hermes-quality-seat-escalation-rules-v1-lead-to-lead-archive.md
  - workspace/closeouts/dd-hermes-quality-seat-escalation-rules-v1-expert-a.md
  - workspace/state/dd-hermes-quality-seat-escalation-rules-v1/state.json
  - workspace/decisions/quality-seat-escalation-routing/synthesis.md
  - openspec/designs/dd-hermes-quality-seat-escalation-rules-v1.md
  - openspec/tasks/dd-hermes-quality-seat-escalation-rules-v1.md
  - docs/coordination-endpoints.md
  - docs/artifact-schemas.md
  - README.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Archive

## Result

`dd-hermes-quality-seat-escalation-rules-v1` now closes the first stable phase-2 escalation-rules proof for DD Hermes. The repo can explain and enforce the initial `T0/T1/T2 => degraded-allowed`, `T3/T4 => requires-independent` matrix, and it can block bounded `T2` work once `high_risk_mode`, `integration_pressure`, or repeated verification failures require an explicit upgrade.

## Deviations

- The archive freezes one bounded policy package; it does not attempt to classify every future `T2` risk pattern or reopen role-theory discussion.
- The repo now truthfully reports that there is no new active phase-2 mainline yet, instead of promoting an undecided follow-up as if it were already a task.

## Risks

- Future work must start under a new task id; reopening this archive would blur the proof boundary and make the phase-2 story dishonest again.
- If a successor task is chosen later, `指挥文档/06-一期PhaseDone审计.md` and `scripts/demo-entry.sh` must be updated together so the entry keeps matching repo truth.

## Acceptance

- DD Hermes exposes the initial task-class matrix across state, context, dispatch, thread gate, quality gate, and smoke coverage.
- The repo can prove one real `T2 degraded-allowed` path and one blocked `T2` path that only unblocks after explicit escalation to `requires-independent`.
- The archived task now has contract, proposal, design, task, decision synthesis, handoff, closeout, state, checkpoint, and archive evidence under one task id.
- The entry surface stays truthful even when no successor mainline has been decided yet.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`
- `./scripts/state-read.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/dispatch-create.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./hooks/thread-switch-gate.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --target execution`
- `./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-quality-seat-escalation-rules-v1/state.json`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/demo-entry.sh`
- `bash tests/smoke.sh all`
