---
status: proposed
owner: lead
scope: dd-hermes-experience-demo-v1
decision_log:
  - Turn the first experience demo into a real protocol fix: task initialization should route architecture work into `3-explorer-then-execute` automatically.
  - Tighten thread gating so execution cannot begin from a placeholder synthesis file.
checks:
  - ./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1
  - bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh
  - ./tests/smoke.sh workflow
  - ./tests/smoke.sh all
links:
  - scripts/state-init.sh
  - scripts/sprint-init.sh
  - hooks/thread-switch-gate.sh
  - tests/smoke.sh
  - docs/decision-discussion.md
  - workspace/contracts/dd-hermes-experience-demo-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-experience-demo-v1.md
---

# Proposal

## What

Make the first DD Hermes experience demo truthful: architecture-like tasks should automatically start in discussion mode, and execution switching should only unblock once decision synthesis contains a real execution boundary.

## Why

DD Hermes already documents `3-explorer-then-execute`, but task initialization still defaults to `direct` and thread gating only checks for a synthesis path, not whether the synthesis is actually filled in. That means the system still relies on human memory for the exact place where multi-agent discipline matters most.

## Non-goals

- Do not add a new runtime, scheduler, or provider integration.
- Do not rewrite the overall DD Hermes philosophy or reopen already archived router/dispatch work.
- Do not pretend a placeholder synthesis file is enough to authorize execution.

## Acceptance

- `state-init` can infer `discussion.policy = 3-explorer-then-execute` for architecture/control-plane style tasks.
- `sprint-init` can preserve or pass through the necessary focus/policy inputs so the initialized state is truthful from the start.
- `thread-switch-gate` rejects placeholder or empty synthesis files for `3-explorer-then-execute` tasks.
- Smoke coverage proves both the architecture-discussion path and the direct-delivery path.
- The task is ready to be used as the first end-to-end experience demo.

## Verification

- Run `./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1`.
- Run `bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh`.
- Run `./tests/smoke.sh workflow`.
- Run `./tests/smoke.sh all`.
