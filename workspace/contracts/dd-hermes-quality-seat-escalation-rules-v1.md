---
schema_version: 2
task_id: dd-hermes-quality-seat-escalation-rules-v1
owner: lead
experts:
  - expert-a
product_goal: Define DD Hermes task-class escalation rules so maintainers know when degraded quality-seat supervision is allowed and when execution must wait for an independent quality seat.
user_value: Let a DD Hermes maintainer decide, before execution or completion, whether a task class may stay degraded or must be upgraded to an independent quality seat.
non_goals:
  - Do not add a new runtime, provider, gateway, or scheduler layer.
  - Do not reopen `dd-hermes-independent-quality-seat-v1` with another implementation slice.
  - Do not reintroduce multiple long-lived chat threads as the default control model.
  - Do not classify every hypothetical future task; stay bounded to task classes that actually matter in DD Hermes.
product_acceptance:
  - The planning package names an initial set of DD Hermes task classes and their default quality-seat requirement.
  - Decision synthesis identifies the exact control-plane surfaces a first implementation slice may touch.
  - The task remains bounded to shared governance scripts, docs, and tests.
drift_risk: This task could drift into abstract role theory or broad governance cleanup if it stops reducing the maintainer-facing ambiguity around degraded vs independent quality seats.
acceptance:
  - Planning artifacts, synthesis, design, task, and state all point to the same escalation-rules outcome.
blocked_if:
  - Missing repo facts or missing verification.
  - Scope expands into runtime/provider/gateway/scheduler work or generic documentation churn.
  - The task cannot name at least one DD Hermes task class that may stay degraded and one that must require an independent quality seat.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-quality-seat-escalation-rules-v1.md
---

# Sprint Contract

## Context

Archive the first quality-seat proof task and define the next phase-2 mainline: escalation rules for when DD Hermes may stay degraded and when it must require an independent quality seat.

## Scope

- In scope: planning package, decision synthesis, design/task framing, and the first implementation boundary for quality-seat escalation rules.
- Out of scope: new runtime services, scheduler recovery, provider/gateway work, or a return to multi-thread chat orchestration as the default model.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `product_goal`
- `user_value`
- `non_goals`
- `product_acceptance`
- `drift_risk`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- All planning artifacts point to one narrow product outcome: task-class-based quality-seat escalation rules.
- The decision synthesis names the exact control-plane files a first implementation slice may touch.
- The next slice can be executed without reopening the archived proof task.

## Product Gate

- The task must remain tied to one clear DD Hermes product outcome.
- If the slice stops reducing ambiguity about when degraded supervision is acceptable, stop and recalibrate before implementation.

## Verification

- Commands:
  - `./scripts/test-workflow.sh --task-id dd-hermes-quality-seat-escalation-rules-v1`
  - `./scripts/context-build.sh --task-id dd-hermes-quality-seat-escalation-rules-v1 --agent-role commander`
- User-visible proof: the planning package exists, the synthesis chooses one path, and DD Hermes can point to a new phase-2 mainline without reopening the archived proof task.

## Open Questions

- Which DD Hermes task classes should default to `independent`, and which may stay `degraded` with explicit acknowledgement?
