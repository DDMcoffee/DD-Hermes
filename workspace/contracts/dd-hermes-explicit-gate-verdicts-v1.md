---
schema_version: 2
task_id: dd-hermes-explicit-gate-verdicts-v1
owner: lead
experts:
  - expert-a
product_goal: Persist explicit gate verdict snapshots in DD Hermes state so a maintainer can resume, hand off, and audit a task without re-deriving scattered gate booleans.
user_value: Let a DD Hermes maintainer open `state.json`, `state.read`, or `context.json` and immediately see stable product/quality gate status, reasons, and freshness.
task_class: T3
quality_requirement: requires-independent
task_class_rationale: This task changes shared control-plane truth surfaces and gate semantics, so it belongs to DD Hermes strict-execution work.
non_goals:
  - Do not redesign the existing product gate, quality review, or quality-seat policy model.
  - Do not expand into routing metadata, runtime/provider work, or revive the paused two-expert experiment.
product_acceptance:
  - `workspace/state/<task_id>/state.json` stores explicit verdict snapshots for `product gate`, `task policy`, `quality anchor`, `quality review`, `degraded ack`, and `quality seat` execution/completion truth.
  - `state.read` and `context.build` expose stable status strings and reasons from that verdict layer instead of only ad hoc booleans.
  - Commander truth sources no longer have to leave successor selection unresolved once this task is accepted as the active mainline.
drift_risk: This task could drift into generic state cleanup if it stops improving the maintainer-visible truth surface for product and quality gates.
acceptance:
  - A real successor mainline exists with contract, decision synthesis, state, proposal/design/task, and updated commander docs.
  - Gate verdicts are persisted on `state-init` and `state-update`, then surfaced consistently through `state.read`, `context.build`, and gate endpoints.
  - Smoke coverage proves one ready path and one blocked path using explicit verdict fields rather than only computed summaries.
blocked_if:
  - Missing repo facts, missing verification, or scope expanding into a broader routing/runtime rewrite.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-explicit-gate-verdicts-v1.md
---

# Sprint Contract

## Context

The previous phase-2 proof task closed the escalation matrix, but DD Hermes still stores most gate truth as scattered derived booleans. This successor task makes those verdicts explicit so state inspection, resume, and archive can rely on durable control-plane truth.

## Scope

- In scope: formalize the successor task, add explicit gate verdict snapshots to task state, expose them through shared endpoints, and update commander truth sources/tests.
- Out of scope: new runtime services, routing-policy redesign, scheduler/provider work, or reopening archived proof tasks.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `product_goal`
- `user_value`
- `task_class`
- `quality_requirement`
- `task_class_rationale`
- `non_goals`
- `product_acceptance`
- `drift_risk`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- The successor task package is internally consistent and points to a real maintainer-visible ambiguity.
- `state.verdicts` exists for the active mainline and updates with shared governance changes.
- Shared summaries and gates expose the persisted verdict layer, including `execution_closeout`.
- `tests/smoke.sh all` passes with explicit verdict assertions.

## Product Gate

- The task must improve the DD Hermes maintainer experience of reading and trusting task control-plane truth, not just add more JSON.
- The slice stays inside shared governance/state/docs/tests and does not reopen the discussion-routing or two-expert boundaries.
- If the work stops helping the system answer “what exactly is blocked, why, and when was that verdict produced,” stop and recalibrate.

## Verification

- Commands:
  - `./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1`
  - `./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander`
  - `./scripts/check-artifact-schemas.sh --task-id dd-hermes-explicit-gate-verdicts-v1`
  - `bash tests/smoke.sh all`
- User-visible proof: DD Hermes can point to an active phase-2 mainline whose state carries explicit gate verdicts and whose shared summaries/gates/tests all agree on those verdicts.

## Open Questions

- 当前剩余开放问题不再是“要不要持久化 closeout semantic verdict”，而是这条主线什么时候完成真实 `quality review / closeout / integration / archive` 收口。
