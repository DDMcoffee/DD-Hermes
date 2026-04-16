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

1. Define the initial DD Hermes task classes relevant to quality-seat escalation.
2. Decide which classes may proceed under explicit degraded acknowledgement and which must require an independent quality seat.
3. Name the minimum control-plane surfaces the first execution slice may change.
4. Prove the planning package through workflow/context generation before entering implementation.

## Dependencies

- `workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md`
- `workspace/decisions/quality-seat-escalation-routing/synthesis.md`
- archived proof from `dd-hermes-independent-quality-seat-v1`

## Done Definition

- DD Hermes has a named escalation-rules mainline with one accepted path and one bounded next execution slice.
- The repo can explain why the previous proof task was archived and what new user-visible ambiguity this task is resolving.
- The planning package is ready to enter a first implementation slice without reopening the archived proof task.

## Acceptance

- The task remains bounded to shared governance scripts, docs, and tests.
- The accepted path identifies at least one `degraded-allowed` class and one `requires-independent` class.
- The next slice is explicitly about escalation rules, not re-implementing quality-seat visibility.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
- `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`
