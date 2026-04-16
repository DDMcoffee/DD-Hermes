---
schema_version: 2
task_id: sprint-000
owner: lead
experts:
  - expert-a
product_goal: Define the concrete DD Hermes improvement this sprint must deliver.
user_value: Explain why a maintainer or operator should care about this sprint.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: Explain why this sprint belongs to the chosen DD Hermes task class.
non_goals:
  - List explicit non-goals here.
product_acceptance:
  - State the user-visible product acceptance here.
drift_risk: Describe how this sprint could drift away from the intended product goal.
acceptance:
  - Define acceptance criteria here.
blocked_if:
  - Describe hard blockers here.
memory_reads:
  - memory/world/policy/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/active/sprint-000.md
---

# Sprint Contract

## Context

Describe the task boundary, expected outcome, and why this sprint exists.

## Scope

- In scope:
- Out of scope:

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

- Add verifiable checks.

## Product Gate

- State the user-visible outcome, product boundary, and drift trigger here.

## Verification

- Commands:
- User-visible proof:

## Open Questions

- List unresolved assumptions here.
