---
status: design
owner: lead
scope: dd-hermes-quality-seat-escalation-rules-v1
decision_log:
  - Keep the new mainline at the policy layer: classify task classes first, then wire only the minimum control-plane fields and gates.
  - Reuse the existing `quality seat` truth instead of inventing a second parallel model.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1
  - ./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander
links:
  - workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/decisions/quality-seat-escalation-routing/synthesis.md
  - openspec/archive/dd-hermes-independent-quality-seat-v1.md
---

# Design

## Summary

Introduce task-class-based escalation rules on top of the already-landed `quality seat` truth so DD Hermes can answer not just “is this task degraded or independent,” but also “does this task class allow degraded supervision at all.”

## Interfaces

- `workspace/contracts/<task_id>.md`
  - Carry explicit `task_class`, `quality_requirement`, and `task_class_rationale` for the new mainline and later execution slices.
- `scripts/team_governance.py`
  - Extend shared governance analysis with a T0-T4-aware escalation rule that can say `degraded-allowed` or `requires-independent`.
- `scripts/state-init.sh` / `scripts/state-update.sh`
  - Carry the minimum metadata needed to express task class and required quality-seat policy.
- `scripts/state-read.sh` / `scripts/context-build.sh` / `scripts/dispatch-create.sh`
  - Surface the new escalation truth alongside the existing `quality seat` fields.
- `hooks/thread-switch-gate.sh` / `hooks/quality-gate.sh`
  - Block when a task class requires an independent quality seat but only degraded supervision is available.

## Data Flow

1. A task declares or derives its task class.
2. Shared governance analysis maps `T0/T1/T2` to `degraded-allowed` and `T3/T4` to `requires-independent`, while still allowing bounded manual escalation from `T2`.
3. State/context/dispatch expose both the current seat truth and the required policy truth.
4. Execution and completion gates compare the two and block when the class requires independence but the task is only degraded.

## Edge Cases

- `T0/T1` stay in no-execution territory and should not force a fake independent seat.
- `T2` may remain degraded, but maintainers can explicitly escalate it to `requires-independent`.
- `T3/T4` should block if only degraded supervision is available.
- Tasks with ambiguous class should stop in planning rather than silently defaulting to degraded.

## Acceptance

- DD Hermes can express at least one task class that may stay degraded and one that must require an independent quality seat.
- The new policy reuses existing control-plane truth instead of adding a second role model.
- The first implementation boundary remains inside shared governance scripts, docs, and tests, and covers one allowed path plus one blocked path.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`
