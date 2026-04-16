---
decision_id: quality-seat-escalation-routing
task_id: dd-hermes-quality-seat-escalation-rules-v1
role: curriculum
status: completed
---

# Explorer Finding

## Goal

Decide how to explain the archive-to-successor transition so DD Hermes users and maintainers do not confuse a closed proof with the new phase-2 mainline.

## Findings

- The archived proof task should remain readable as “this is how DD Hermes exposes quality-seat truth today.”
- The successor task should read as “this is how DD Hermes will decide when degraded supervision is acceptable.”
- `README`, `指挥文档/04`, `指挥文档/06`, and `指挥文档/08` are the minimum narrative surfaces that must switch together.

## Recommended Path

- Archive the proof task and switch the documented phase-2 mainline in one batch so `demo-entry` can tell a coherent story.

## Rejected Paths

- Do not leave the old task as “current mainline” after its closeout is archived.
- Do not point `demo-entry` at a new mainline before the successor planning package exists.

## Risks

- If `demo-entry` still points to the old task after archive, the commander's truth source will contradict the repo state.
- If the successor mainline is introduced without a clear product goal, users will read it as generic governance churn.

## Evidence

- `README.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
- `指挥文档/08-恒定锚点策略.md`
