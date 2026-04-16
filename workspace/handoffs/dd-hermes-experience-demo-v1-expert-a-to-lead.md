---
from: expert-a
to: lead
scope: dd-hermes-experience-demo-v1 policy-routing and synthesis-gate execution slice
files:
  - scripts/state-init.sh
  - scripts/sprint-init.sh
  - hooks/thread-switch-gate.sh
  - tests/smoke.sh
  - docs/decision-discussion.md
  - README.md
decisions:
  - Add `discussion_policy=auto` to task initialization so architecture/control-plane flavored tasks can start in `3-explorer-then-execute` without manual state edits.
  - Keep delivery-oriented tasks on `direct` unless the lead explicitly overrides policy.
  - Make `thread-switch-gate` require state, contract, handoff, context, worktree, and non-placeholder synthesis content before allowing execution.
risks:
  - Auto-routing currently relies on `task_id` and `current_focus`; future experience may justify a stricter explicit metadata field.
  - The gate is stricter now, so any future caller that skips `context-build` or `dispatch-create` will be blocked by design.
next_checks:
  - Lead should integrate branch `dd-hermes-experience-demo-v1-expert-a` back to `main` through `git-integrate-task.sh`.
  - Lead should archive the task only after merge succeeds and task-level artifacts are finalized.
---

# Expert Handoff

## Context

This execution slice turns the first DD Hermes experience demo into a real behavioral proof instead of a documentation promise. The slice tightens discussion-policy routing at initialization time and makes execution gating require non-placeholder synthesis plus the expected control-plane artifacts.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Architecture-style tasks can initialize into `3-explorer-then-execute`.
- Delivery-style tasks remain `direct`.
- `thread-switch-gate` blocks when state, context, worktree, or synthesis boundary is missing.
- Smoke coverage proves the new routing and gate behavior.

## Verification

- `./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,docs/decision-discussion.md,README.md,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1` -> pass
- `bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh` -> pass
- `./tests/smoke.sh discussion` -> pass
- `./tests/smoke.sh workflow` -> pass
- `./tests/smoke.sh all` -> pass
- execution commit: `687ffa823672e42cf67a3431d9aa4b640abf2e22` (`feat(dd-hermes-experience-demo-v1): auto-route discussion and tighten execution gate`)

## Open Questions

- Should the long-term routing strategy stay heuristic (`task_id + current_focus`) or later graduate into an explicit task metadata field once enough experience data accumulates?
