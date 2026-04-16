# DD Hermes: 3-Explorer Decision Discussion

涉及架构、线程模型、长期策略、重大改造时，DD Hermes 默认不直接编码，而是先走 `3-explorer-then-execute`。任务初始化若能从 `task_id`、`current_focus`、contract/proposal 文本里识别出这些信号，就应直接把 state 初始化到讨论模式，而不是依赖人工补切。

## Roles

- `Explorer A: architecture`
  - 看 `context / runtime / state / memory` 的边界、线程切换、暂停/恢复和控制面。
- `Explorer B: delivery`
  - 看 git、worktree、execution commit、integration boundary 和验证闭环。
- `Explorer C: curriculum`
  - 看 memory、观测、经验回收、教材沉淀和长期使用规律。

## Flow

1. 指挥线程运行 `scripts/decision-init.sh --task-id <task_id> --decision-id <decision_id>`。
2. 三个 explorer 分别写入自己的结论卡。
3. 主线程只做归并与裁决，不直接复写 explorer 原文。
4. 归并结果写入 `synthesis.md`，并更新 task state。
5. 只有当 `synthesis.md` 明确了执行边界，才切到 execution thread。

## Required Output Shape

主线程收敛后的 `synthesis.md` 至少要有：

- `Goal`
- `Accepted Path`
- `Rejected Paths`
- `Execution Boundary`
- `Executor Handoff`

## State Contract

`workspace/state/<task_id>/state.json` 里至少维护：

- `discussion.policy`
- `discussion.decision_id`
- `discussion.explorer_queue`
- `discussion.explorer_findings`
- `discussion.synthesis_path`
- `discussion.current_executor`

## Thread Switch Rule

如果 `discussion.policy == 3-explorer-then-execute`，且 `discussion.synthesis_path` 为空，或 synthesis 仍是占位内容，就不应切到 execution thread。
