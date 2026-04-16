---
status: proposed
owner: lead
scope: dd-hermes-quality-seat-escalation-rules-v1
decision_log:
  - Archive `dd-hermes-independent-quality-seat-v1` as a closed proof task instead of stretching it into a larger governance umbrella.
  - Open a new phase-2 mainline dedicated to task-class escalation rules for quality seats.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1
  - ./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander
links:
  - workspace/contracts/dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-quality-seat-escalation-rules-v1.md
  - workspace/decisions/quality-seat-escalation-routing/synthesis.md
  - openspec/archive/dd-hermes-independent-quality-seat-v1.md
---

# Proposal

## What

Define the next phase-2 DD Hermes mainline: classify which task classes may proceed under explicit degraded acknowledgement and which must require an independent quality seat before execution or completion.

## Why

`dd-hermes-independent-quality-seat-v1` already proved DD Hermes can expose one truthful quality-seat state across state/context/dispatch/gates. The remaining gap is no longer “what is the seat right now,” but “when is degraded supervision acceptable at all.” That is a new policy slice and should not be stuffed back into the archived proof task.

## Non-goals

- Do not add a new runtime, provider, gateway, or scheduler layer.
- Do not reopen the archived proof task with another implementation slice.
- Do not treat generic documentation cleanup as delivery.

## Acceptance

- The planning package names initial DD Hermes task classes and their default quality-seat requirement.
- Decision synthesis states the exact control-plane landing points for a first implementation slice.
- The task remains bounded to shared governance scripts, docs, and tests.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`.
- Run `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`.
