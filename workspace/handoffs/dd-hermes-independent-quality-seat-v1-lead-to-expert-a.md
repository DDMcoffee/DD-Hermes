---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-independent-quality-seat-v1 planning and first-slice boundary definition
product_rationale: This slice should advance task dd-hermes-independent-quality-seat-v1 in a way a DD Hermes maintainer can explain and verify.
goal_drift_risk: The slice could drift into generic governance churn or role-theory prose if it stops improving maintainer-visible quality-seat truth.
user_visible_outcome: A maintainer can quickly tell whether a task has an independent quality seat or an explicit degraded fallback.
files:
  - workspace/contracts/dd-hermes-independent-quality-seat-v1.md
  - openspec/proposals/dd-hermes-independent-quality-seat-v1.md
  - workspace/state/dd-hermes-independent-quality-seat-v1/state.json
  - workspace/decisions/independent-quality-seat-routing/synthesis.md
decisions:
  - Use `3-explorer-then-execute`; do not enter implementation without a real synthesis.
  - Keep the first execution slice inside shared governance scripts, schemas, and tests.
risks:
  - Do not change policy through memory writes.
  - Do not pretend degraded supervision is independent supervision.
  - Do not expand into runtime/provider/scheduler work.
next_checks:
  - Refresh decision synthesis before any implementation handoff.
  - Build commander context and verify planning artifacts before opening an execution slice.
---

# Lead Handoff

## Context

Expert expert-a is reserved for the first implementation slice after planning is signed off; this handoff defines the boundary in advance so the task does not sprawl.

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

- Keep the planning package task-bound, and make the first implementation slice small enough to verify through shared scripts and tests.

## Product Check

- Confirm the slice improves maintainer-visible quality-seat truth and does not expand beyond the declared non-goals.

## Verification

- Before execution starts, require:
  - `./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1`
  - `./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander`
  - `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1`

## Open Questions

- Which concrete gate or summary surface should become the first implementation slice: dispatch output, state/context summary, or gate enforcement text?
