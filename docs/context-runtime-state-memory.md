# DD Hermes: Context / Runtime / State / Memory

这四层必须分开建模，否则 agent 很快会把“当前任务控制面”“执行环境事实”和“长期知识”混成一团。

## Definitions

- `runtime`
  - 当前执行面事实快照。
  - 例子：repo root、当前 worktree、git branch、hooks、可用 tests、shell、脏文件。
  - 特征：瞬时、可重算、不能直接定义 policy。
- `state`
  - 当前任务的短期控制面。
  - 例子：当前模式、阻塞原因、最近一次 verification、最新 context packet、最近一次 runtime snapshot。
  - 落盘位置：`workspace/state/<task_id>/state.json` 和 `events.jsonl`
  - 特征：可变、任务级、生命周期短于 memory。
- `context`
  - 某次执行前装配出来的输入包。
  - 来源：contract、handoff、exploration、OpenSpec、state、runtime、相关 memory。
  - 落盘位置：`workspace/state/<task_id>/context.json`
  - 特征：派生物、可丢弃、可重建。
- `memory`
  - 跨会话保留的知识卡。
  - 例子：用户偏好、世界约束、任务教训、自身失误模式。
  - 落盘位置：`memory/{user,task,world,self}/` + `memory/journal/`
  - 特征：治理优先、允许冲突保留、不能被短期 state 覆盖。

## Invariants

- `runtime -> state`
  - runtime 可以更新 state 的观测字段，例如最近 runtime snapshot 路径。
- `state -> context`
  - state 决定当前任务该向执行线程暴露哪些控制信息。
- `memory -> context`
  - memory 通过检索进入 context，但不会被 context 自动改写。
- `policy != memory mutation`
  - policy 约束可以被 memory 引用，但不能通过 memory 写入流程被重写。
- `context != truth`
  - context 是某一时刻的装配结果，不是最终真相源。

## Thread Model

- 指挥线程
  - 负责规划、拆分、验收、state 推进、context 出包。
  - 主要工件：`workspace/contracts/`、`workspace/state/`、`openspec/`
- 执行线程
  - 负责在 worktree 内实现、验证并回传 handoff / exploration / verification。
  - 主要工件：`.worktrees/`、`workspace/handoffs/`、`workspace/exploration/`
- 多 agent 并行
  - 不是依赖聊天历史，而是依赖显式工件同步。
  - 最小同步集合：`contract + state + context + handoff`

## Lease / Pause / Resume

- 长时任务不应该假设单个线程会一直在线。
- `state.lease` 负责记录：
  - `goal`
  - `status`
  - `duration_hours`
  - `started_at`
  - `deadline_at`
  - `paused_at`
  - `pause_reason`
  - `resume_after`
  - `resume_checkpoint`
  - `dispatch_cursor`
- 当宿主报告 Codex 配额命中时，指挥线程只需要把 `lease.status=paused`、`pause_reason=codex_quota`、`resume_after=<next window>` 写回 state。
- 恢复时重新进入指挥线程，读取 state、重建 context、继续派发执行线程，不需要依赖旧聊天上下文仍然完整存在。

## Scripts

- `scripts/runtime-report.sh`
  - 生成执行面能力快照。
- `scripts/state-init.sh`
  - 为任务初始化短期状态。
- `scripts/state-read.sh`
  - 读取状态并返回派生摘要。
- `scripts/state-update.sh`
  - 更新短期状态并记录 state event。
- `scripts/context-build.sh`
  - 组装指挥线程要交给执行线程的 context packet。
- `scripts/memory-refresh-views.sh`
  - 刷新长期知识视图。
