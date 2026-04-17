---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-legacy-archive-normalization-v1 bootstrap artifact slice
product_rationale: This slice should advance task dd-hermes-legacy-archive-normalization-v1 in a way a DD Hermes maintainer can explain and verify.
goal_drift_risk: The slice could drift into generic control-plane churn if it stops serving the declared product goal.
user_visible_outcome: A maintainer can point to one concrete outcome instead of scattered partial work.
files:
  - workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/proposals/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/state/dd-hermes-legacy-archive-normalization-v1/state.json
decisions:
  - Follow the sprint contract and spec-first rule.
  - Prefer repo templates and existing scripts over ad-hoc scaffolding.
risks:
  - Do not change policy through memory writes.
  - Only write execution evidence back to commander-side state.
next_checks:
  - Run verification before completion.
  - Write back expert handoff and verification evidence.
---

# Lead Handoff

## Context

Expert expert-a owns the bootstrap execution slice for sprint dd-hermes-legacy-archive-normalization-v1 inside an isolated worktree.

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

- Keep the sprint bootstrap artifacts task-bound, template-aligned, and ready for execution handoff.

## Product Check

- Confirm the slice still serves the stated product goal and does not expand into the declared non-goals.

## Verification

- State commands and evidence expected from expert before handoff return.
- At minimum, include the workflow test result and the changed file list.

## Open Questions

- Final implementation files depend on the assigned execution slice and will be reported back by the expert.
