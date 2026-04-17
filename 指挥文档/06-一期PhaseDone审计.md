---
phase_status: 一期已经达到完整的 `phase done`；现在可以直接使用 DD Hermes harness 的只读入口与任务控制面。
latest_proof_task_id: dd-hermes-legacy-archive-normalization-v1
latest_proof_archive: openspec/archive/dd-hermes-legacy-archive-normalization-v1.md
current_mainline_task_id: dd-hermes-independent-skeptic-dispatch-v1
current_mainline_doc: workspace/contracts/dd-hermes-independent-skeptic-dispatch-v1.md
current_gap_1: 当前 active mainline 已切到 `dd-hermes-independent-skeptic-dispatch-v1`；它负责把真实独立 skeptic 从命名真相推进到可派发、可审查、可验收的运行面。
current_gap_2: 当前 active mainline 已经进入 execution-ready：`expert-a` executor lane 和 `expert-b` skeptic lane 都已 materialize，execution gate 已通过。剩余 blocker 已收口成真实 execution commit、独立质量复核和 closeout/archive 证据。
---

# DD Hermes 一期 Phase Done 审计

## 快速判断

- 现在就能用 DD Hermes。
- 当前能用到的程度，是 harness / 控制面级别，而不是新的 runtime 或自动调度器。
- 如果要继续开发，不要把这页当 task tracker；当前主线与下一步请转到 `04-任务重校准与线程策略.md`。

## 什么时候能用上 DD Hermes

现在就能用。

但当前能用到的程度，是**只读体验入口级别**：

- 你可以通过 `./scripts/demo-entry.sh` 看到一期当前状态
- 你可以看到最近一次真实 end-to-end 证明
- 你可以看到当前主线任务和剩余 gap

它还不是一个新的交互式控制台，也不是自动调度器。

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
3. phase-2 已经可以在不破坏一期入口的前提下继续推进
  - 最近归档 proof task：`dd-hermes-legacy-archive-normalization-v1`
  - 当前 active mainline：`dd-hermes-independent-skeptic-dispatch-v1`

## 你现在能用到什么

- `./scripts/demo-entry.sh`
  - 只读查看当前状态、最近 proof、是否存在当前 mainline，以及锚点真相
- `workspace/contracts/<task_id>.md`
  - 查看当前 active mainline 的产品边界和验收范围
- `workspace/state/<task_id>/state.json`
  - 查看当前 active mainline 的最新控制面真相
- `openspec/archive/<task_id>.md`
  - 回到最近 proof 的 archive 看“刚刚到底证明了什么、为什么会切到当前治理主线”
- `workspace/handoffs/` 与 `workspace/closeouts/`
  - 查看最近一个 execution slice 或 archive checkpoint 到底做到哪

## 当前 phase-2 处于什么位置

- 最近归档 proof task：`dd-hermes-legacy-archive-normalization-v1`
- 最近归档治理主线：`dd-hermes-successor-triage-v1`
- 当前 active mainline：`dd-hermes-independent-skeptic-dispatch-v1`
- 最近归档 proof 已经完成 no-execution closeout semantics、legacy archived proof 的 schema-v2 contract/state/closeout truth 回填，以及 execution-anchor-backed archive 收口
- 当前真正剩下的不是 proof 补洞，而是把已经物化的 `expert-a / expert-b` lanes 推进成这条 task 自己的 execution commit、独立质量复核和 closeout/archive 证据

## 一期为什么现在算 `phase done`

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
- 当前剩余 gap 全部属于 phase-2：
  - 当前 active mainline 已经拥有自己的 `expert-a` / `expert-b` 运行中 lanes，但还没有 expert execution commit
  - `expert-b` 作为独立质量位已就绪，但还没有真实 quality review 结论与 closeout 证据

## 当前线程应该去哪里继续看

- 如果只是判断“现在能不能用”，停在本页即可。
- 如果要继续开发，直接转到 `04-任务重校准与线程策略.md`。
