---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-quality-seat-escalation-rules-v1 planning and escalation-boundary definition
product_rationale: This slice should tell a DD Hermes maintainer when degraded supervision is acceptable and when an independent quality seat is mandatory.
goal_drift_risk: The slice could drift into generic governance theory if it stops reducing ambiguity for real DD Hermes task classes.
user_visible_outcome: A maintainer can see not only the current seat truth, but also whether the current task class is allowed to stay degraded.
files:
  - workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md
  - openspec/proposals/dd-hermes-quality-seat-escalation-rules-v1.md
  - openspec/designs/dd-hermes-quality-seat-escalation-rules-v1.md
  - openspec/tasks/dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/state/dd-hermes-quality-seat-escalation-rules-v1/state.json
  - workspace/decisions/quality-seat-escalation-routing/synthesis.md
decisions:
  - Archive the previous proof task instead of adding another slice to it.
  - Keep the new mainline at the task-class escalation layer before any broader governance changes.
  - Reuse the existing quality-seat truth already exposed across state/context/dispatch/gates.
risks:
  - Do not change policy through memory writes.
  - Do not reopen `dd-hermes-independent-quality-seat-v1` with new implementation work.
  - Do not expand into runtime/provider/scheduler or generic documentation churn.
next_checks:
  - Run workflow/context verification for the planning package.
  - Write back the accepted escalation boundary before any new execution slice begins.
---

# Lead Handoff

## Context

Expert expert-a owns the planning slice that turns “quality seat escalation rules” into a bounded next mainline rather than an abstract policy placeholder.

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

- Keep the planning artifacts task-bound, product-explicit, and ready for a later first execution slice.

## Product Check

- Confirm the slice names real DD Hermes task classes and keeps the next boundary inside shared governance scripts, docs, and tests.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`

## Open Questions

- Which task classes should DD Hermes initially treat as `requires-independent`, and which are acceptable as `degraded-allowed`?
