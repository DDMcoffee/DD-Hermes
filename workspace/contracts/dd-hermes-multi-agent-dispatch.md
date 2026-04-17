---
schema_version: 2
task_id: dd-hermes-multi-agent-dispatch
owner: lead
experts:
  - expert-a
product_goal: Materialize runnable supervisor/executor/skeptic assignments from DD Hermes task state.
user_value: Let a maintainer see real assignment packets and degraded role-integrity truth instead of keeping role division as documentation-only metadata.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: 多角色派发切片，但写集集中在 dispatch/governance/smoke 输出层，允许显式 degraded 监督。
non_goals:
  - Do not expand into new runtime/provider behavior or multi-thread scheduling.
  - Do not silently make independent skepticism the default experience without a dedicated follow-up task.
product_acceptance:
  - Dispatch materializes supervisor/executor/skeptic assignments from task state.
  - Role-integrity truth is exposed through `independent_skeptic`, `degraded`, and `role_conflicts`.
  - Task-bound artifacts capture the integrated dispatch slice under the correct task id.
drift_risk: This task could drift into general orchestration redesign if it stops focusing on assignment materialization and role-integrity truth.
acceptance:
  - Dispatch materializes supervisor/executor/skeptic assignments from task state.
  - Role-integrity truth is exposed through `independent_skeptic`, `degraded`, and `role_conflicts`.
  - Task-bound artifacts honestly capture the already integrated dispatch slice under the correct task id.
blocked_if:
  - Missing verification evidence for dispatch assignment behavior.
  - Scope expands into later orchestration work that belongs to a follow-up task instead of the original dispatch slice.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-multi-agent-dispatch.md
---

# Sprint Contract

## Context

Close `dd-hermes-multi-agent-dispatch` as a task-bound record for the dispatch slice that already landed on `main`, so assignment materialization, role-integrity truth, verification, and git anchors are captured under the proper task id.

## Scope

- In scope: `scripts/dispatch-create.sh`, `scripts/team_governance.py`, dispatch-related smoke coverage, and the related role-division docs updates in `docs/long-term-agent-division.md` and `README.md`.
- Out of scope: new runtime services, new provider/gateway behavior, independent multi-thread scheduling, and later coordination tasks outside the original dispatch slice.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- `scripts/dispatch-create.sh` materializes `Supervisor` / `Executor` / `Skeptic` assignments from `state.team`.
- Dispatch output exposes degraded role integrity truth when `Skeptic` is not independent.
- Smoke coverage verifies both independent-skeptic and degraded-skeptic cases.
- Task-bound handoff, closeout, archive, and state evidence exist for this dispatch slice.

## Product Gate

- The product outcome is runnable dispatch materialization and truthful role-integrity output.
- This task must not absorb later orchestration or scheduler scope.
- If the slice starts redefining the default quality-seat experience, it belongs in a separate follow-up task.

## Verification

- `bash -n scripts/dispatch-create.sh tests/smoke.sh`
- `./tests/smoke.sh workflow`
- `./tests/smoke.sh all`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-multi-agent-dispatch`

## Open Questions

- Whether future work should make an independent `Skeptic` the default experience version instead of a degraded fallback remains a phase-level decision.
