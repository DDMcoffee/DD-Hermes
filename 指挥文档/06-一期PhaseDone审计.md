---
phase_status: 一期已经达到完整的 `phase done`；现在就可以使用只读体验入口。
latest_proof_task_id: dd-hermes-demo-entry-v1
latest_proof_archive: openspec/archive/dd-hermes-demo-entry-v1.md
current_mainline_task_id: dd-hermes-anchor-governance-v1
current_mainline_doc: 指挥文档/08-恒定锚点策略.md
current_gap_1: phase-2 还需要把 dd-hermes-anchor-governance-v1 收成 integration/archive 级证据，而不只是 planning + gate 验证。
current_gap_2: phase-2 当前仍是 degraded 监督形态；需要后续任务验证独立质量位是否应当实配。
---

# DD Hermes 一期 Phase Done 审计

## 快速入口

- 第一次看当前体验版状态，先运行 `./scripts/demo-entry.sh`。
- 这页是当前最适合直接阅读的一页：它回答“现在能不能用、能用到什么程度、一期为什么已经完成、下一步是什么”。

## 什么时候能用上 DD Hermes

现在就能用。

但当前能用到的程度，是**只读体验入口级别**：

- 你可以通过 `./scripts/demo-entry.sh` 看到一期当前状态
- 你可以看到最近一次真实 end-to-end 证明
- 你可以看到当前主线任务和剩余 gap

它还不是一个交互式控制台，也不是自动调度器。

## 审计结论

一期已经达到完整的 `phase done`。

更准确地说：

- `体验版本完成`：是。
- `一期完全收口`：是。

原因很直接：最后一层“用户可见入口 + phase 级裁决”已经由 `dd-hermes-demo-entry-v1` 收口并合入 `main`。

## 已经完成的事实

1. `dd-hermes-execution-bootstrap` 已归档。
2. `dd-hermes-endpoint-router-v1` 已完成追溯回填。
3. `dd-hermes-multi-agent-dispatch` 已完成主线收口。
4. `dd-hermes-experience-demo-v1` 已经真实跑通：
   - 有 execution commit
   - 有 integration commit
   - 有 archive
   - 有 task memory
   - 证明了一次真实的 end-to-end 体验闭环已经成立
5. `dd-hermes-demo-entry-v1` 已经完成：
   - 有 execution commit
   - 有 integration commit
   - 有 archive
   - 把体验版真相收成了 `./scripts/demo-entry.sh` 和本页这类单一入口

所以，DD Hermes 不是“快有体验版”，而是“一期体验版本已经收口完成”。

## 为什么现在算 `phase done`

### 1. 单一用户可见入口已经建立

现在已经有：

- `./scripts/demo-entry.sh`
- `指挥文档/06-一期PhaseDone审计.md`
- `openspec/archive/dd-hermes-demo-entry-v1.md`

这说明体验版不仅存在，而且已经有了单一入口和对应的主线收口证据。

### 2. phase 级裁决已经固定成仓库事实

本页 frontmatter 和正文现在明确固定：

- 一期已到 `phase done`
- 最新证明任务是 `dd-hermes-demo-entry-v1`
- 下一条主线不再属于一期，而是已经定义好的 `phase-2` 主线

### 3. 历史体验任务已经收口为单一入口

`dd-hermes-demo-entry-v1` 这条任务原本负责把“一次真实演示闭环”变成用户可见入口。

它现在已经完成了自己的职责：

- 历史任务说明已并入本页
- 当前体验入口脚本直接以本页和 archive 为事实源
- 用户不需要再分别翻 `路线图 + 入口任务说明 + phase 审计` 三页才能看懂当前状态

## 关于 `独立 Skeptic` 的裁决

当前裁决是：

- `独立 Skeptic` 不应成为所有任务的全局默认。
- 但它应成为高风险任务的默认：
  - 架构
  - 控制面
  - 状态机
  - 线程模型
  - 权限 / 安全边界
  - 容易误判完成态的任务

低风险、小边界、只读或局部实现切片，仍然可以使用：

- 单线程
- `Lead + Executor`

只要仓库明确暴露：

- 当前是不是 `independent_skeptic`
- 若不是，是否 `degraded`

这和 `AGENTS.md` 里的策略矩阵是一致的。

## 你现在能用到什么

- `./scripts/demo-entry.sh`
  - 只读查看当前一期状态、最近一次证明和下一条主线
- `openspec/archive/dd-hermes-demo-entry-v1.md`
  - 查看最近一次把体验入口收口成仓库事实的完整证据
- `指挥文档/08-恒定锚点策略.md`
  - 查看 phase-2 当前主线到底在补什么

## 一期已完成，不代表 phase-2 已开工

当前最重要的事实不是“一期还能不能用”，而是：

- 一期已经能用
- phase-2 主线已经定义
- `dd-hermes-anchor-governance-v1` 现在已经有正式 task 工件，并且控制面 gate 已开始落地
- 但它还没有完成 integration/archive 级证明

## 剩余 gap

- 一期无剩余 blocker。
- 剩余 gap 全部属于 phase-2：
  - 把锚点治理从“已落盘并已测试”推进到“已归档并已完成一轮真实主线集成”
  - 决定 `independent_skeptic=false` 的 degraded 现实是否需要在后续任务中升级为独立质量位

## 下一条唯一主线任务

下一条唯一主线已经定义为 `dd-hermes-anchor-governance-v1`。

当前正确表述是：

- 一期已经收口。
- 下一步不是继续补一期，而是把 `Product Anchor` 与 `Quality Anchor` 变成 phase-2 的首个正式能力。
- 重点不是“多开几个 agent”，而是让两个恒定锚点成为任务推进的硬约束。
- 当前这条主线已经建成正式 task 包，并能通过 `dispatch-create` / `thread-switch-gate` 进入实现。

## 审计后的线程策略

- 这个线程继续作为唯一主线程。
- 默认仍然是单线程角色切换 + 按需隔离 worktree。
- 不开第二个并跑主线线程。
- 下一步先做 `phase-2` 目标定义，再决定是否需要新的实现任务。
