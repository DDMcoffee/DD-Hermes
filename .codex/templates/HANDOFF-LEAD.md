---
schema_version: 2
from: lead
to: expert-a
scope: subsystem-or-slice
product_rationale: Explain how this slice serves the product goal.
goal_drift_risk: Describe how this slice could drift away from the product goal.
user_visible_outcome: State the expected user-visible outcome of this handoff.
files:
  - path/to/file
decisions:
  - Decision already fixed by lead.
risks:
  - Known risk.
next_checks:
  - Verification to run.
---

# Lead Handoff

## Context

Describe task intent and the non-goals for this expert.

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

- State the exact finish line for this handoff.

## Product Check

- Confirm the slice still advances the intended product goal and does not expand into non-goals.

## Verification

- State commands and evidence expected from expert.

## Open Questions

- Questions the expert may still need to resolve locally.
