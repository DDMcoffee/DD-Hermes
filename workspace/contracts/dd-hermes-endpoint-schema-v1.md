---
schema_version: 2
task_id: dd-hermes-endpoint-schema-v1
owner: lead
experts:
  - expert-a
product_goal: Make DD Hermes endpoint and artifact contracts explicit, field-level, and executable through repository checks.
user_value: Let a maintainer inspect and validate DD Hermes control-plane contracts from docs/templates/checkers instead of relying on implicit commit history.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: 公共 schema/doc/checker 切片，但实现写集受控，主要是协议文档、模板和校验脚本的收口。
non_goals:
  - Do not expand into router-only or dispatch-only follow-up work.
  - Do not introduce new runtime services or provider-layer changes.
product_acceptance:
  - Endpoint and artifact schema docs are explicit and field-level.
  - Execution closeout support is materialized in templates and sprint bootstrap flow.
  - Repository checks verify contract, handoff, state, and closeout requirements.
drift_risk: This task could drift into generic docs churn if it stops hardening the executable schema path specifically.
acceptance:
  - Endpoint and artifact schema docs are explicit, field-level, and executable through repository checks.
  - Execution closeout support is materialized in repository templates and sprint bootstrap flow.
  - Schema validation and smoke verification cover contract, handoff, state, and closeout requirements.
blocked_if:
  - Missing verification evidence for the integrated endpoint/schema slice.
  - The task scope expands into router-only or dispatch-only follow-up work that belongs to sibling tasks.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-endpoint-schema-v1.md
---

# Sprint Contract

## Context

Close `dd-hermes-endpoint-schema-v1` as a task-bound record for the endpoint/schema slice that already landed on `main`, so the implementation, verification, and git evidence are traceable under the correct task id.

## Scope

- In scope: `docs/coordination-endpoints.md`, `docs/artifact-schemas.md`, `.codex/templates/EXECUTION-CLOSEOUT.md`, `scripts/check-artifact-schemas.sh`, `scripts/test-artifact-schemas.sh`, `scripts/sprint-init.sh`, and smoke coverage that validates the schema path.
- Out of scope: new runtime services, policy changes, router-only follow-up work owned by `dd-hermes-endpoint-router-v1`, and dispatch-only follow-up work owned by `dd-hermes-multi-agent-dispatch`.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- `docs/coordination-endpoints.md` defines endpoint contracts and field expectations for the three-layer finish line.
- `docs/artifact-schemas.md` defines required keys for contract, handoff, state, and execution closeout artifacts.
- `.codex/templates/EXECUTION-CLOSEOUT.md` exists and sprint bootstrap can materialize closeout files from it.
- `scripts/check-artifact-schemas.sh` and smoke/schema verification paths validate the required artifact structure.
- The task has task-bound handoff, closeout, state, and archive evidence instead of relying only on commit history.

## Product Gate

- The slice is about making endpoint/schema contracts executable, not about expanding the endpoint surface itself.
- The outcome must remain task-bound to schema docs, closeout templating, and validation paths.
- If router or dispatch follow-up work becomes the center of gravity, this task boundary has been crossed.

## Verification

- `bash -n scripts/sprint-init.sh scripts/check-artifact-schemas.sh tests/smoke.sh`
- `./scripts/test-artifact-schemas.sh`
- `./tests/smoke.sh all`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-endpoint-schema-v1`

## Open Questions

- Should `dd-hermes-endpoint-router-v1` and `dd-hermes-multi-agent-dispatch` be archived separately now that their code is also on `main`?
