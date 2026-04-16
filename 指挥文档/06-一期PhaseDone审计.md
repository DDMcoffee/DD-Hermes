# DD Hermes 一期 Phase Done 审计

## 审计结论

一期已经达到“体验版本 v0 已出现”，但还没有达到完整的 `phase done`。

更准确地说：

- `体验版本完成`：是。
- `一期完全收口`：还不是。

原因不是控制面还缺大块能力，而是还差最后一层“用户可见入口 + phase 级裁决”。

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

所以，DD Hermes 不是“快有体验版”，而是“已经有体验版 v0，只是入口还不够清楚”。

## 还没达到 `phase done` 的原因

### 1. 缺少单一用户可见入口

当前体验版真相分散在：

- `README.md`
- `指挥文档/05-体验版本路线图.md`
- `openspec/archive/dd-hermes-experience-demo-v1.md`
- task memory / handoff / closeout / state 痕迹

这说明体验版已经存在，但还没有一个“给人看”的统一入口。

### 2. 缺少 phase 级裁决

现在仓库已经证明：

- 多 agent 可以跑真实任务
- 讨论模式和执行模式能被真实 gate 管住
- task 能从定义一路收成 `done/archive`

但“一期到底什么时候算收口”还没被最后裁决成仓库级共识。需要把下一条主线和剩余 blocker 明确写死，避免又回到无限补脚手架。

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

当前只剩 2 个 phase 级 blocker：

1. 建立一个单一、真实、用户可见的体验入口。
2. 把“一期已达到体验版 v0，但尚未 phase done”的裁决固化为仓库事实。

## 下一条唯一主线任务

下一条唯一主线任务应当是：

- `dd-hermes-demo-entry-v1`

它不是新的控制面扩展，而是把已经证明过的体验版事实做成：

- 一个命令入口
- 一页中文入口说明

## 审计后的线程策略

- 这个线程继续作为唯一指挥线程。
- 下一步只开一个按需 execution thread。
- 不开第二个并跑主线线程。
- `dd-hermes-demo-entry-v1` 完成后，再决定是否已经达到一期 `phase done`。
