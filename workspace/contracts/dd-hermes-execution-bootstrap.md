---
task_id: dd-hermes-execution-bootstrap
owner: lead
experts:
  - expert-a
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing repo facts or missing verification.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-execution-bootstrap.md
---

# Sprint Contract

## Context

Integrate the execution-thread bootstrap slice into the command branch and make the task artifacts match the repository templates and current control-plane protocol.

## Scope

- In scope: template-aligned sprint bootstrap docs, worktree-safe control-plane scripts, state/context/git integration, and verification closure for `dd-hermes-execution-bootstrap`.
- Out of scope: new runtime features outside the bootstrap and integration path.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- Lead handoff, contract, exploration log, and proposal are task-bound and no longer contain placeholder content.
- Execution-thread script changes are integrated into the command branch.
- The task reaches at least `task done` under `指挥文档/02-三层终点定义.md`.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap`
- Run `./tests/smoke.sh all`

## Open Questions

- Phase-level follow-up work will be delegated as a new execution slice after this bootstrap task is closed.
