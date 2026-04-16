---
status: proposed
owner: lead
scope: dd-hermes-demo-entry-v1
decision_log:
  - The first real DD Hermes experience demo has already been proven end to end.
  - The next gap is not another control-plane primitive; it is the lack of a single user-visible entry that explains and proves the current experience version.
checks:
  - ./scripts/spec-first.sh --changed-files scripts/demo-entry.sh,README.md,指挥文档/README.md,指挥文档/07-体验入口任务说明.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1
  - bash -n scripts/demo-entry.sh
  - ./scripts/demo-entry.sh
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1
links:
  - README.md
  - 指挥文档/05-体验版本路线图.md
  - workspace/contracts/dd-hermes-demo-entry-v1.md
  - workspace/handoffs/dd-hermes-demo-entry-v1-lead-to-expert-a.md
  - workspace/exploration/exploration-lead-dd-hermes-demo-entry-v1.md
  - 指挥文档/06-一期PhaseDone审计.md
  - 指挥文档/07-体验入口任务说明.md
---

# Proposal

## What

Build the first canonical DD Hermes experience entry: one script command and one Chinese landing page that tell a human what phase-1 can already do, what the latest end-to-end proof is, and what the next mainline task is.

## Why

The repo already has a real end-to-end demo, but the experience is still hidden behind scattered commander docs and task traces. That makes the project feel less complete than it actually is. A truthful entry point is the smallest next step that makes the experience version visible.

## Non-goals

- Do not add a new runtime, scheduler, provider, or plugin loader.
- Do not reopen archived router / dispatch / experience-demo control-plane tasks.
- Do not fake readiness with hard-coded claims that are not derived from current repo facts.

## Acceptance

- A single command can show current DD Hermes experience readiness and point at the latest end-to-end proof.
- A single Chinese landing page explains what the user is seeing and where to go next.
- The entry is grounded in current repo truth, including task ids and commit anchors.
- The task remains an experience-entry task, not a disguised control-plane expansion.

## Verification

- Run `./scripts/spec-first.sh --changed-files scripts/demo-entry.sh,README.md,指挥文档/README.md,指挥文档/07-体验入口任务说明.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1`.
- Run `bash -n scripts/demo-entry.sh`.
- Run `./scripts/demo-entry.sh`.
- Run `./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1`.
