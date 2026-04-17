---
decision_id: independent-skeptic-dispatch-routing
task_id: dd-hermes-independent-skeptic-dispatch-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Decide the next bounded phase-2 mainline after successor triage has finished rereading committed repo evidence.

## Accepted Path

- Start `dd-hermes-independent-skeptic-dispatch-v1` as the current active mainline.
- Keep it bounded to operational independent skepticism: make a separate skeptic seat materialize as a real internal review lane rather than only as state metadata.
- Reuse existing dispatch/context/gate surfaces and preserve the one-thread outward UX.

## Rejected Paths

- Reopen archived semantics/policy/verdict tasks: rejected because those proofs are already closed and should remain narrow.
- Leave successor triage as the active mainline: rejected because triage has already done its job once the next task is explicit.
- Choose `no-successor-yet`: rejected because the committed archive trail now points to one concrete unresolved gap strongly enough to justify a new task id.

## Execution Boundary

- The task may change dispatch/context/handoff/worktree/gate surfaces.
- It must not expand into runtime/provider work or user-facing thread-model redesign.
- Degraded fallback remains an explicit path; the task is about materializing independent review where it is required, not pretending degraded fallback disappeared.

## Executor Handoff

- Land the planning package and commander truth updates first.
- First execution slice is now fixed to land both together: skeptic worktree plus skeptic-specific handoff/context/runtime packet.
