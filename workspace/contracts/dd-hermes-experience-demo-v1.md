---
task_id: dd-hermes-experience-demo-v1
owner: lead
experts:
  - expert-a
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

## Verification

- `./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1`
- `bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh`
- `./tests/smoke.sh workflow`
- `./tests/smoke.sh all`

## Open Questions

- Which keyword or metadata signals are stable enough for `auto` discussion-policy routing without becoming overfit heuristics?
