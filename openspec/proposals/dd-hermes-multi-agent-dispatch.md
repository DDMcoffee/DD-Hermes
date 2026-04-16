---
status: proposed
owner: lead
scope: dd-hermes-multi-agent-dispatch
decision_log:
  - Materialize multi-agent assignments from task state instead of stopping at role metadata.
checks:
  - bash -n scripts/dispatch-create.sh tests/smoke.sh
  - ./tests/smoke.sh workflow
  - ./tests/smoke.sh all
links:
  - docs/long-term-agent-division.md
  - scripts/state-init.sh
  - scripts/state-update.sh
  - scripts/context-build.sh
---

# Proposal

## What

Add a `scripts/dispatch-create.sh` entrypoint that reads `workspace/state/<task_id>/state.json`, creates or confirms executor worktrees, and emits normalized assignment payloads for `Supervisor`, `Executor`, and `Skeptic`.

## Why

The repo already models long-term roles in `state.team`, but it still does not turn those roles into runnable execution units. Without a dispatch layer, “multi agent” remains documentation and metadata rather than runtime behavior.

## Non-goals

- Do not implement a full scheduler or automatic supervisor loop in this change.
- Do not redesign the worktree model or replace existing `worktree-create.sh`.
- Do not add external orchestration services.

## Acceptance

- `dispatch-create.sh` returns at least one supervisor assignment, one skeptic assignment, and one assignment per executor listed in task state.
- Executor assignments create or confirm isolated worktrees under `.worktrees/`.
- Dispatch output includes enough data for a caller to start each role without manually reconstructing paths.
- Smoke coverage fails if multi-agent dispatch collapses back to a single implicit executor flow.

## Verification

- Run `bash -n scripts/dispatch-create.sh tests/smoke.sh`.
- Run `./tests/smoke.sh workflow`.
- Run `./tests/smoke.sh all`.
