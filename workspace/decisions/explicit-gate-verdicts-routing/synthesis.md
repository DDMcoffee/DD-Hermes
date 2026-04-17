---
decision_id: explicit-gate-verdicts-routing
task_id: dd-hermes-explicit-gate-verdicts-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Decide the single best successor mainline after the archived escalation-rules proof task.

## Accepted Path

- Start `dd-hermes-explicit-gate-verdicts-v1` as the active phase-2 mainline.
- Persist explicit gate verdict snapshots into `state.verdicts` so DD Hermes can carry stable product/quality gate truth across resume, handoff, entry, and archive.
- Reuse the existing governance model and quality-seat policy; do not invent a parallel policy system.

## Rejected Paths

- Do not prioritize explicit routing metadata first; the repo does not yet show a stronger maintainer-visible break there than in verdict persistence.
- Do not promote `dd-hermes-s5-2expert-20260416` into the mainline; it is still an under-specified experiment, not a ready successor.
- Do not leave successor selection open now that the repo evidence clearly favors one bounded control-plane gap.

## Execution Boundary

- The execution slice may add shared verdict persistence and summary fields inside governance scripts, state endpoints, gate hooks, commander docs, and smoke coverage.
- The slice may not reopen archived proof tasks, redesign routing policy, or expand into runtime/provider/thread-model work.

## Executor Handoff

- Add a shared helper that derives persisted verdict snapshots from raw state.
- Persist `task_policy`, `product_gate`, `quality_anchor`, `quality_review`, `degraded_ack`, and `quality_seat` execution/completion verdicts on `state-init` and `state-update`.
- Expose those verdicts in `state.read`, `context.build`, gate outputs, and commander truth sources.
- Prove one ready path and one blocked path with smoke coverage.
