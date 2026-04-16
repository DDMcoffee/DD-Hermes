---
decision_id: independent-quality-seat-routing
task_id: dd-hermes-independent-quality-seat-v1
role: architecture
status: reviewed
---

# Explorer Finding

## Goal

Decide where an independent quality seat should live in DD Hermes without inventing a new runtime or provider layer.

## Findings

- `dd-hermes-independent-quality-seat-v1` is still a planning task with `independent_skeptic=false`, `degraded=true`, and no degraded acknowledgement recorded yet.
- The repo already has the control-plane surfaces required for this slice: `state-*`, `context-build`, `dispatch-create`, `thread-switch-gate`, `quality-gate`, `check-artifact-schemas`, closeout, and archive records.
- The real architectural gap is not missing runtime machinery; it is missing enforcement and visibility around quality-seat truth.

## Recommended Path

- Put the independent quality seat in the control plane, not in a new runtime/provider layer.
- Land the truth in `workspace/state/.../state.json`, emit it through `state-read` and `context-build`, materialize it through `dispatch-create`, and enforce it through `thread-switch-gate`, `quality-gate`, and artifact schema checks.
- Keep degraded fallback explicit and auditable rather than pretending an independent seat exists by default.

## Rejected Paths

- Reject a new manager-agent runtime, scheduler, provider, or gateway surface for this slice.
- Reject solutions that add metadata but do not change dispatch or gate behavior.

## Risks

- The task could degrade into “more fields and more docs” without stronger enforcement.
- The design could accidentally normalize lead-overlap as the permanent architecture instead of a truthful fallback.
- Scope could drift into runtime/service work that the repo does not need.

## Evidence

- `workspace/state/dd-hermes-independent-quality-seat-v1/state.json`
- `openspec/archive/dd-hermes-anchor-governance-v1.md`
- `scripts/state-read.sh`
- `scripts/context-build.sh`
- `scripts/dispatch-create.sh`
- `hooks/thread-switch-gate.sh`
- `hooks/quality-gate.sh`
