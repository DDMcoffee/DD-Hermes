---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-successor-triage-v1 committed-repo successor triage
product_rationale: Expose one honest current mainline again by making successor triage itself visible and evidence-backed after archive normalization.
goal_drift_risk: The slice could drift into generic cleanup or guessed feature planning if it stops discriminating between committed repo evidence and working-tree residue.
user_visible_outcome: A maintainer can answer “主线是什么、为什么是它、下一步怎么收口” without reading chat history.
files:
  - workspace/contracts/dd-hermes-successor-triage-v1.md
  - workspace/decisions/successor-triage-routing/synthesis.md
  - workspace/exploration/exploration-lead-dd-hermes-successor-triage-v1.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
  - openspec/proposals/dd-hermes-successor-triage-v1.md
  - workspace/state/dd-hermes-successor-triage-v1/state.json
decisions:
  - Treat `dd-hermes-successor-triage-v1` as the current governance mainline instead of hiding triage behind “暂无主线”.
  - Only committed repo evidence may justify a successor; local residue such as `workspace/state/review-policy-demo/` is explicitly non-evidence.
  - This task is allowed to update task-pack docs, decision evidence, state, and commander truth sources, but not to invent a feature execution slice.
risks:
  - Do not reopen archived proof tasks or blur archive boundaries.
  - Do not let commander docs claim a feature successor exists before the decision pack proves it.
  - Keep degraded supervision explicit until an independent skeptic is actually present.
next_checks:
  - Run `./scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v1`.
  - Run `./scripts/context-build.sh --task-id dd-hermes-successor-triage-v1 --agent-role commander`.
  - Run `./scripts/check-artifact-schemas.sh --task-id dd-hermes-successor-triage-v1`.
  - Run `./scripts/demo-entry.sh`.
  - If monitoring finds drift, consume findings immediately and rerun the same chain.
---

# Lead Handoff

## Context

This sprint has no feature execution slice yet. The current ownership is a governance slice: re-read committed repo truth, expose successor triage as the active mainline, and keep the decision boundary honest until a stronger successor exists.

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

- Keep the triage task task-bound, evidence-backed, and recoverable from repo truth alone.

## Product Check

- Confirm the slice still serves the stated product goal and does not expand into the declared non-goals.

## Verification

- Verification must prove both task-pack validity and commander truth consistency.
- At minimum, include workflow/context/schema/entry results and the changed file list.

## Open Questions

- After this governance slice stabilizes, is there one bounded successor strong enough to deserve its own new task package?
