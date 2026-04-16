---
decision_id: anchor-governance-routing
task_id: dd-hermes-anchor-governance-v1
role: curriculum
status: proposed
---

# Explorer Finding

## Goal

Decide how this phase-2 change should improve the maintainer/operator experience instead of只增加内部复杂度.

## Findings

- 用户现在已经能用只读体验入口，但此前无法看到 phase-2 是不是一个真实任务。
- “产品经理锚点缺失”的感受来自：锚点在文档里存在，但系统没有在关键时刻替产品边界说“不”。
- 只要系统能在进入实现和宣称完成前拦住缺少产品意图或质量审查的任务，用户就能真实感受到锚点存在。

## Recommended Path

- 让入口文档改口到当前真相：phase-2 task 包已经存在，剩余问题是 integration/archive 证明与 degraded 监督形态。
- 把 `product goal / user value / non-goals` 提升到 summary 层，让 maintainer 不用翻长文也能看清任务边界。

## Rejected Paths

- 不用“更多 agent 名称”来制造产品感。
- 不用新 UI 或新 CLI 掩盖 control-plane 还没成型的问题。

## Risks

- 如果入口文档不更新，用户会继续以为 phase-2 还没建档。
- 如果 quality gate 只看测试结果不看质量审查，用户仍会感觉质量位是假的。

## Evidence

- `README.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
- `指挥文档/08-恒定锚点策略.md`
- `scripts/demo-entry.sh`
