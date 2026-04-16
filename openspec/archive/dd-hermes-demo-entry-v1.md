---
status: archived
owner: lead
scope: dd-hermes-demo-entry-v1
decision_log:
  - Added the first single-command user-visible DD Hermes experience entry.
  - Migrated the default workflow wording from split chat threads to single-thread role switching plus isolated worktrees.
  - Closed the final phase-1 blocker and moved the repo to `phase done`.
checks:
  - ./scripts/spec-first.sh --changed-files AGENTS.md,docs/context-runtime-state-memory.md,scripts/demo-entry.sh,scripts/execution-thread-prompt.sh,README.md,指挥文档/README.md,指挥文档/03-执行线程干到底说明.md,指挥文档/04-任务重校准与线程策略.md,指挥文档/06-一期PhaseDone审计.md,指挥文档/07-体验入口任务说明.md,workspace/closeouts/dd-hermes-demo-entry-v1-expert-a.md,workspace/handoffs/dd-hermes-demo-entry-v1-expert-a-to-lead.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1
  - bash -n scripts/demo-entry.sh scripts/execution-thread-prompt.sh
  - ./scripts/demo-entry.sh
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1
  - ./tests/smoke.sh all
links:
  - openspec/proposals/dd-hermes-demo-entry-v1.md
  - workspace/contracts/dd-hermes-demo-entry-v1.md
  - workspace/handoffs/dd-hermes-demo-entry-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-demo-entry-v1-expert-a-to-lead.md
  - workspace/closeouts/dd-hermes-demo-entry-v1-expert-a.md
  - AGENTS.md
  - README.md
  - docs/context-runtime-state-memory.md
  - scripts/demo-entry.sh
  - 指挥文档/06-一期PhaseDone审计.md
---

# Archive

## Result

`dd-hermes-demo-entry-v1` completed the user-visible DD Hermes experience entry. The repository now has a single-command entry point, a single-thread default workflow narrative, and a canonical Chinese phase-closeout page.

## Deviations

- `scripts/execution-thread-prompt.sh` and `hooks/thread-switch-gate.sh` still keep legacy names for compatibility, even though the default workflow no longer requires a second chat thread.
- The control plane still reports `independent_skeptic=false` for this task because lead temporarily doubled as skeptic.

## Risks

- Future changes to commander docs must keep the phase-audit frontmatter truthful, because `scripts/demo-entry.sh` now treats it as the structured truth source.
- If commit message conventions drift away from `feat(<task_id>)` / `integrate(<task_id>)`, the entry script will report proof commits as `未找到`.

## Acceptance

- `./scripts/demo-entry.sh` exposes the current phase status, latest proof, and next-stage focus from repo facts.
- The repo no longer presents split chat threads as the default workflow.
- The task has a full proposal / contract / handoff / closeout / integration / archive trace.
- Phase-1 now has no remaining blocker.

## Verification

- `./scripts/spec-first.sh --changed-files AGENTS.md,docs/context-runtime-state-memory.md,scripts/demo-entry.sh,scripts/execution-thread-prompt.sh,README.md,指挥文档/README.md,指挥文档/03-执行线程干到底说明.md,指挥文档/04-任务重校准与线程策略.md,指挥文档/06-一期PhaseDone审计.md,指挥文档/07-体验入口任务说明.md,workspace/closeouts/dd-hermes-demo-entry-v1-expert-a.md,workspace/handoffs/dd-hermes-demo-entry-v1-expert-a-to-lead.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1`
- `bash -n scripts/demo-entry.sh scripts/execution-thread-prompt.sh`
- `./scripts/demo-entry.sh`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1`
- `./tests/smoke.sh all`
