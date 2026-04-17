---
status: active
owner: lead
scope: dd-hermes-quality-seat-escalation-rules-v1
decision_log:
  - Start with task-class classification and gate landing points before any broader policy expansion.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1
  - ./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander
links:
  - openspec/designs/dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/decisions/quality-seat-escalation-routing/synthesis.md
---

# Task

## Steps

1. Freeze the initial matrix: `T0/T1/T2 => degraded-allowed`, `T3/T4 => requires-independent`.
2. Add `task_class / quality_requirement / task_class_rationale` to the shared governance truth.
3. Land the minimum control-plane surfaces the first execution slice may change.
4. Prove one degraded-allowed path and one requires-independent blocked path through workflow/context/dispatch/gates.
5. Add the narrow follow-up rule for `T2`: when bounded work hits `high_risk_mode`, `integration_pressure`, or repeated verification failures, DD Hermes must block until maintainers explicitly escalate to `requires-independent`.

## Dependencies

- `workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md`
- `workspace/decisions/quality-seat-escalation-routing/synthesis.md`
- archived proof from `dd-hermes-independent-quality-seat-v1`

## Done Definition

- DD Hermes has a named escalation-rules mainline with one concrete matrix and one bounded execution slice.
- The repo can explain why the previous proof task was archived and what new user-visible ambiguity this task is resolving.
- The execution slice is ready without reopening the archived proof task.

## Acceptance

- The task remains bounded to shared governance scripts, docs, and tests.
- The accepted path identifies the T0-T4 matrix and shows it in shared control-plane outputs.
- The next slice is explicitly about escalation rules, not re-implementing quality-seat visibility.
- The repo can show one `T2` path that remains degraded-allowed and one `T2` path that is blocked until explicit escalation.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`
