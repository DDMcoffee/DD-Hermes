---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-quality-seat-escalation-rules-v1 first execution slice for task-class escalation rules
product_rationale: This slice should tell a DD Hermes maintainer when degraded supervision is acceptable and when an independent quality seat is mandatory.
goal_drift_risk: The slice could drift into generic governance theory if it stops reducing ambiguity for real DD Hermes task classes.
user_visible_outcome: A maintainer can see not only the current seat truth, but also the task class, the required quality-seat policy, and whether degraded supervision is allowed.
files:
  - workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md
  - openspec/proposals/dd-hermes-quality-seat-escalation-rules-v1.md
  - openspec/designs/dd-hermes-quality-seat-escalation-rules-v1.md
  - openspec/tasks/dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/state/dd-hermes-quality-seat-escalation-rules-v1/state.json
  - workspace/decisions/quality-seat-escalation-routing/synthesis.md
decisions:
  - Archive the previous proof task instead of adding another slice to it.
  - Keep the new mainline at the task-class escalation layer before any broader governance changes.
  - Freeze the initial matrix as `T0/T1/T2 => degraded-allowed` and `T3/T4 => requires-independent`.
  - Reuse the existing quality-seat truth already exposed across state/context/dispatch/gates.
risks:
  - Do not change policy through memory writes.
  - Do not reopen `dd-hermes-independent-quality-seat-v1` with new implementation work.
  - Do not expand into runtime/provider/scheduler or generic documentation churn.
next_checks:
  - Run workflow/context/dispatch/gate verification for the execution slice.
  - Prove one degraded-allowed path and one requires-independent blocked path before handing back to lead.
---

# Lead Handoff

## Context

Expert expert-a owns the first execution slice that turns the agreed T0-T4 matrix into observable control-plane truth.

## Required Fields

- `from`
- `to`
- `scope`
- `product_rationale`
- `goal_drift_risk`
- `user_visible_outcome`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Keep the slice task-bound, product-explicit, and prove the matrix through real gate behavior.

## Product Check

- Confirm the slice keeps the next boundary inside shared governance scripts, docs, and tests, and that the current task itself stays `T3`.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`

## Open Questions

- Which concrete `T2` scenarios should later be promoted to explicit `requires-independent` overrides?
