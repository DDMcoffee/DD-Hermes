---
decision_id: anchor-governance-routing
task_id: dd-hermes-anchor-governance-v1
role: delivery
status: proposed
---

# Explorer Finding

## Goal

Decide what the smallest deliverable phase-2 execution package should look like.

## Findings

- phase-2 主线此前只有路线文档，没有正式 task 工件。
- 一旦补齐 `contract + state + proposal + handoff + decision synthesis + context + worktree`，当前主线就可以被真实派发。
- 现有 smoke 已经覆盖大部分 shared workflow，因此最小交付可以直接落在 shared scripts 和 smoke assertions 上。

## Recommended Path

- 先建 `dd-hermes-anchor-governance-v1` 的正式任务包。
- 然后只改最小共享写集：team governance helper、state/context summaries、dispatch、thread gate、quality gate、schema check、smoke。
- 最后用 `dispatch-create` 和 `thread-switch-gate` 证明 phase-2 已可进入实现。

## Rejected Paths

- 不开新的长期执行线程去掩盖缺少 task 工件的问题。
- 不把 phase-2 扩成新的 scheduler / quota manager 任务。

## Risks

- 如果 contract 和 state 的 product 叙述不一致，入口会继续漂移。
- 如果只改 tests 不改 shared scripts，会出现假阳性。

## Evidence

- `scripts/sprint-init.sh`
- `scripts/decision-init.sh`
- `workspace/contracts/`
- `workspace/handoffs/`
- `workspace/state/`
- `openspec/proposals/`
- `tests/smoke.sh`
