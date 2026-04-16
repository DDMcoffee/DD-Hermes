---
decision_id: anchor-governance-routing
task_id: dd-hermes-anchor-governance-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Decide how DD Hermes phase-2 should make Product Anchor and Quality Anchor enforce task progression without reintroducing a permanent manager-thread architecture.

## Accepted Path

- Build a real task package for `dd-hermes-anchor-governance-v1` first, so phase-2 is task-bound instead of route-bound.
- Reuse the existing anchor fields in state and summaries, then harden them through `dispatch-create`, `thread-switch-gate`, and `quality-gate`.
- Prefer computed gate truth over adding a new runtime service in this slice.
- Sync execution-facing goal display to `product.goal` so runtime summaries do not drift to `lease.goal`.

## Rejected Paths

- Do not create a new long-lived “manager agent of agents” as the primary fix; the control truth belongs in `state + context + gate`.
- Do not add new runtime/provider/gateway layers for phase-2.
- Do not count “more fields in state” as success unless gates and tests actually change behavior.

## Execution Boundary

- May modify shared governance helpers, state/context summaries, dispatch, thread gate, completion gate, artifact schema checks, and smoke coverage.
- May create and refine task-bound artifacts for `dd-hermes-anchor-governance-v1`.
- Must not expand into new runtime services, scheduler recovery, or external integrations.

## Executor Handoff

- Implement anchor-governance hard constraints in the shared scripts.
- Prove one blocked path for missing product anchor intent and one blocked path for missing quality review.
- Leave the repo with a real phase-2 task package plus passing smoke coverage.
