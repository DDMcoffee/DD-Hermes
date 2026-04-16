---
from: expert-a
to: lead
scope: dd-hermes-demo-entry-v1 user-visible experience entry slice
files:
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
decisions:
  - Migrate DD Hermes default workflow to a single-thread model with in-thread role switching.
  - Keep isolated worktrees as code-isolation tools instead of as external thread requirements.
  - Use `06-一期PhaseDone审计.md` as the canonical landing page and let `scripts/demo-entry.sh` print the latest proof plus current mainline task.
risks:
  - `hooks/thread-switch-gate.sh` still keeps the historical name and will need a later compatibility cleanup if the wording remains confusing.
  - The current task still exposes `degraded` skeptic truth at the control-plane level; this slice does not change staffing.
next_checks:
  - Lead should verify the script output and single-thread wording on `main` after integration.
  - Lead should decide whether this task landing removes the final phase-1 blocker or if one more phase-closeout task is needed.
---

# Expert Handoff

## Context

This execution slice does two things together: it adds the first user-visible DD Hermes experience entry, and it aligns the repository away from “new chat thread required” language toward a single-thread, role-based workflow.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- `./scripts/demo-entry.sh` prints the current experience status, latest proof, and current mainline task.
- The repository no longer presents split chat threads as the default workflow.
- The slice stays read-only at the entry layer and does not introduce a new controller or runtime behavior.

## Verification

- `./scripts/spec-first.sh --changed-files AGENTS.md,docs/context-runtime-state-memory.md,scripts/demo-entry.sh,scripts/execution-thread-prompt.sh,README.md,指挥文档/README.md,指挥文档/03-执行线程干到底说明.md,指挥文档/04-任务重校准与线程策略.md,指挥文档/06-一期PhaseDone审计.md,指挥文档/07-体验入口任务说明.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1`
- `bash -n scripts/demo-entry.sh scripts/execution-thread-prompt.sh`
- `./scripts/demo-entry.sh`
- execution commit: `cae67bf` (`feat(dd-hermes-demo-entry-v1): add single-thread experience entry`)

## Open Questions

- Once this entry lands on `main`, does phase-1 immediately qualify as `phase done`, or should lead cut one final explicit phase-closeout task?
