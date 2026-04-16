---
task_id: dd-hermes-endpoint-router-v1
owner: lead
experts:
  - expert-a
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

## Verification

- `bash -n scripts/coordination-endpoint.sh tests/smoke.sh scripts/test-coordination-endpoint.sh`
- `./scripts/test-coordination-endpoint.sh`
- `./tests/smoke.sh endpoint`
- `./tests/smoke.sh all`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-endpoint-router-v1`

## Open Questions

- Should later endpoint additions after the initial router slice be archived here, or kept as separate follow-up task history?
