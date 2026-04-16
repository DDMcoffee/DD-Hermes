---
status: design
owner: lead
scope: dd-hermes-independent-quality-seat-v1
decision_log:
  - First execution slice stays inside shared governance scripts and tests.
  - The maintainer-facing truth must collapse to one semantic pair: `independent` or `degraded`.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1
  - ./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1
links:
  - workspace/contracts/dd-hermes-independent-quality-seat-v1.md
  - openspec/proposals/dd-hermes-independent-quality-seat-v1.md
  - workspace/decisions/independent-quality-seat-routing/synthesis.md
---

# Design

## Summary

Introduce one shared `quality seat` analysis across DD Hermes control-plane surfaces so maintainers can read the current seat as `independent` or `degraded`, while gates keep blocking unsafe execution and completion paths.

## Interfaces

- `scripts/team_governance.py`
  - Add `quality_seat_analysis(role_integrity, quality_anchor, degraded_ack, quality_review)`
- `scripts/state-read.sh`
  - Expose `summary.quality_seat_mode`, `summary.quality_seat_status`, `summary.quality_seat_reasons`
- `scripts/context-build.sh`
  - Expose the same `context_summary.quality_seat_*` fields
- `scripts/dispatch-create.sh`
  - Expose `quality_seat_*` at top level and in `summary`
- `hooks/thread-switch-gate.sh`
  - Use `quality seat not ready (...)` as the unified blocked reason for execution entry
- `hooks/quality-gate.sh`
  - Expose `quality_seat_*` in completion checks
- `scripts/demo-entry.sh`
  - Print one human-readable `Quality Seat` line

## Data Flow

1. `state-read` derives `role_integrity`, `quality_anchor`, `quality_review`, and `degraded_ack`.
2. `quality_seat_analysis` collapses them into:
   - `mode`: `independent`, `degraded`, or `unknown`
   - `execution_status`: `ready` or `blocked`
   - `completion_status`: `ready` or `blocked`
3. `context-build`, `dispatch-create`, and gates reuse the same derived truth.
4. `demo-entry` renders the derived truth directly instead of forcing maintainers to infer it from raw booleans.

## Edge Cases

- `independent_skeptic=false` with explicit ack:
  - `mode=degraded`, `execution_status=ready`
- `independent_skeptic=false` without explicit ack:
  - `mode=degraded`, `execution_status=blocked`
- no quality seat can be derived:
  - `mode=unknown`, `execution_status=blocked`
- completion may still be blocked when execution is ready if quality review is missing

## Acceptance

- `state / context / dispatch / gates / demo-entry` all expose a consistent `quality seat` truth.
- At least one blocked path and one passing path are proven in smoke coverage.
- No new runtime, provider, gateway, scheduler, or thread model is introduced.

## Verification

- `bash tests/smoke.sh all`
- `./scripts/state-read.sh --task-id dd-hermes-independent-quality-seat-v1`
- `./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander`
- `./scripts/demo-entry.sh`
