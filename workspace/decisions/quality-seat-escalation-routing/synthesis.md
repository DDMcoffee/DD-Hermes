---
decision_id: quality-seat-escalation-routing
task_id: dd-hermes-quality-seat-escalation-rules-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Decide whether to keep extending `dd-hermes-independent-quality-seat-v1`, or archive it and open a new phase-2 mainline for quality-seat escalation rules.

## Accepted Path

- Archive `dd-hermes-independent-quality-seat-v1` as a bounded proof task now that its first execution slice is semantically closed.
- Start `dd-hermes-quality-seat-escalation-rules-v1` as the new phase-2 mainline focused on task-class escalation rules.
- Freeze the initial matrix as `T0/T1/T2 => degraded-allowed` and `T3/T4 => requires-independent`, with explicit `T2 -> requires-independent` escalation allowed when bounded work stops being low risk.

## Rejected Paths

- Do not add another implementation slice to `dd-hermes-independent-quality-seat-v1`; that would turn a completed proof task into an open-ended governance umbrella.
- Do not jump to runtime/provider/thread-model work; the remaining ambiguity is still inside shared governance policy.

## Execution Boundary

- The next execution slice may only add task-class escalation metadata and gate logic to shared governance surfaces such as `state`, `context`, `dispatch`, `thread-switch-gate`, `quality-gate`, and smoke coverage.
- The next slice may not reopen the archived proof task or introduce a new runtime, scheduler, provider, or default second chat thread.

## Executor Handoff

- Land `task_class / quality_requirement / task_class_rationale` into the shared control plane.
- Treat `T0/T1/T2` as degraded-allowed by default and `T3/T4` as requires-independent by default.
- Prove a degraded-allowed path and a requires-independent blocked path through shared scripts and smoke tests.
