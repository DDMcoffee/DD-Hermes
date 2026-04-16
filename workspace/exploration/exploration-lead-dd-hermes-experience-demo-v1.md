# Exploration Log

## Context

- Task: dd-hermes-experience-demo-v1
- Role: lead
- Status: DECISION_SYNTHESIZED_READY_FOR_EXECUTION

## Facts

- DD Hermes already has `decision-init`, `thread-switch-gate`, and dispatch/worktree plumbing.
- `state-init` still defaults `discussion.policy` to `direct`, even though architecture-oriented work is supposed to start with `3-explorer-then-execute`.
- `thread-switch-gate` currently only checks whether `synthesis_path` exists; it does not verify whether the synthesis has a real accepted path and execution boundary.

## Hypotheses

- A small protocol fix in `state-init` + `sprint-init` + `thread-switch-gate` is enough to turn the first experience demo into a truthful end-to-end task.
- This task is smaller and more honest than inventing a new feature, because it tightens an already-documented multi-agent promise.

## Evidence

- `scripts/state-init.sh`
- `scripts/sprint-init.sh`
- `hooks/thread-switch-gate.sh`
- `docs/decision-discussion.md`
- `指挥文档/05-体验版本路线图.md`
- explorer conclusions from architecture / delivery / curriculum roles synthesized under `workspace/decisions/experience-demo-policy-routing/`

## Acceptance

- Architecture-style tasks initialize into discussion mode automatically.
- Execution thread switching requires non-placeholder synthesis content.
- Smoke coverage proves the behavior through the normal workflow surface.

## Verification

- Confirm targeted smoke coverage passes for both `3-explorer-then-execute` and `direct` initialization paths.
- Confirm `thread-switch-gate` blocks placeholder synthesis and accepts filled synthesis.

## Open Questions

- Should future routing logic stay keyword-based, or later move to an explicit task metadata field once experience feedback stabilizes?
