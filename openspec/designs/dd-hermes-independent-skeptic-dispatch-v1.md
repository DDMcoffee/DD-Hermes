---
status: design
owner: lead
scope: dd-hermes-independent-skeptic-dispatch-v1
decision_log: []
checks:
  - ./scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander
  - ./scripts/demo-entry.sh
links:
  - workspace/contracts/dd-hermes-independent-skeptic-dispatch-v1.md
  - workspace/decisions/independent-skeptic-dispatch-routing/synthesis.md
---

# Design

## Summary

DD Hermes already exposes whether the quality seat is degraded or independent. This task adds the missing operational layer: when the skeptic seat is truly independent, dispatch should materialize a real skeptic review lane instead of only a name in state.

## Interfaces

- `scripts/dispatch-create.sh`
- `scripts/context-build.sh`
- `scripts/state-read.sh`
- `hooks/thread-switch-gate.sh`
- `hooks/quality-gate.sh`
- `docs/coordination-endpoints.md`
- `docs/artifact-schemas.md`
- `tests/smoke.sh`

## Data Flow

1. Read `task_class / quality_requirement / team.role_integrity / quality_seat`.
2. If a separate skeptic seat is present for a `requires-independent` task, dispatch emits skeptic-specific artifacts instead of a repo-root placeholder packet.
3. The first bounded slice materializes both the skeptic worktree and the skeptic-specific handoff/context/runtime packet.
4. Context and summaries expose whether skeptical review is only named or fully materialized.
5. Gates and completion truth can later consume the same skeptic-lane evidence without inferring independence from state names alone.

## Edge Cases

- `T0/T1` no-execution tasks must keep `execution_closeout = not-required`; this task must not reintroduce fake execution requirements.
- Degraded fallback remains legal where policy allows it; the slice must keep that path explicit instead of treating independent skepticism as universal default.
- User-facing interaction still stays on one primary thread; skeptic materialization is an internal execution/review surface only.

## Acceptance

- The design distinguishes “independent skeptic named in state” from “independent skeptic lane actually materialized”.
- The slice stays inside dispatch/context/handoff/worktree/gate surfaces.
- The design does not reopen policy-matrix work that is already archived.

## Verification

- `./scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander`
- `./scripts/demo-entry.sh`
