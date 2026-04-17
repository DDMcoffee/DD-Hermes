---
decision_id: independent-skeptic-dispatch-routing
task_id: dd-hermes-independent-skeptic-dispatch-v1
role: delivery
status: proposed
---

# Explorer Finding

## Goal

Decide what maintainer-visible delivery gap remains after the archived governance proofs.

## Findings

- Maintainers can already read whether quality supervision is degraded or independent in state, but they still cannot point to a real skeptical review lane when the seat is supposed to be independent.
- Current dispatch output makes executors look operational and skeptics look declarative.
- A new successor is justified only if it materially improves that maintainer-visible gap; independent skeptic dispatch does.

## Recommended Path

- Make `dd-hermes-independent-skeptic-dispatch-v1` the next active mainline and keep it focused on materializing skeptical review artifacts/lane rather than on policy discussion.

## Rejected Paths

- Keep successor triage open indefinitely: rejected because that would hide the now-favored next step behind a governance umbrella.
- Leave the repo at `no active mainline`: rejected because the repeated follow-up gap is concrete enough now.

## Risks

- If the task does not produce user-visible/auditable skeptic-lane truth, it will feel like another naming exercise.
- If commander docs are not updated together with task selection, the repo will regress into split truth again.

## Evidence

- `workspace/closeouts/dd-hermes-independent-quality-seat-v1-expert-a.md`
- `openspec/archive/dd-hermes-multi-agent-dispatch.md`
- `scripts/dispatch-create.sh`
- `指挥文档/04-任务重校准与线程策略.md`
