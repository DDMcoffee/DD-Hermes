---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-anchor-governance-v1 anchor-governance enforcement slice
product_rationale: This slice should make Product Anchor and Quality Anchor visibly enforce task progression, not just appear in documents.
goal_drift_risk: The slice could drift into generic refactoring if it stops improving the maintainer-facing experience of phase-2 task governance.
user_visible_outcome: A maintainer can see DD Hermes block execution or completion when anchor constraints are missing.
files:
  - scripts/artifact_semantics.py
  - scripts/team_governance.py
  - scripts/state-init.sh
  - scripts/state-update.sh
  - scripts/state-read.sh
  - scripts/context-build.sh
  - scripts/dispatch-create.sh
  - hooks/thread-switch-gate.sh
  - hooks/quality-gate.sh
  - scripts/check-artifact-schemas.sh
  - scripts/demo-entry.sh
  - docs/artifact-schemas.md
  - docs/coordination-endpoints.md
  - README.md
  - tests/smoke.sh
  - workspace/contracts/dd-hermes-anchor-governance-v1.md
  - openspec/proposals/dd-hermes-anchor-governance-v1.md
decisions:
  - Keep phase-2 task-bound: do not expand into runtime/provider/scheduler work.
  - Use existing anchor fields and role model; harden them through gates instead of inventing a new manager thread.
  - Sync runtime-facing goal display to product goal so execution does not drift to lease-only intent.
  - Treat degraded supervision as an explicit exception path that must be acknowledged before dispatch or thread-switch can enter execution.
  - Treat closeout semantics as a separate proof layer from structural schema completeness.
risks:
  - Do not fake completion by updating docs without making gates fail/pass differently.
  - Do not silently allow missing product intent or missing quality review to pass through completion.
  - Keep old historical v1 task records readable; only harden the current phase-2 path and shared runtime surface.
next_checks:
  - Run shell syntax checks, `py_compile`, and `tests/smoke.sh all`.
  - Verify `dd-hermes-anchor-governance-v1` has contract/state/proposal/decision artifacts.
  - Verify current entry docs no longer claim that phase-2 task artifacts are missing.
  - Verify `demo-entry.sh` shows Product Anchor / Quality Anchor / degraded ack truth.
  - Verify `dd-hermes-anchor-governance-v1` itself carries degraded ack and non-placeholder closeout evidence.
---

# Lead Handoff

## Context

Expert `expert-a` owns the first real implementation slice for phase-2 anchor governance. The repo already has anchor vocabulary; this slice must make that vocabulary enforce task progression through actual gate behavior.

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

- The phase-2 task package is real, not route-level.
- Product anchor completeness is visible in summaries and enforced before implementation.
- Quality review completeness is enforced before claiming completion.
- Degraded supervision cannot slip through implicitly; it must be acknowledged and visible.
- Placeholder closeouts cannot be mistaken for execution-complete evidence.

## Product Check

- Confirm the slice improves the operator-visible DD Hermes workflow instead of just increasing field count.

## Verification

- Include shell syntax checks, `python3 -m py_compile scripts/team_governance.py`, and `bash tests/smoke.sh all`.
- Show at least one failing-path assertion and one passing-path assertion for anchor governance.

## Open Questions

- Is computed gate truth enough, or should a later task add explicit `product_gate_status / quality_gate_status` fields?
