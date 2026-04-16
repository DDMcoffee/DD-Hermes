---
decision_id: quality-seat-escalation-routing
task_id: dd-hermes-quality-seat-escalation-rules-v1
role: delivery
status: completed
---

# Explorer Finding

## Goal

Decide the smallest deliverable follow-up after the archived quality-seat proof.

## Findings

- The current proof task already satisfies its user-visible outcome: maintainers can see whether the current seat is degraded or independent.
- The next smallest deliverable is not more visibility work; it is a rule set that says when degraded is still acceptable.
- That deliverable can start as a planning mainline with one later execution slice that only touches shared governance scripts, docs, and tests.

## Recommended Path

- Start `dd-hermes-quality-seat-escalation-rules-v1` as a planning mainline and keep the first execution slice bounded to task-class metadata and gates.

## Rejected Paths

- Do not keep shipping more visibility-oriented changes under the archived proof task.
- Do not expand into broad documentation cleanup without a first concrete execution boundary.

## Risks

- A planning package without a clear first slice will stall and become narrative-only.
- Over-specifying task classes before the first implementation slice may slow delivery without increasing truth.

## Evidence

- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1`
- `workspace/handoffs/dd-hermes-independent-quality-seat-v1-expert-a-to-lead.md`
- `openspec/archive/dd-hermes-independent-quality-seat-v1.md`
- `指挥文档/04-任务重校准与线程策略.md`
