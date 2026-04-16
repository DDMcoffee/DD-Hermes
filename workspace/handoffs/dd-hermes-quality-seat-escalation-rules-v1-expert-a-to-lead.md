---
schema_version: 2
from: expert-a
to: lead
scope: dd-hermes-quality-seat-escalation-rules-v1 first execution slice
product_rationale: This slice removes maintainer ambiguity about when DD Hermes may stay degraded and when the task class itself requires an independent quality seat.
goal_drift_risk: The task would drift if it expanded into abstract governance theory instead of keeping the matrix and compatibility migration grounded in shared control-plane behavior.
user_visible_outcome: A maintainer can now see task-class policy in state/context/dispatch, and historical v2 proof tasks still validate after the new rules land.
files:
  - scripts/team_governance.py
  - scripts/state-init.sh
  - scripts/state-read.sh
  - scripts/state-update.sh
  - scripts/context-build.sh
  - scripts/dispatch-create.sh
  - hooks/thread-switch-gate.sh
  - hooks/quality-gate.sh
  - scripts/check-artifact-schemas.sh
  - scripts/sprint-init.sh
  - tests/smoke.sh
  - workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/contracts/dd-hermes-anchor-governance-v1.md
  - workspace/contracts/dd-hermes-independent-quality-seat-v1.md
decisions:
  - Freeze the initial matrix as `T0/T1/T2 => degraded-allowed` and `T3/T4 => requires-independent`.
  - Treat the two archived v2 proof tasks as pre-matrix bounded `T2` slices so historical evidence remains valid without weakening the new rule.
  - Keep the current mainline itself as `T3 => requires-independent`.
risks:
  - This handoff closes only the first execution slice, not the full task archive.
  - Future slices can still drift if they reopen generic governance cleanup instead of narrowing override rules.
next_checks:
  - Refresh task state with execution commit, quality-review evidence, and verification history.
  - Rerun `check-artifact-schemas` and `quality-gate` for the current task before deciding archive vs continue.
---

# Expert Handoff

## Context

This handoff returns the first execution slice for `dd-hermes-quality-seat-escalation-rules-v1`. The shared control-plane changes are committed, the legacy-v2 compatibility regression is backfilled, and the task now has a review-backed baseline instead of an unclosed diff.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- The current mainline exposes `task_class / quality_requirement / task_class_rationale` across state, context, dispatch, thread gate, quality gate, schema checks, and sprint bootstrap.
- Historical v2 proof tasks no longer fail schema revalidation after the new rule lands.
- The slice stays bounded to shared governance scripts, contracts, state migration, and smoke coverage.

## Product Check

- The slice improves one maintainer-facing answer: which DD Hermes task classes may stay degraded, and which must require an independent quality seat.

## Verification

- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-anchor-governance-v1` -> pass
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1` -> pass
- `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1` -> pass
- `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander` -> pass
- `./scripts/dispatch-create.sh --task-id dd-hermes-quality-seat-escalation-rules-v1` -> pass
- `./hooks/thread-switch-gate.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --target execution` -> pass
- execution commit: `f1d84d97e0d993f1720153038c07a106293cd37a`

## Open Questions

- Should the next slice archive this task, or keep it open to encode explicit `T2 -> requires-independent` override rules?
