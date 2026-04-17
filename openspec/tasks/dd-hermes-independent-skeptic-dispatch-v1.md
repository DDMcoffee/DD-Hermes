---
status: active
owner: lead
scope: dd-hermes-independent-skeptic-dispatch-v1
decision_log: []
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-independent-skeptic-dispatch-v1
  - ./scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-skeptic-dispatch-v1
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-independent-skeptic-dispatch-v1.md
  - workspace/decisions/independent-skeptic-dispatch-routing/synthesis.md
---

# Task

## Steps

1. Freeze successor triage and point commander truth sources to this new mainline.
2. Define the real lane as a paired skeptic worktree plus skeptic-specific handoff/context/runtime packet.
3. Materialize that lane through dispatch/context/handoff/worktree surfaces without changing the user-facing single-thread model.
4. Keep degraded fallback explicit for tasks that still do not have a separate skeptic seat.
5. Prove the new lane with bounded verification and smoke coverage.

## Dependencies

- `workspace/decisions/successor-triage-routing/synthesis.md`
- `openspec/archive/dd-hermes-independent-quality-seat-v1.md`
- `openspec/archive/dd-hermes-quality-seat-escalation-rules-v1.md`
- `openspec/archive/dd-hermes-explicit-gate-verdicts-v1.md`

## Done Definition

DD Hermes can point to a real independent skeptic lane, not only a role-integrity boolean.

## Acceptance

- The slice stays about independent skeptic dispatch/review-lane materialization, not generic role theory.
- The new lane remains internal to DD Hermes and does not require user-managed external chat threads.
- Archived policy and verdict proofs remain archived.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`
- `./scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`
- `./scripts/demo-entry.sh`
