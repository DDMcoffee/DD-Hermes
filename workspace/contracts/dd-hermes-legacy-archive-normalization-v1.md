---
schema_version: 2
task_id: dd-hermes-legacy-archive-normalization-v1
owner: lead
experts:
  - expert-a
product_goal: Normalize archived DD Hermes proof tasks so legacy contracts, states, and verdicts still tell the truth under the current control-plane model.
user_value: Let a maintainer trust archived proof history again instead of reverse-engineering which old tasks are real, which are missing v2 metadata, and which are only blocked by outdated closeout semantics.
task_class: T3
quality_requirement: requires-independent
task_class_rationale: 控制面、架构、策略或高回归风险任务，默认要求独立质量位。
non_goals:
  - Do not expand into unrelated runtime, provider, or gateway work.
  - Do not fabricate a new feature mainline or reopen archived product scope.
  - Do not rewrite historical implementation slices that are already archived and verified.
product_acceptance:
  - Legacy archived proof tasks gain explicit product/task-class truth and stop defaulting to empty v1 state surfaces.
  - No-execution archived tasks stop reporting fake blocked execution-closeout truth.
  - Representative legacy archived execution tasks can pass schema checks again after closeout/state normalization.
drift_risk: This task could drift into generic repo cleanup if it stops targeting archived proof truth and no-execution archive semantics specifically.
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing repo facts or missing verification.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-legacy-archive-normalization-v1.md
---

# Sprint Contract

## Context

Archive truth is now the narrowest real DD Hermes control-plane gap. Several archived proof tasks still carry v1 contracts/states or placeholder closeout semantics, which makes `state.read`, `closeout.check`, and maintainer triage disagree about what those historical proofs actually established.

## Scope

- In scope: no-execution closeout semantics, legacy archived proof contract normalization, representative closeout backfills, state refresh, and the docs/tests needed to lock that truth in place.
- Out of scope: new runtime/provider features, new product mainline claims, and unrelated commander-doc cleanup.

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

- Legacy archived proof tasks that still sit on v1 truth surfaces are upgraded to schema v2 product/task-class metadata.
- Archived `T0/T1` tasks expose `execution_closeout = not-required` instead of fake blocked closeout truth.
- Representative archived execution tasks expose consistent state/closeout truth again under `state.read` and `check-artifact-schemas`.

## Product Gate

- The task must remain tied to one clear DD Hermes product outcome.
- This bootstrap defaults to `T3` with `requires-independent` so later gates know the intended quality-seat bar.
- If the slice starts expanding into generic cleanup or a new mainline claim, stop and recalibrate before implementation.

## Verification

- Commands: `./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1`
- Commands: `./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander`
- Commands: `./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1`
- Commands: `./scripts/check-artifact-schemas.sh --task-id dd-hermes-s5-2expert-20260416`
- Commands: `bash tests/smoke.sh all`
- User-visible proof: archived proof tasks stop surfacing stale blocked truth when their historical class is `no-execution`, and representative legacy execution tasks regain coherent archive semantics.

## Open Questions

- Should the repo later add a separate archive-audit endpoint for scanning every archived proof, or is the normalized `state.read/closeout.check` surface sufficient?
