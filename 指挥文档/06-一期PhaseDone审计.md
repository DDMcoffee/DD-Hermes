---
phase_status: 一期已经达到完整的 `phase done`；现在可以直接使用 DD Hermes harness 的只读入口与任务控制面。
latest_proof_task_id: dd-hermes-successor-evidence-audit-v1
latest_proof_archive: openspec/archive/dd-hermes-successor-evidence-audit-v1.md
current_mainline_task_id:
current_mainline_doc:
current_gap_1: 最近 proof 已更新为 `dd-hermes-successor-evidence-audit-v1`；它已经把 successor evidence discrimination 收口成 review-backed、integration-backed 的 endpoint / entry truth。
current_gap_2: 最新治理 slice `dd-hermes-residue-remediation-hints-v1` 已归档；当前仍无 active mainline，但 residue 的建议动作已经进入控制面，下一步只剩明确处理 `review-policy-demo` 或等待新的 committed task package。
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
   - 最近归档 proof task：`dd-hermes-successor-evidence-audit-v1`
   - 当前 active mainline：暂无

## 当前 phase-2 处于什么位置

- 最近归档 proof task：`dd-hermes-successor-evidence-audit-v1`
- 最近归档治理主线：`dd-hermes-residue-remediation-hints-v1`
- 当前 active mainline：暂无
- 最新 proof 已完成的事实：
  - `successor.audit` 已经把 committed live candidates、archived proof history 和 working-tree residue 的区分做成共享 endpoint
  - `demo-entry` 已能消费这份 audit truth，不再只靠手工 repo sweep 解释“为什么现在没有主线”
  - expert execution slice 已通过 review-backed closeout、合并进 `main`，并保持 execution anchor `897a0d58f462ff7c4525e414682f037e023ac839` 与 integration commit `67d50f80fb8e4f8fa937e6eeaf772e4763c1b231` 分离

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
- 当前没有 active phase-2 主线。
- 最新治理 slice `dd-hermes-residue-remediation-hints-v1` 已经让 residue 的建议动作进入 endpoint / entry truth。
- 下一步如果还要继续开发，必须先处理剩余 residue 或出现新的 bounded task package：
  - 只有 repo evidence 明确支持一个新 bounded task package 时，才能再次写入 `current_mainline_task_id`
  - 在新主线出现前，不应该回到手工 repo sweep、聊天记忆驱动的 successor 裁决，或把 residue 误记成 live candidate

## 当前线程应该去哪里继续看

- 如果只是判断“现在能不能用”，停在本页即可。
- 如果要继续开发，直接转到 `04-任务重校准与线程策略.md`。
