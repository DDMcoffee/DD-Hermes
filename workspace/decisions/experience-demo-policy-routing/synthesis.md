---
decision_id: experience-demo-policy-routing
task_id: dd-hermes-experience-demo-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Select the smallest real task that can serve as the first DD Hermes end-to-end experience demo.

## Accepted Path

- Use `dd-hermes-experience-demo-v1` to tighten the discussion boundary: architecture/control-plane tasks should auto-route into `3-explorer-then-execute`, while delivery tasks remain `direct`.
- Harden `thread-switch-gate` so it only allows execution when synthesis contains a real accepted path and execution boundary, not just a placeholder file.

## Rejected Paths

- Rejected: spending the demo on already archived bootstrap/router/dispatch tasks, because that would only replay traceability work instead of proving a new real slice.
- Rejected: turning the demo into a generic runtime/scheduler expansion, because that is too large and would blur the finish line.
- Rejected: using textbook or peripheral features for the first demo, because they do not prove the main DD Hermes workflow.

## Execution Boundary

- Execution may change `scripts/state-init.sh`, `scripts/sprint-init.sh`, `hooks/thread-switch-gate.sh`, and `tests/smoke.sh`.
- Execution may make minimal doc/task-artifact edits required to keep the demo honest and testable.
- Execution may not add new runtime services, reopen archived router/dispatch work, or broaden the task into scheduler/provider scope.

## Executor Handoff

- Implement automatic discussion-policy routing for architecture/control-plane flavored tasks.
- Preserve `direct` for delivery-only tasks.
- Make `thread-switch-gate` reject placeholder synthesis files.
- Add targeted smoke coverage proving both routing modes and gate behavior, then run full smoke.
