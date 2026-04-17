---
schema_version: 2
task_id: dd-hermes-experience-demo-v1
owner: lead
experts:
  - expert-a
product_goal: Prove the first real DD Hermes experience slice by auto-routing architecture work into discussion synthesis and enforcing execution gating from that synthesis.
user_value: Let a maintainer trust that architecture-flavored tasks will not jump straight into execution without an explicit synthesis boundary.
task_class: T3
quality_requirement: requires-independent
task_class_rationale: 讨论策略和线程门卫属于控制面与架构边界任务，默认要求独立质量位。
non_goals:
  - Do not add new runtime services, scheduler work, provider integration, or unrelated endpoint/dispatch expansion.
  - Do not turn heuristic routing into a broad metadata system in this slice.
product_acceptance:
  - Architecture-oriented tasks auto-initialize into `3-explorer-then-execute`.
  - Delivery-only tasks still initialize into `direct`.
  - Execution thread switching is blocked until a real synthesis boundary exists.
drift_risk: This task could drift into broad workflow redesign if it stops targeting discussion-policy routing and thread-gate enforcement specifically.
acceptance:
  - Architecture-oriented tasks are automatically initialized with `discussion.policy = 3-explorer-then-execute`.
  - Delivery-oriented tasks still default to `discussion.policy = direct`.
  - `thread-switch-gate.sh` blocks execution threads until synthesis contains a real execution boundary instead of only a placeholder path.
  - Smoke coverage proves the auto-routing and gate behavior end to end.
blocked_if:
  - Scope expands beyond discussion-policy routing and thread-gate enforcement.
  - Verification does not prove both architecture and direct-delivery paths.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-experience-demo-v1.md
---

# Sprint Contract

## Context

Run the first real DD Hermes experience demo task by tightening how task initialization chooses `discussion.policy` and how thread switching verifies decision synthesis before execution begins.

## Scope

- In scope: `scripts/state-init.sh`, `scripts/sprint-init.sh`, `hooks/thread-switch-gate.sh`, `tests/smoke.sh`, and minimal docs/task-artifact updates required to demonstrate the behavior end to end.
- Out of scope: new runtime services, scheduler work, provider integration, or unrelated endpoint/dispatch expansion.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- Architecture or control-plane flavored tasks initialize into `3-explorer-then-execute` without manual state editing.
- Delivery-only tasks still initialize into `direct`.
- Execution thread switching is blocked until the synthesis file exists and contains a concrete accepted path plus execution boundary.
- The task can be demonstrated through the normal DD Hermes flow: task artifacts, worktree execution, verification, integration, archive.

## Product Gate

- The product outcome is a real experience proof for discussion-policy routing and execution gating.
- This slice must remain inside architecture-task routing and gate enforcement, not expand into unrelated workflow redesign.
- Because the task changes control-plane entry conditions, independent quality review is mandatory.

## Verification

- `./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1`
- `bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh`
- `./tests/smoke.sh workflow`
- `./tests/smoke.sh all`

## Open Questions

- Which keyword or metadata signals are stable enough for `auto` discussion-policy routing without becoming overfit heuristics?
