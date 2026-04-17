---
phase_status: 一期已经达到完整的 `phase done`；现在可以直接使用 DD Hermes harness 的只读入口与任务控制面。
latest_proof_task_id: dd-hermes-independent-skeptic-dispatch-v1
latest_proof_archive: openspec/archive/dd-hermes-independent-skeptic-dispatch-v1.md
current_mainline_task_id:
current_mainline_doc:
current_gap_1: 最近 proof 已更新为 `dd-hermes-independent-skeptic-dispatch-v1`；它已经把独立 skeptic 从命名真相推进成 review-backed、merge-backed 的运行面真相。
current_gap_2: 当前没有 active mainline；下一步只剩 successor triage / 新 task package，而不是继续伪装这条 proof 还在执行。
---

# DD Hermes 一期 Phase Done 审计

## 快速判断

- 现在就能用 DD Hermes。
- 当前能用到的程度，是 harness / 控制面级别，而不是新的 runtime 或自动调度器。
- 如果要继续开发，不要把这页当 task tracker；当前是否存在主线、最近 proof 是什么、下一步要不要立新任务，都先看 `04-任务重校准与线程策略.md`。

## 现在能用到什么

- `./scripts/demo-entry.sh`
  - 只读查看当前状态、最近 proof、是否存在 active mainline，以及锚点真相
- `openspec/archive/<task_id>.md`
  - 回到最近 proof 的 archive 看“刚刚到底证明了什么”
- `workspace/contracts/<task_id>.md`
  - 如果将来再次出现 active mainline，用它看产品边界和验收范围
- `workspace/state/<task_id>/state.json`
  - 如果将来再次出现 active mainline，用它看最新控制面真相
- `workspace/handoffs/` 与 `workspace/closeouts/`
  - 查看最近一个 execution slice 和 archive checkpoint 到底做到哪

## 审计结论

一期已经达到完整的 `phase done`。

更准确地说，一期已经具备下面三类稳定事实：

1. 单一入口已经建立
   - `./scripts/demo-entry.sh`
   - `指挥文档/06-一期PhaseDone审计.md`
2. 项目级协议已经落盘
   - `AGENTS.md`
   - `docs/context-runtime-state-memory.md`
   - `docs/coordination-endpoints.md`
   - `docs/artifact-schemas.md`
   - `docs/git-management.md`
3. phase-2 已经证明可以在不破坏一期入口的前提下继续推进、完成、归档
   - 最近归档 proof task：`dd-hermes-independent-skeptic-dispatch-v1`
   - 当前 active mainline：暂无

## 当前 phase-2 处于什么位置

- 最近归档 proof task：`dd-hermes-independent-skeptic-dispatch-v1`
- 最近归档治理主线：`dd-hermes-successor-triage-v1`
- 当前 active mainline：暂无
- 最新 proof 已完成的事实：
  - `expert-b` 质量位不再只是命名元数据，而是可物化的真实 skeptic lane
  - `dispatch-create` 在 `state_read / context_build / worktree_create` 上都能返回协议化 blocked JSON，而不是 traceback
  - expert execution slice 已通过 review-backed closeout、合并进 `main`，并保持 execution anchor 与 merge commit 分离

## 为什么现在仍然算 `phase done`

### 1. 用户可见入口已经稳定

- 入口脚本在 `main`
- 中文入口页在 `main`
- 不再依赖某条聊天历史解释“现在是什么状态”

### 2. 协议层已经稳定到可继续派发

- `contract + state + context + handoff + worktree` 已经形成稳定协作面
- `dispatch-create`、`thread-switch-gate`、`quality-gate`、`check-artifact-schemas` 已形成闭环
- `tests/smoke.sh all` 能回归验证核心流程

### 3. phase-2 可以在一期基线之上继续，而不是重开一期

- 最近 proof 已归档
- 当前可以在不破坏一期入口的前提下重新选择下一条 active mainline
- 一期本身不需要再返工

## 当前剩余 gap

- 一期无剩余 blocker。
- 当前剩余 gap 全部属于 phase-2 successor 选择：
  - 需要重新做一次 successor triage，判断下一条 bounded task 是否已经有足够 repo evidence
  - 在新 task package 出现之前，入口必须诚实地显示“暂无 active mainline”

## 当前线程应该去哪里继续看

- 如果只是判断“现在能不能用”，停在本页即可。
- 如果要继续开发，直接转到 `04-任务重校准与线程策略.md`。
