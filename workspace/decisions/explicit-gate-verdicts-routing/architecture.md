---
decision_id: explicit-gate-verdicts-routing
task_id: dd-hermes-explicit-gate-verdicts-v1
role: architecture
status: proposed
---

# Explorer Finding

## Goal

Decide whether the next phase-2 mainline should persist explicit gate verdicts or keep relying on per-endpoint recomputation.

## Findings

- Shared governance truth already exists, but it is recomputed independently in `state-read`, `context-build`, `dispatch-create`, `thread-switch-gate`, and `quality-gate`.
- Raw control-plane fields live in `product`, `quality`, and `team`, yet there is no durable verdict layer that says which gate is ready/blocked right now and why.
- The missing piece is not another policy model; it is one persisted snapshot that keeps the computed verdicts stable across resume/handoff/archive.

## Recommended Path

- Add one shared governance snapshot helper and persist its verdict output into `state.verdicts`.
- Keep raw source fields intact and treat verdicts as additive control-plane truth.
- Update shared summaries and gates to expose explicit status/reasons from that verdict layer.

## Rejected Paths

- Do not leave verdicts purely implicit inside each endpoint.
- Do not flatten the model into only `product_gate_status` and `quality_gate_status`; the maintainer still needs anchor/review/seat-level verdicts.
- Do not open a broader routing/runtime refactor.

## Risks

- Manual edits to `state.json` could make persisted verdicts stale until `state-update` or `state-init` refreshes them.
- If the helper is not shared, verdict persistence will just duplicate drift instead of fixing it.

## Evidence

- `scripts/state-init.sh`
- `scripts/state-update.sh`
- `scripts/state-read.sh`
- `scripts/context-build.sh`
- `scripts/dispatch-create.sh`
- `hooks/thread-switch-gate.sh`
- `hooks/quality-gate.sh`
