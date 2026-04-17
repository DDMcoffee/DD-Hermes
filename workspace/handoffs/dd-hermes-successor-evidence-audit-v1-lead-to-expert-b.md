---
schema_version: 2
from: lead
to: expert-b
scope: dd-hermes-successor-evidence-audit-v1 skeptic review lane
product_rationale: Keep dd-hermes-successor-evidence-audit-v1 tied to the declared product goal while materializing a real skeptic lane.
goal_drift_risk: This slice could drift into generic orchestration cleanup if it stops improving task-bound traceability.
user_visible_outcome: A maintainer can see that skeptical review is running in its own lane with explicit artifacts.
files:
  - workspace/contracts/dd-hermes-successor-evidence-audit-v1.md
  - workspace/state/dd-hermes-successor-evidence-audit-v1/state.json
decisions:
  - Follow the existing contract, state, and gate surfaces.
  - Keep the separate lane internal to DD Hermes instead of exposing a new user-facing thread.
risks:
  - Do not overclaim independent review before its artifacts are materialized.
  - Keep degraded fallback explicit when the lane is not available.
next_checks:
  - Run context-build for this lane.
  - Verify dispatch, gate, and state surfaces expose the lane truth.
---

# Lead Handoff

## Context

This handoff materializes the `skeptic` lane for `dd-hermes-successor-evidence-audit-v1`. Reuse the existing control-plane surfaces and keep the slice bounded to traceable task artifacts.

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

- The `skeptic` lane has its own handoff, context packet, and worktree truth where applicable.

## Product Check

- Confirm the lane still serves the declared product goal and does not expand into runtime/provider redesign.

## Verification

- Include the dispatch result, the lane-specific context path, and the gate result.

## Open Questions

- None for this materialized lane.
