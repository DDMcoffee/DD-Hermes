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
  - openspec/designs/dd-hermes-independent-quality-seat-v1.md
  - openspec/tasks/dd-hermes-independent-quality-seat-v1.md
  - workspace/state/dd-hermes-independent-quality-seat-v1/state.json
  - workspace/decisions/independent-quality-seat-routing/synthesis.md
  - scripts/team_governance.py
  - scripts/state-read.sh
  - scripts/context-build.sh
  - scripts/dispatch-create.sh
  - hooks/thread-switch-gate.sh
  - hooks/quality-gate.sh
  - scripts/demo-entry.sh
  - tests/smoke.sh
decisions:
  - Use `3-explorer-then-execute`; do not enter implementation without a real synthesis.
  - Keep the first execution slice inside shared governance scripts, schemas, and tests.
  - Use one shared `quality seat` semantic pair across state/context/dispatch/gates instead of scattered booleans.
risks:
  - Do not change policy through memory writes.
  - Do not pretend degraded supervision is independent supervision.
  - Do not expand into runtime/provider/scheduler work.
next_checks:
  - Rebuild commander context after shared-script changes.
  - Record execution evidence and closeout once the first slice is committed.
---

# Lead Handoff

## Context

Expert expert-a owns the first bounded implementation slice: expose one consistent `quality seat` truth across state, context, dispatch, gates, and demo entry without expanding the control surface.

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

- Keep the slice task-bound, and make the first implementation small enough to verify through shared scripts and tests.

## Product Check

- Confirm the slice improves maintainer-visible quality-seat truth and does not expand beyond the declared non-goals.

## Verification

- For the first execution slice, require:
  - `./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1`
  - `./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander`
  - `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1`
  - `bash tests/smoke.sh all`

## Open Questions

- Which task classes must later require an actually independent quality seat rather than an explicitly degraded fallback?
