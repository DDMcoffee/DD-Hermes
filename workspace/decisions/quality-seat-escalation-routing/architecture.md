---
decision_id: quality-seat-escalation-routing
task_id: dd-hermes-quality-seat-escalation-rules-v1
role: architecture
status: completed
---

# Explorer Finding

## Goal

Decide whether the next phase-2 step should extend the archived proof task or create a new bounded mainline for escalation rules.

## Findings

- `dd-hermes-independent-quality-seat-v1` already closed the first quality-seat proof slice with semantic closeout and should stay bounded.
- The remaining ambiguity is architectural policy: which task classes are allowed to stay degraded and which must require an independent quality seat.
- That ambiguity belongs in a new task because it changes control-plane policy scope, not just the archived proof task's implementation details.

## Recommended Path

- Archive the proof task and move to a new mainline that only handles escalation rules across shared governance surfaces.

## Rejected Paths

- Do not keep adding slices to `dd-hermes-independent-quality-seat-v1`; that would blur a completed proof into an umbrella governance task.
- Do not jump to runtime or thread-model work; the next boundary is still inside shared governance policy.

## Risks

- If task-class taxonomy is too broad, the mainline will drift into theory instead of enforcement.
- If task-class taxonomy is too narrow, DD Hermes will still leave high-risk tasks under-guarded.

## Evidence

- `workspace/contracts/dd-hermes-independent-quality-seat-v1.md`
- `workspace/closeouts/dd-hermes-independent-quality-seat-v1-expert-a.md`
- `workspace/state/dd-hermes-independent-quality-seat-v1/state.json`
- `openspec/tasks/dd-hermes-independent-quality-seat-v1.md`
