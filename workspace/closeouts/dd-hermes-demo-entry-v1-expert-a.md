---
task_id: dd-hermes-demo-entry-v1
from: expert-a
to: lead
scope: dd-hermes-demo-entry-v1 execution slice closeout
execution_commit: cae67bf0f02098ef340fd4c79741fb3ec1771d35
state_path: workspace/state/dd-hermes-demo-entry-v1/state.json
context_path: workspace/state/dd-hermes-demo-entry-v1/context.json
runtime_path: workspace/state/dd-hermes-demo-entry-v1/runtime.json
verified_steps:
  - ./scripts/spec-first.sh --changed-files AGENTS.md,docs/context-runtime-state-memory.md,scripts/demo-entry.sh,scripts/execution-thread-prompt.sh,README.md,指挥文档/README.md,指挥文档/03-执行线程干到底说明.md,指挥文档/04-任务重校准与线程策略.md,指挥文档/06-一期PhaseDone审计.md,指挥文档/07-体验入口任务说明.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1
  - bash -n scripts/demo-entry.sh scripts/execution-thread-prompt.sh
  - ./scripts/demo-entry.sh
verified_files:
  - AGENTS.md
  - docs/context-runtime-state-memory.md
  - scripts/demo-entry.sh
  - scripts/execution-thread-prompt.sh
  - README.md
  - 指挥文档/README.md
  - 指挥文档/03-执行线程干到底说明.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
  - 指挥文档/07-体验入口任务说明.md
open_risks:
  - The current control plane still reports `independent_skeptic=false` for this task because lead is temporarily doubling as skeptic.
next_actions:
  - Fill in the execution commit after `git-commit-task.sh`.
---

# Execution Closeout

## Context

Execution closeout for the single-thread user-visible experience entry slice on task dd-hermes-demo-entry-v1.

## Required Fields

- `task_id`
- `from`
- `to`
- `scope`
- `execution_commit`
- `state_path`
- `context_path`
- `runtime_path`
- `verified_steps`
- `verified_files`
- `open_risks`
- `next_actions`

## Completion

- The slice is complete when the read-only entry script, the single-thread wording updates, and the commander-doc alignment are verified and committed from the isolated worktree.

## Verification

- `./scripts/spec-first.sh --changed-files AGENTS.md,docs/context-runtime-state-memory.md,scripts/demo-entry.sh,scripts/execution-thread-prompt.sh,README.md,指挥文档/README.md,指挥文档/03-执行线程干到底说明.md,指挥文档/04-任务重校准与线程策略.md,指挥文档/06-一期PhaseDone审计.md,指挥文档/07-体验入口任务说明.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1`
- `bash -n scripts/demo-entry.sh scripts/execution-thread-prompt.sh`
- `./scripts/demo-entry.sh`

## Open Questions

- Should this task landing immediately trigger a final phase-closeout decision?
