---
status: active
owner: lead
scope: dd-hermes-independent-quality-seat-v1
decision_log:
  - Use shared `quality seat` semantics before adding any new gate category.
checks:
  - bash tests/smoke.sh all
  - ./scripts/demo-entry.sh
links:
  - openspec/designs/dd-hermes-independent-quality-seat-v1.md
  - workspace/decisions/independent-quality-seat-routing/synthesis.md
---

# Task

## Steps

1. Add shared `quality_seat_analysis` to `scripts/team_governance.py`.
2. Expose `quality_seat_*` fields in `state-read`, `context-build`, and `dispatch-create`.
3. Surface the same truth in `thread-switch-gate`, `quality-gate`, and `demo-entry`.
4. Extend smoke coverage for independent and degraded paths.

## Dependencies

- `workspace/contracts/dd-hermes-independent-quality-seat-v1.md`
- `workspace/decisions/independent-quality-seat-routing/synthesis.md`
- shared governance surfaces from `dd-hermes-anchor-governance-v1`

## Done Definition

- Maintainers can read `Quality Seat` from any primary control-plane surface.
- Execution entry and completion outputs explain blocked degraded states with one shared reason model.
- Smoke passes with both blocked and passing seat states.

## Acceptance

- `quality_seat_mode` is consistent across state/context/dispatch.
- `quality_seat_status` is consistent across state/context/dispatch/gates.
- The first slice remains bounded to shared governance scripts, docs, and tests.

## Verification

- `bash tests/smoke.sh all`
- `./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1`
