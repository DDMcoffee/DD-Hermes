---
from: lead
to: expert-a
scope: dd-hermes-experience-demo-v1 policy-routing and synthesis-gate execution slice
files:
  - scripts/state-init.sh
  - scripts/sprint-init.sh
  - hooks/thread-switch-gate.sh
  - tests/smoke.sh
  - workspace/contracts/dd-hermes-experience-demo-v1.md
  - openspec/proposals/dd-hermes-experience-demo-v1.md
  - workspace/state/dd-hermes-experience-demo-v1/state.json
decisions:
  - This slice is the first real experience demo task, not more bootstrap scaffolding.
  - Architecture/control-plane flavored tasks should auto-route into `3-explorer-then-execute`.
  - A synthesis file must contain real execution-boundary content before `thread-switch-gate` allows execution.
risks:
  - Do not broaden scope into new scheduler/runtime work.
  - Keep auto-routing heuristics explainable; avoid magic rules that cannot be traced back to task metadata.
  - Do not claim independent multi-agent supervision unless the task state and dispatch output truly show it.
next_checks:
  - Run targeted smoke for the auto-routing and gate behavior, then run full smoke.
  - Write back execution evidence, changed files, and any heuristics introduced for policy routing.
---

# Lead Handoff

## Context

Expert `expert-a` owns the first real experience-demo execution slice in an isolated worktree. The goal is to make the discussion/execution boundary truthful before DD Hermes claims it can demonstrate end-to-end multi-agent behavior.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Keep the slice small and real: auto-route architecture tasks into discussion mode, preserve direct mode for delivery work, and require non-placeholder synthesis before execution.

## Verification

- `./scripts/spec-first.sh --changed-files scripts/state-init.sh,scripts/sprint-init.sh,hooks/thread-switch-gate.sh,tests/smoke.sh,workspace/contracts/dd-hermes-experience-demo-v1.md,openspec/proposals/dd-hermes-experience-demo-v1.md --spec-path openspec/proposals/dd-hermes-experience-demo-v1.md --task-id dd-hermes-experience-demo-v1` -> pass
- `bash -n scripts/state-init.sh scripts/sprint-init.sh hooks/thread-switch-gate.sh tests/smoke.sh` -> pass
- `./tests/smoke.sh workflow` -> pass
- `./tests/smoke.sh all` -> pass
- execution commit and expert handoff must both be written before handoff return.

## Open Questions

- Whether the auto-routing heuristics should later become explicit task metadata instead of inference remains a follow-up design question.
