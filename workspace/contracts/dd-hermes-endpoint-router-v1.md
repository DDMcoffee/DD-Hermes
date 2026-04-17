---
schema_version: 2
task_id: dd-hermes-endpoint-router-v1
owner: lead
experts:
  - expert-a
product_goal: Materialize one executable coordination-endpoint router for DD Hermes task-bound orchestration.
user_value: Let a maintainer invoke one stable endpoint surface instead of manually fanning out to separate state/context/dispatch scripts.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: 共享控制面入口，但实现边界清晰，主要是路由脚本、验证和文档收口，允许显式 degraded 监督。
non_goals:
  - Do not add later endpoint families that belong to follow-up tasks.
  - Do not expand into new network services, provider wiring, or dispatch/schema follow-up work.
product_acceptance:
  - `scripts/coordination-endpoint.sh` provides one executable router surface for task-bound orchestration.
  - Router behavior is covered by dedicated endpoint tests and smoke coverage.
  - Task-bound artifacts capture the original router slice under the correct task id.
drift_risk: This task could drift into generic endpoint expansion if it stops focusing on the original router introduction slice.
acceptance:
  - A single executable coordination endpoint router exists for task-bound orchestration entry.
  - Router behavior is covered by dedicated endpoint tests and smoke coverage.
  - Task-bound artifacts honestly capture the already integrated router slice under the correct task id.
blocked_if:
  - Missing verification evidence for router entrypoint behavior.
  - Scope expands into later endpoint additions that belong to follow-up tasks instead of the original router slice.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-endpoint-router-v1.md
---

# Sprint Contract

## Context

Close `dd-hermes-endpoint-router-v1` as a task-bound record for the unified coordination endpoint router slice that is already on `main`, so router implementation, verification, and git anchors are captured under the proper task id.

## Scope

- In scope: `scripts/coordination-endpoint.sh`, `scripts/test-coordination-endpoint.sh`, `tests/smoke.sh` endpoint coverage, and the related router-facing docs updates in `docs/coordination-endpoints.md` and `README.md`.
- Out of scope: later endpoint additions beyond the original router acceptance, new network services, policy changes, and unrelated dispatch/schema follow-up work.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- `scripts/coordination-endpoint.sh` routes endpoint name + task id to the correct implementation.
- `state.update` routing preserves stdin JSON payload behavior.
- Router verification exists through `scripts/test-coordination-endpoint.sh` and `tests/smoke.sh endpoint`.
- Task-bound handoff, closeout, archive, and state evidence exist for this router slice.

## Product Gate

- The product outcome is a single router surface, not later endpoint expansion.
- Verification and archive evidence must still point back to the original router introduction slice.
- If the work starts absorbing schema or dispatch follow-up scope, it no longer belongs to this task.

## Verification

- `bash -n scripts/coordination-endpoint.sh tests/smoke.sh scripts/test-coordination-endpoint.sh`
- `./scripts/test-coordination-endpoint.sh`
- `./tests/smoke.sh endpoint`
- `./tests/smoke.sh all`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-endpoint-router-v1`

## Open Questions

- Should later endpoint additions after the initial router slice be archived here, or kept as separate follow-up task history?
