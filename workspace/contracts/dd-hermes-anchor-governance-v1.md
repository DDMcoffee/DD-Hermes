---
schema_version: 2
task_id: dd-hermes-anchor-governance-v1
owner: lead
experts:
  - expert-a
product_goal: Advance DD Hermes through task dd-hermes-anchor-governance-v1 without drifting from the current product focus.
user_value: Let a DD Hermes maintainer start a phase-2 task and have the system block execution or completion when product intent or quality review is missing.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This archived proof slice predates the frozen T0-T4 escalation matrix and is preserved as a bounded governance proof task accepted under explicit degraded supervision.
non_goals:
  - Do not expand into unrelated runtime, provider, or gateway work.
product_acceptance:
  - Thread-switch and dispatch refuse to enter implementation when product anchor intent is incomplete or drifting.
  - Quality gate refuses completion when code changed but quality review is still pending.
  - The phase-2 mainline exists as a task-bound package with contract, state, proposal, handoff, decision synthesis, and verification evidence.
drift_risk: This task could drift into generic control-plane cleanup if it stops improving the phase-2 product anchor and quality anchor experience.
acceptance:
  - Anchor governance becomes a hard constraint in state, dispatch, context summary, thread gate, and completion gate.
  - Smoke coverage proves both blocking and passing paths.
blocked_if:
  - Missing repo facts or missing verification.
  - Scope expands into new runtime, provider, gateway, scheduler, or unrelated thread orchestration work.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-anchor-governance-v1.md
---

# Sprint Contract

## Context

Turn phase-2 anchor governance from a route-level idea into a real DD Hermes task and then make product/quality anchors enforceable in the control plane.

## Scope

- In scope: formalize the phase-2 task package, harden anchor constraints in state/dispatch/context/gates, and prove the behavior with repo tests.
- Out of scope: new runtime services, new provider integration, autonomous scheduler recovery, or another chat-thread orchestration system.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `product_goal`
- `user_value`
- `task_class`
- `quality_requirement`
- `task_class_rationale`
- `non_goals`
- `product_acceptance`
- `drift_risk`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- A phase-2 task package exists and is internally consistent.
- `dispatch-create` blocks if product anchor intent is incomplete, and passes when the anchor package is complete.
- `thread-switch-gate` blocks implementation when product anchor constraints are incomplete or drifting.
- `quality-gate` blocks completion when code changed without a recorded quality review.
- `tests/smoke.sh all` passes with anchor-governance assertions.

## Product Gate

- The task must improve the maintainer-facing experience of DD Hermes phase-2, not just add more fields.
- This archived proof slice is treated as a pre-matrix `T2` bounded execution task rather than a post-matrix `T3` enforcement task.
- If the work stops helping the system say "this task has a real product goal and a real quality review", stop and recalibrate.

## Verification

- Commands:
  - `bash -n scripts/state-init.sh scripts/state-update.sh scripts/state-read.sh scripts/context-build.sh scripts/dispatch-create.sh hooks/thread-switch-gate.sh hooks/quality-gate.sh scripts/check-artifact-schemas.sh tests/smoke.sh`
  - `python3 -m py_compile scripts/team_governance.py`
  - `bash tests/smoke.sh all`
- User-visible proof: DD Hermes can point to a real phase-2 task package, and the control plane blocks implementation/completion when anchor requirements are not met.

## Open Questions

- Should phase-2 later add explicit `product_gate_status / quality_gate_status` state fields, or is computed gate truth sufficient for now?
