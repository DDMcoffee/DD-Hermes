---
schema_version: 2
task_id: dd-hermes-execution-bootstrap
owner: lead
experts:
  - expert-a
product_goal: Bootstrap DD Hermes task-bound execution so sprint artifacts, shared scripts, and worktree-safe control-plane flows become runnable instead of ad hoc.
user_value: Let a maintainer initialize and run DD Hermes collaboration artifacts from templates and shared scripts rather than stitching together manual bootstrap steps.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: 启动型实现切片，覆盖 bootstrap/worktree/control-plane 基础能力，但仍是有界的执行收口任务。
non_goals:
  - Do not add unrelated runtime features outside the bootstrap and integration path.
  - Do not claim later endpoint/router/dispatch follow-up work as if it were newly invented here.
product_acceptance:
  - Sprint bootstrap artifacts are template-aligned and task-bound.
  - Shared control-plane scripts work safely from linked worktrees.
  - The task reaches at least task-done and leaves follow-up slices to separate tasks.
drift_risk: This task could drift into an omnibus infrastructure bucket if bootstrap/foundation work is allowed to absorb every later control-plane follow-up.
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

## Product Gate

- The product outcome is DD Hermes bootstrap viability, not a catch-all bucket for every later control-plane feature.
- Verification and archive truth must stay bound to bootstrap/worktree/integration capability.
- Later endpoint/router/dispatch follow-up slices should remain separately traceable even if they were developed on the same branch history.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap`
- Run `./tests/smoke.sh all`

## Open Questions

- Phase-level follow-up work will be delegated as a new execution slice after this bootstrap task is closed.
