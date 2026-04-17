---
status: design
owner: lead
scope: dd-hermes-explicit-gate-verdicts-v1
decision_log:
  - Persist one shared verdict snapshot instead of letting each endpoint invent its own gate summary.
  - Keep verdict storage additive: do not replace raw `product`, `quality`, or `team` source fields.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1
  - ./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander
links:
  - workspace/contracts/dd-hermes-explicit-gate-verdicts-v1.md
  - workspace/decisions/explicit-gate-verdicts-routing/synthesis.md
  - docs/artifact-schemas.md
  - docs/coordination-endpoints.md
---

# Design

## Summary

Introduce a persisted `state.verdicts` layer that captures the current product/quality gate verdicts, plus `execution_closeout`, and surface that layer consistently through `state.read`, `context.build`, and gate endpoints.

## Interfaces

- `workspace/state/<task_id>/state.json`
  - Add a top-level `verdicts` object for `task_policy`, `product_gate`, `quality_anchor`, `quality_review`, `degraded_ack`, `quality_seat_execution`, `quality_seat_completion`, and `execution_closeout`.
- `scripts/team_governance.py`
  - Add one shared governance snapshot helper that derives persisted verdicts from raw state.
- `scripts/state-init.sh` / `scripts/state-update.sh`
  - Recompute and persist the shared verdict snapshot whenever state is initialized or updated.
- `scripts/state-read.sh` / `scripts/context-build.sh`
  - Expose explicit verdict status strings, reasons, and freshness alongside the raw state.
- `hooks/thread-switch-gate.sh` / `hooks/quality-gate.sh`
  - Reuse the shared verdict snapshot logic so gate behavior and persisted truth cannot drift apart.

## Data Flow

1. Raw control-plane inputs remain in `product`, `quality`, `team`, `verification`, and `discussion`.
2. Shared governance code derives a normalized verdict snapshot from those inputs.
3. `state-init` and `state-update` persist that snapshot into `state.verdicts`.
4. Read/context/gate endpoints expose the same verdict semantics as summary fields and block reasons.
5. `execution_closeout` stops being quality-gate-only ephemeral truth and becomes resumable task state.
5. Commander docs and entry surfaces can point to one active mainline whose verdict truth is stable on disk.

## Edge Cases

- Tasks manually edited on disk may carry stale verdicts until `state-update`/`state-init` refreshes them; the shared helper must still be the single computation path.
- `degraded_ack` should stay explicit even when not required so maintainers can distinguish “not required” from “missing.”
- `quality_review_status` must keep its raw field in `state.quality`, but the verdict layer should also express whether that is gate-ready.
- `T2` manual escalation remains a task-policy verdict, not a separate policy model.
- `execution_closeout` should select the active expert closeout when present, otherwise fall back to the only closeout candidate or block on ambiguity.

## Acceptance

- `state.json` contains a persisted verdict layer for state version 2 tasks, including `execution_closeout`.
- Shared summaries expose stable status fields such as `product_gate_status`, `task_policy_status`, and `quality_anchor_status`.
- One blocked path and one ready path are proven through smoke coverage using the explicit verdict layer.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1`
- `./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander`
- `bash tests/smoke.sh all`
