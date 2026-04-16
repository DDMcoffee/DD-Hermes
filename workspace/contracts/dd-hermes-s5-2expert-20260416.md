---
task_id: dd-hermes-s5-2expert-20260416
owner: lead
experts:
  - expert-a
  - expert-b
acceptance:
  - Validate that a two-expert parallel sprint can be initialized and dispatched with isolated worktrees.
  - Keep all experiment evidence separated from the current main task finish line.
blocked_if:
  - Missing repo facts or missing verification.
  - The experiment starts to change the current main task scope or acceptance.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-s5-2expert-20260416.md
---

# Sprint Contract

## Context

This sprint is an independent experiment task used to validate the DD Hermes two-expert parallel workflow. It is not part of the current endpoint/schema main-task finish line and must not be used to claim task completion for that main task.

## Scope

- In scope: sprint bootstrap, dispatch, isolated worktree creation, role integrity validation, and experiment documentation.
- Out of scope: mainline feature delivery, project-level policy changes, and any integration into the endpoint/schema task unless separately approved.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- Contract, handoffs, exploration log, proposal, and state all exist and point to the same experiment task id.
- Two executor worktrees can be materialized without contaminating the primary worktree.
- Experiment outputs clearly state that they are not part of the current main task deliverable.

## Verification

- Commands: `scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- Commands: `scripts/dispatch-create.sh --task-id dd-hermes-s5-2expert-20260416`
- User-visible proof: workflow test passes, two isolated executor worktrees exist, and role integrity is reported explicitly.

## Open Questions

- Should this experiment later be resumed as a dedicated phase-validation task, or archived after documentation only?
