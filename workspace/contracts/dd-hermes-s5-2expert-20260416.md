---
schema_version: 2
task_id: dd-hermes-s5-2expert-20260416
owner: lead
experts:
  - expert-a
  - expert-b
product_goal: Preserve the paused two-expert experiment as archived bootstrap-and-dispatch evidence without pretending it delivered a product execution slice.
user_value: Let a maintainer distinguish clearly between parallel bootstrap proof and mainline feature delivery when reading the archive.
task_class: T1
quality_requirement: degraded-allowed
task_class_rationale: 探索性实验验证任务；验证双 expert bootstrap/dispatch 能力，但不进入产品执行切片。
non_goals:
  - Do not treat the experiment as an active mainline or product delivery task.
  - Do not change the endpoint/schema task scope through this archived experiment.
product_acceptance:
  - The archive preserves bootstrap, dispatch, and role-integrity evidence for the two-expert experiment.
  - The task stays explicitly separated from mainline feature delivery.
  - Readers can see that no execution slice was claimed.
drift_risk: This task could drift into fake product progress if the experiment archive starts being presented as feature delivery.
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

## Product Gate

- The product outcome is honest experiment archival, not mainline delivery.
- This task must remain a paused experiment proof and must not be used to claim execution completion.
- Because this is a `T1` no-execution experiment, archive truth should not depend on an execution closeout.

## Verification

- Commands: `scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- Commands: `scripts/dispatch-create.sh --task-id dd-hermes-s5-2expert-20260416`
- User-visible proof: workflow test passes, two isolated executor worktrees exist, and role integrity is reported explicitly.

## Open Questions

- Should this experiment later be resumed as a dedicated phase-validation task, or archived after documentation only?
