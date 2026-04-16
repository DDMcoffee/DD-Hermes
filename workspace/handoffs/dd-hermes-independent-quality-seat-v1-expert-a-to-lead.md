---
schema_version: 2
from: expert-a
to: lead
scope: dd-hermes-independent-quality-seat-v1 first quality-seat execution slice
product_rationale: This slice turns quality-seat semantics into maintainer-visible truth so DD Hermes can stop conflating degraded supervision with independent review.
goal_drift_risk: The task could drift into abstract role theory or generic doc cleanup if it stops improving control-plane truth and execution evidence.
user_visible_outcome: A maintainer can now see `Quality Seat: degraded (ready)` only after degraded acknowledgement and quality review are both explicit.
files:
  - scripts/team_governance.py
  - scripts/state-read.sh
  - scripts/context-build.sh
  - scripts/dispatch-create.sh
  - hooks/thread-switch-gate.sh
  - hooks/quality-gate.sh
  - scripts/demo-entry.sh
  - tests/smoke.sh
  - docs/coordination-endpoints.md
  - docs/artifact-schemas.md
  - openspec/designs/dd-hermes-independent-quality-seat-v1.md
  - openspec/tasks/dd-hermes-independent-quality-seat-v1.md
  - workspace/closeouts/dd-hermes-independent-quality-seat-v1-expert-a.md
decisions:
  - Keep the first execution slice inside shared governance scripts and tests instead of adding any new runtime or scheduler surface.
  - Represent the seat with one shared semantic pair: `quality_seat_mode` plus `quality_seat_status`.
  - Accept the slice under explicit degraded acknowledgement because an independent skeptic is still unavailable for this task.
risks:
  - The task is still degraded, not independent; later work must decide whether that is acceptable per task class.
  - This handoff returns execution evidence, not an archive or next-mainline decision.
next_checks:
  - Lead should rerun semantic closeout checks after this handoff and decide whether to archive or continue the task with a narrower follow-up slice.
  - If the task stays open, lead should define the next boundary explicitly instead of letting the mainline drift.
---

# Expert Handoff

## Context

This handoff returns the first real execution slice for `dd-hermes-independent-quality-seat-v1`. The shared governance surfaces already landed on `main`; this handoff and closeout freeze the slice as review-backed evidence rather than leaving it in a “code landed, closeout pending” state.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- `state-read`, `context-build`, `dispatch-create`, and both gates expose the same quality-seat truth.
- `demo-entry.sh` only reports the degraded seat as ready after degraded acknowledgement and quality review exist in state.
- Execution evidence is no longer placeholder-only.

## Product Check

- The slice improves maintainer-visible quality-seat truth without adding any new runtime, provider, gateway, or thread-orchestration surface.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1` -> pass
- `./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander` -> pass
- `./scripts/state-read.sh --task-id dd-hermes-independent-quality-seat-v1` -> pass
- `./scripts/dispatch-create.sh --task-id dd-hermes-independent-quality-seat-v1` -> pass
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1` -> pass (`semantic_valid=true`, `ready_for_execution_slice_done=true`)
- `./hooks/thread-switch-gate.sh --task-id dd-hermes-independent-quality-seat-v1 --target execution` -> pass
- `./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-independent-quality-seat-v1/state.json` -> pass
- `./scripts/demo-entry.sh` -> pass
- `bash tests/smoke.sh all` -> pass
- execution commit: `bfe1739f92ff2ef1ff30b1c0d16547b1e4c43cd6` (`feat(dd-hermes): expose quality seat semantics`)

## Open Questions

- Should lead archive this slice as the first closed phase-2 proof, or keep the task open and use the next slice to classify when degraded supervision must be upgraded to an actually independent quality seat?
