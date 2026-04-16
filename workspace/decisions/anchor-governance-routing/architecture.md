---
decision_id: anchor-governance-routing
task_id: dd-hermes-anchor-governance-v1
role: architecture
status: proposed
---

# Explorer Finding

## Goal

Decide how phase-2 should turn anchor semantics into hard control-plane behavior.

## Findings

- `state-init / state-update / state-read / context-build` 已经拥有大部分 `product / quality / anchor` 字段。
- 真实缺口不是字段缺失，而是 gate 不够硬，且 `lease.goal` 与 `product.goal` 容易漂移。
- `dispatch-create`、`thread-switch-gate`、`quality-gate` 是最小且最有效的落点。

## Recommended Path

- 复用现有字段和角色分析逻辑。
- 增加共享的 product/quality gate 计算，并让 dispatch / thread gate / completion gate 使用它们。
- 让运行态 summary 明确暴露 product gate 与 quality gate 的真相。

## Rejected Paths

- 不新增 runtime service。
- 不把“管理职责”重新做成一个长期在线外部聊天线程。
- 不靠增加更多文档字段来冒充治理完成。

## Risks

- 当前 `independent_skeptic=false`，所以 phase-2 仍然是 degraded 监督形态。
- 如果只修 gate 不同步 task state 与入口文档，会形成新的事实漂移。

## Evidence

- `scripts/state-init.sh`
- `scripts/state-update.sh`
- `scripts/state-read.sh`
- `scripts/context-build.sh`
- `scripts/dispatch-create.sh`
- `hooks/thread-switch-gate.sh`
- `hooks/quality-gate.sh`
- `指挥文档/08-恒定锚点策略.md`
