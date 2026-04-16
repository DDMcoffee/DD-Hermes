---
decision_id: experience-demo-policy-routing
task_id: dd-hermes-experience-demo-v1
role: architecture
status: proposed
---

# Explorer Finding

## Goal

Decide what the first real DD Hermes experience-demo task should tighten in the architecture/control-plane layer.

## Findings

- `state-init` still defaults `discussion.policy` to `direct`, which leaves architecture-oriented tasks dependent on manual correction.
- `thread-switch-gate` only checks that `synthesis_path` exists, not that the synthesis actually defines an accepted path and execution boundary.
- The command/execution split is already documented and partially enforced, so the smallest truthful demo is to tighten this decision boundary instead of inventing a new feature.

## Recommended Path

- Make `state-init` capable of auto-routing architecture/control-plane tasks into `3-explorer-then-execute`.
- Make `thread-switch-gate` reject placeholder synthesis files.

## Rejected Paths

- Do not use the experience demo to add new runtime services or more control-plane surface.
- Do not treat a merely existing synthesis path as sufficient for execution.

## Risks

- Overfit keyword routing can become opaque if it is not tied to visible task metadata.
- Tightening gate logic must not break delivery-only tasks that should remain `direct`.

## Evidence

- `scripts/state-init.sh`
- `hooks/thread-switch-gate.sh`
- `docs/decision-discussion.md`
- `指挥文档/05-体验版本路线图.md`
