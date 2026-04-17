---
status: active
owner: lead
scope: dd-hermes-independent-skeptic-dispatch-v1
decision_log:
  - Choose independent skeptic dispatch as the next mainline because quality-seat semantics, escalation policy, and verdict persistence are already archived proofs.
  - Treat the remaining gap as operational: a separate skeptic can be named in state, but DD Hermes still does not materialize a real review lane for that seat.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-independent-skeptic-dispatch-v1
  - ./scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-skeptic-dispatch-v1
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-independent-skeptic-dispatch-v1.md
  - workspace/decisions/independent-skeptic-dispatch-routing/synthesis.md
  - 指挥文档/04-任务重校准与线程策略.md
---

# Proposal

## What

Make DD Hermes dispatch an actually independent skeptic lane instead of stopping at `independent_skeptic=true` as a state-level truth claim.

## Why

Archived proofs already closed three earlier gaps:

- `dd-hermes-independent-quality-seat-v1` proved quality-seat truth.
- `dd-hermes-quality-seat-escalation-rules-v1` froze when degraded vs independent supervision is allowed.
- `dd-hermes-explicit-gate-verdicts-v1` persisted that truth into state.

The remaining maintainer-facing gap is operational. `dispatch-create` gives executors isolated worktrees, but skeptics still receive only a repo-root packet with no equivalent review lane. Multiple archived closeouts explicitly call for a real independent skeptic assignee rather than more metadata tweaks.

## Non-goals

- Redesigning runtime/provider layers.
- Reopening archived quality-seat, escalation-rule, or verdict-persistence proofs.
- Requiring the user to manage multiple visible chat threads.
- Changing the `T0/T1/T2 => degraded-allowed` and `T3/T4 => requires-independent` policy matrix.

## Acceptance

- The repo names `dd-hermes-independent-skeptic-dispatch-v1` as the current active mainline under a new task id.
- The proposal explains why operational skeptic dispatch is now the narrowest unresolved gap.
- The new mainline stays bounded to skeptic dispatch/review-lane materialization rather than reopening older governance slices.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`
- `./scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`
- `./scripts/demo-entry.sh`
