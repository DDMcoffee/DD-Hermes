---
phase_status: 一期已经达到完整的 `phase done`；体验入口和单线程默认模型都已落到 main。
latest_proof_task_id: dd-hermes-demo-entry-v1
latest_proof_archive: openspec/archive/dd-hermes-demo-entry-v1.md
current_mainline_task_id: dd-hermes-anchor-governance-v1
current_mainline_doc: 指挥文档/08-恒定锚点策略.md
current_gap_1: 需要把产品锚点与质量锚点的协议写进 state、dispatch、gate 和 schema。
current_gap_2: 需要验证恒定锚点不会退化成形式化勾选，而是真的约束任务推进。
---

# DD Hermes 一期 Phase Done 审计

## 快速入口

- 第一次看当前体验版状态，先运行 `./scripts/demo-entry.sh`。
- 这页是当前最适合直接阅读的一页：它回答“现在做到哪里了、为什么还没 `phase done`、下一步是什么”。

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
- 下一条主线不再属于一期，而是 `phase-2` 待定义

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

## 剩余 blocker

- 一期无剩余 blocker。
- 下一阶段只有新的规划问题，没有一期遗留问题。

## 下一条唯一主线任务

下一条唯一主线已经定义为 `dd-hermes-anchor-governance-v1`。

当前正确表述是：

- 一期已经收口。
- 下一步不是继续补一期，而是把 `Product Anchor` 与 `Quality Anchor` 变成 phase-2 的首个正式能力。
- 重点不是“多开几个 agent”，而是让两个恒定锚点成为任务推进的硬约束。

## 审计后的线程策略

- 这个线程继续作为唯一主线程。
- 默认仍然是单线程角色切换 + 按需隔离 worktree。
- 不开第二个并跑主线线程。
- 下一步先做 `phase-2` 目标定义，再决定是否需要新的实现任务。
