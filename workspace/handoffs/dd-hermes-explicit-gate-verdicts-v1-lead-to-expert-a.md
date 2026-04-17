---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-explicit-gate-verdicts-v1 first execution slice for persisted gate verdicts
product_rationale: This slice should let a DD Hermes maintainer inspect a task and see explicit product/quality gate verdicts instead of reconstructing them from multiple scripts.
goal_drift_risk: The slice could drift into generic state refactoring if it stops improving the maintainer-visible gate truth surface.
user_visible_outcome: A maintainer can open `state.json`, `state.read`, or `context.json` and immediately see which gate is ready or blocked, why, and when that verdict was refreshed.
files:
  - workspace/contracts/dd-hermes-explicit-gate-verdicts-v1.md
  - openspec/proposals/dd-hermes-explicit-gate-verdicts-v1.md
  - openspec/designs/dd-hermes-explicit-gate-verdicts-v1.md
  - openspec/tasks/dd-hermes-explicit-gate-verdicts-v1.md
  - workspace/state/dd-hermes-explicit-gate-verdicts-v1/state.json
  - workspace/decisions/explicit-gate-verdicts-routing/synthesis.md
decisions:
  - Promote explicit gate verdict persistence as the next phase-2 mainline instead of leaving successor selection open.
  - Persist one shared verdict snapshot instead of scattering more ad hoc booleans.
  - Keep the execution boundary inside shared governance/state/docs/tests.
risks:
  - Do not change policy through memory writes.
  - Do not expand into routing metadata, runtime/provider work, or the paused two-expert experiment.
  - Do not replace raw `product`, `quality`, or `team` fields with verdict-only storage.
next_checks:
  - Prove one ready path and one blocked path using explicit verdict fields.
  - Update commander truth sources after the shared control-plane slice lands.
---

# Lead Handoff

## Context

Expert `expert-a` owns the first execution slice that turns gate truth into persisted control-plane verdicts.

## Required Fields

- `from`
- `to`
- `scope`
- `product_rationale`
- `goal_drift_risk`
- `user_visible_outcome`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Keep the slice task-bound, additive, and prove the persisted verdict layer through real shared outputs.

## Product Check

- Confirm the slice still answers the concrete maintainer question: “what gate is blocked, why, and is that verdict fresh?”

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1`
- `./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander`
- `bash tests/smoke.sh all`

## Open Questions

- Later是否还要把 closeout semantic verdict 也沉淀进 state，而不只保留在 `quality-gate`。
