---
schema_version: 2
task_id: dd-hermes-independent-skeptic-dispatch-v1
owner: lead
experts:
  - expert-a
product_goal: Materialize an actually independent skeptic review lane in DD Hermes so a separate quality seat can be dispatched, contextualized, and audited instead of existing only as role metadata.
user_value: Let a DD Hermes maintainer tell when quality supervision is backed by a real separate skeptic lane rather than only by `independent_skeptic=true` and role names in state.
task_class: T3
quality_requirement: requires-independent
task_class_rationale: 控制面与多角色治理主线；需要把真实独立 skeptic 从命名真相推进到可派发、可审查、可验收的运行面。
non_goals:
  - Do not redesign the runtime, provider, or user-facing thread model.
  - Do not reopen archived quality-seat semantics, escalation-rule, or verdict-persistence tasks.
  - Do not change the existing `T0/T1/T2 => degraded-allowed` and `T3/T4 => requires-independent` policy matrix.
  - Do not require users to manually manage multiple visible chat threads.
product_acceptance:
  - When a separate skeptic is assigned for a `requires-independent` task, DD Hermes materializes a skeptic review lane rather than only exposing role metadata.
  - Shared control-plane surfaces can distinguish named independent skepticism from actually dispatched skeptical review.
  - Degraded fallback remains explicit and truthful when an independent skeptic lane is absent.
drift_risk: This task could drift into abstract staffing theory or broad orchestration redesign if it stops improving the maintainer-visible truth around actual independent review.
acceptance:
  - Complete sprint artifacts and verification.
blocked_if:
  - Missing evidence that operational independent-skeptic dispatch is the remaining narrow gap.
  - Scope expands into runtime/provider work or reopens archived governance proofs.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-independent-skeptic-dispatch-v1.md
---

# Sprint Contract

## Context

Archived phase-2 work already proved three separate truths: quality-seat semantics, task-class escalation policy, and explicit verdict persistence. The remaining gap is operational. `dispatch-create.sh` materializes executor worktrees, but a separate skeptic still does not get an equivalent review lane, even though archived closeouts repeatedly identify a real independent skeptic assignee as the next proof point.

## Scope

- In scope: skeptic-lane dispatch/context/handoff/worktree/gate surfaces for tasks that already require independent quality supervision.
- Out of scope: runtime/provider redesign, user-facing multi-thread UX changes, and reopening archived proof scope.

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

- The mainline package is internally consistent and tied to one clear operational gap.
- The task can explain why archived policy/verdict work is not the remaining gap.
- The slice stays bounded to actual independent skeptic materialization.

## Product Gate

- The task must improve the maintainer experience of trusting independent supervision, not just add more role metadata.
- The slice stays inside shared governance/dispatch artifacts and does not reopen older policy or verdict layers.
- If the work stops helping the system answer “is there a real separate skeptic lane here, or only a named seat?”, stop and recalibrate.

## Verification

- Commands: `scripts/test-workflow.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`
- Commands: `scripts/context-build.sh --task-id dd-hermes-independent-skeptic-dispatch-v1 --agent-role commander`
- Commands: `scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-skeptic-dispatch-v1`
- Commands: `scripts/demo-entry.sh`
- User-visible proof: DD Hermes points to this task as the active mainline and the task package explains why operational independent skepticism, not more policy/verdict work, is the next bounded slice.

## Open Questions

- The first implementation slice is resolved to materialize both: an isolated skeptic worktree plus a skeptic-specific handoff/context/runtime packet, so independent review is operational instead of nominal.
