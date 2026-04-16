---
decision_id: experience-demo-policy-routing
task_id: dd-hermes-experience-demo-v1
role: delivery
status: proposed
---

# Explorer Finding

## Goal

Decide which smallest real delivery slice should be used for the first DD Hermes experience-demo task.

## Findings

- The first experience demo should be a real implementation slice, not more traceability backfill.
- The slice should be small enough to run through worktree, execution commit, verification, and integration in one pass.
- Tightening discussion-policy routing and synthesis gating fits that shape because it changes real behavior while staying within a bounded write set.

## Recommended Path

- Use `dd-hermes-experience-demo-v1` to implement automatic routing into `3-explorer-then-execute` for architecture-style tasks and to harden the execution gate.
- Verify it with targeted workflow smoke plus full smoke.

## Rejected Paths

- Do not spend the demo on already archived bootstrap/router/dispatch slices.
- Do not make `git-integrate-task` the demo target itself; the real demo task can use integration as part of the flow instead of patching it first.

## Risks

- If the slice grows into a generic orchestration rewrite, the demo will lose momentum.
- If no targeted smoke is added, the demo will still rely on full-smoke coincidence instead of explicit proof.

## Evidence

- `README.md`
- `tests/smoke.sh`
- `scripts/git-integrate-task.sh`
- `指挥文档/03-执行线程干到底说明.md`
