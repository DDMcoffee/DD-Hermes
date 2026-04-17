---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-independent-skeptic-dispatch-v1 bootstrap artifact slice
product_rationale: Turn the repeated “real independent skeptic assignee” follow-up into one explicit mainline with a bounded implementation surface.
goal_drift_risk: The slice could drift into staffing theory or generic orchestration cleanup if it stops improving the maintainer-visible truth around real independent review.
user_visible_outcome: A maintainer can see that DD Hermes is now working on a real skeptic lane, not reopening older policy/verdict slices.
files:
  - workspace/contracts/dd-hermes-independent-skeptic-dispatch-v1.md
  - openspec/proposals/dd-hermes-independent-skeptic-dispatch-v1.md
  - openspec/designs/dd-hermes-independent-skeptic-dispatch-v1.md
  - openspec/tasks/dd-hermes-independent-skeptic-dispatch-v1.md
  - workspace/decisions/independent-skeptic-dispatch-routing/synthesis.md
  - workspace/state/dd-hermes-independent-skeptic-dispatch-v1/state.json
decisions:
  - Keep the mainline focused on operational independent skepticism, not on redoing escalation rules or verdict persistence.
  - Preserve the one-thread outward UX; any separate skeptic lane remains internal to DD Hermes.
  - Reuse existing dispatch/context/gate surfaces instead of inventing a parallel workflow.
  - Materialize the first lane as both a skeptic worktree and a skeptic-specific handoff/context/runtime packet.
risks:
  - Do not overclaim independent supervision before a skeptic lane is actually materialized.
  - Do not expand into runtime/provider work.
  - Keep degraded fallback explicit until a separate skeptic lane is real.
next_checks:
  - Run `./scripts/test-workflow.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`.
  - Run `./scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander`.
  - Run `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`.
  - Run `./scripts/demo-entry.sh`.
  - Verify that dispatch, state, context, and thread gate all agree on the materialized skeptic lane truth.
---

# Lead Handoff

## Context

Expert expert-a owns the initial planning/implementation boundary for the next phase-2 mainline. The task is not “more policy”; it is “make a separate skeptic lane operational and auditable.”

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

- Keep the mainline task-bound, product-bound, and ready for a bounded first implementation slice.

## Product Check

- Confirm the slice still serves the stated product goal and does not expand into staffing theory, runtime work, or user-visible thread proliferation.

## Verification

- State commands and evidence expected from expert before handoff return.
- At minimum, include the workflow/context/schema/entry results and the changed file list.

## Open Questions

- First-slice boundary is fixed: create both the skeptic worktree and the skeptic-specific handoff/context bundle.
