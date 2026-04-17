---
decision_id: explicit-gate-verdicts-routing
task_id: dd-hermes-explicit-gate-verdicts-v1
role: delivery
status: proposed
---

# Explorer Finding

## Goal

Decide what the smallest deliverable successor slice is after the archived escalation-rules proof.

## Findings

- The archived proof already resolved task classification and `T2` manual escalation triggers, so repeating policy work would be churn.
- The smallest shared write set is `team_governance.py`, `state-init.sh`, `state-update.sh`, `state-read.sh`, `context-build.sh`, `dispatch-create.sh`, the two gate hooks, docs, and smoke coverage.
- `dd-hermes-s5-2expert-20260416` is still an experiment with missing product/quality/task-class closure, so it is not a safe successor mainline.

## Recommended Path

- Make `dd-hermes-explicit-gate-verdicts-v1` the active mainline.
- Land persisted verdicts first, then update commander docs/entry so the repo truth stops saying “no active mainline”.
- Prove one ready path and one blocked path through smoke assertions tied to the verdict layer.

## Rejected Paths

- Do not promote the paused two-expert experiment into the mainline.
- Do not switch to explicit routing metadata first; the repo does not yet show stronger breakage there than in verdict persistence.
- Do not add more placeholder task docs without changing the shared control plane.

## Risks

- If commander docs are not updated, the repo will keep advertising “no active mainline” after successor selection.
- If smoke only checks booleans and not persisted verdict fields, the new layer will have no regression guard.

## Evidence

- `workspace/contracts/dd-hermes-anchor-governance-v1.md`
- `workspace/contracts/dd-hermes-s5-2expert-20260416.md`
- `workspace/state/dd-hermes-s5-2expert-20260416/state.json`
- `scripts/demo-entry.sh`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
