---
schema_version: 2
task_id: dd-hermes-independent-quality-seat-v1
owner: lead
experts:
  - expert-a
product_goal: Make DD Hermes expose and enforce whether the quality seat is independent or degraded, so maintainers can trust quality-review truth before execution and completion.
user_value: Let a DD Hermes maintainer tell, before execution and completion, whether the quality seat is truly independent or explicitly degraded.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This archived proof slice predates the frozen T0-T4 escalation matrix and is preserved as a bounded quality-seat proof task accepted under explicit degraded supervision.
non_goals:
  - Do not add a new runtime, provider, gateway, or scheduler layer.
  - Do not reintroduce multiple long-lived chat threads as the main control model.
  - Do not treat generic document cleanup as independent quality-seat delivery.
product_acceptance:
  - State, dispatch, context summary, and gates can all explain whether the quality seat is independent or degraded.
  - The planning package defines one narrow execution boundary for a first implementation slice.
  - The task stays within shared governance scripts, schemas, and tests.
drift_risk: This task could drift into generic governance cleanup or role-theory prose if it stops improving maintainer-visible quality-seat truth.
acceptance:
  - A task-bound planning package exists with contract, proposal, state, handoff, exploration log, and decision synthesis.
  - The decision package identifies the exact control-plane layers the first implementation slice may touch.
  - Workflow and context generation succeed for the planning package.
blocked_if:
  - Missing repo facts or missing verification.
  - Scope expands into runtime/provider/gateway/scheduler work or generic thread orchestration.
  - The task cannot reduce independent-quality semantics to observable state, dispatch, context, and gate truth.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-independent-quality-seat-v1.md
---

# Sprint Contract

## Context

Turn the post-archive phase-2 question into a real planning task: DD Hermes now needs a truthful, maintainer-readable way to represent an independent quality seat or a degraded fallback.

## Scope

- In scope: define the planning package, decision boundary, and control-plane landing zones for an independent quality seat.
- Out of scope: new runtime services, provider/gateway work, scheduler recovery, or a new chat-thread orchestration model.

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

- The planning artifacts all point to the same product outcome.
- The decision synthesis states what execution may change and what remains out of scope.
- The package is ready for a first implementation slice without inventing new control surfaces.

## Product Gate

- The task must help a maintainer answer one question quickly: is the quality seat independent, or is it degraded with an explicit reason.
- This archived proof slice is treated as a pre-matrix `T2` bounded execution task rather than a post-matrix `T3` enforcement task.
- If the slice starts adding theory, runtime machinery, or document churn without improving that answer, stop and recalibrate.

## Verification

- Commands:
  - `./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1`
  - `./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander`
  - `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1`
- User-visible proof: the planning package exists, a decision synthesis is present, and DD Hermes can point to one explicit next execution boundary.

## Open Questions

- Which task classes must require an independent quality seat by default, and which can remain explicitly degraded?
