---
status: archived
owner: lead
scope: dd-hermes-experience-demo-v1
decision_log:
  - Completed the first real DD Hermes experience demo by tightening initialization-time discussion routing and execution gating.
  - Proved the end-to-end chain from task definition through execution commit and integration commit on `main`.
checks:
  - ./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,docs/decision-discussion.md,README.md,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1
  - bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh
  - ./tests/smoke.sh discussion
  - ./tests/smoke.sh workflow
  - ./tests/smoke.sh all
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-experience-demo-v1
links:
  - openspec/proposals/dd-hermes-experience-demo-v1.md
  - workspace/contracts/dd-hermes-experience-demo-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-experience-demo-v1.md
  - workspace/handoffs/dd-hermes-experience-demo-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-experience-demo-v1-expert-a-to-lead.md
  - workspace/closeouts/dd-hermes-experience-demo-v1-expert-a.md
  - scripts/state-init.sh
  - scripts/sprint-init.sh
  - hooks/thread-switch-gate.sh
  - tests/smoke.sh
---

# Archive

## Result

`dd-hermes-experience-demo-v1` completed the first real DD Hermes end-to-end experience demo. The system now auto-routes architecture/control-plane flavored tasks into `3-explorer-then-execute`, keeps delivery tasks on `direct`, and blocks execution when the control-plane artifacts or synthesis boundary are missing.

## Deviations

- Auto-routing currently infers from `task_id` and `current_focus` rather than an explicit task metadata field.
- The demo proves an independent skeptic seat can be represented and dispatched truthfully for this task, but it does not claim that every future task will default to an independent skeptic without staffing.

## Risks

- Heuristic routing may need to evolve into explicit metadata if task naming/focus text becomes noisy.
- Downstream automation that tries to skip `context-build` or `dispatch-create` will now be blocked earlier by design.

## Acceptance

- Architecture-style tasks initialize into discussion mode.
- Placeholder synthesis no longer authorizes execution.
- Missing state, context, handoff, or worktree no longer slip past the execution gate.
- Smoke coverage proves the routing and gating behavior.
- The task now has a full proposal / contract / decision / handoff / closeout / integration trace.

## Verification

- `./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,docs/decision-discussion.md,README.md,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1`
- `bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh`
- `./tests/smoke.sh discussion`
- `./tests/smoke.sh workflow`
- `./tests/smoke.sh all`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-experience-demo-v1`
