# DD Hermes: Git Management

DD Hermes 的多 agent 架构依赖 git 不是为了“版本控制一般论”，而是为了保证指挥线程和执行线程之间有干净的切面。

## Why

- 没有首个 baseline commit，`git worktree` 在真实仓库里无法启动。
- 没有 worktree 生命周期协议，多个 Expert 很容易互相污染文件面。
- 没有提交边界，handoff 很快会失去可审计性。

## Roles

- Lead
  - 维护 baseline commit
  - 创建和回收 Expert worktree
  - 最终集成和验收
- Expert
  - 只在自己的 worktree 内实现
  - 回传 code + handoff + verification
  - 不直接修改主工作区

## Scripts

- `scripts/git-status-report.sh`
  - 报告 repo 是否有 HEAD、当前 branch、脏文件、worktree 列表、是否需要 bootstrap。
- `scripts/git-bootstrap.sh`
  - 在“有 `.git` 但还没有第一个 commit”的仓库里创建 managed baseline commit。
- `scripts/git-snapshot.sh`
  - 输出某个 worktree 的 `HEAD`、branch、upstream、ahead/behind、remote URL 和 dirty 状态。
- `scripts/git-commit-task.sh`
  - 在 execution worktree 内创建任务切片 commit，并把 commit 锚点写回 task state。
- `scripts/git-integrate-task.sh`
  - 将 execution branch 合并回主工作区，形成 integration commit，并把集成后的 git 锚点回写到 task state。
- `scripts/worktree-create.sh`
  - 为某个 Expert 建立隔离 worktree。
- `scripts/worktree-remove.sh`
  - 回收 Expert worktree，并可选删除其 branch。

## Invariants

- `git worktree` 只能建立在已有 baseline commit 的仓库上。
- 指挥线程不直接在 Expert worktree 写实现代码。
- worktree 回收前至少应满足：
  - handoff 已写
  - verification 已写回 state
  - dirty 状态已被审阅

## Commit Boundary

- baseline commit
  - 由 Lead 创建，目标是让 worktree 系统可用。
- execution commit
  - 由 Expert 在自己 worktree 内创建，目标是提交一个可评审切片。
  - 这个 commit 必须回写 `state.git.latest_commit` 一类的版本锚点。
- integration commit
  - 由 Lead 在主工作区合并或整理后创建，目标是把多个 execution slice 集成为一个可验收单元。
  - 标准入口是 `scripts/git-integrate-task.sh`，不是手工 merge 约定。
