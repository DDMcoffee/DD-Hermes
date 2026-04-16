# DD Hermes

DD Hermes 是一个 workspace-first 的 Hermes agent harness，用来在 Codex IDE 中组织多 agent 协作、规范约束、上下文工程、状态治理、记忆治理、OpenSpec 生命周期和验证闭环。它兼容 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 的工作区思路，但不重造 Hermes 运行时、消息网关或 provider 层。

## What This Repo Is

- 面向 Codex IDE 的工程 harness，而不是新的 agent runtime。
- 提供 Lead/Expert 协作模板、hooks、记忆卡模型、OpenSpec 模板和薄脚本。
- 默认工作模式是仓库内工作流优先；后续接 Hermes 外部实例时仍沿用相同协议。
- 支持把线程拆成两类执行面：
  - 指挥线程：负责讨论、规划、验收、状态推进和 context 出包。
  - 执行线程：负责在隔离 worktree 中编码、验证和回传 handoff。

## Out Of Scope

- 不实现新的 CLI 产品。
- 不实现向量数据库、复杂 RAG 或新的模型 provider。
- 不覆盖 Hermes 上游的 gateway、adapter、plugin loader。

## Project Map

- `AGENTS.md`: 主行为规范和模式触发词。
- `CLAUDE.md`: Claude Code 兼容 shim，不是主规范。
- `.codex/skills/`: `spec-first`、`deep-research`、`coding-harness`、`auto-verify`。
- `.codex/templates/`: Sprint、Handoff、Exploration、OpenSpec 模板。
- `hooks/`: 安全门、质量门、类型检查、会话日志、通知适配。
- `docs/context-runtime-state-memory.md`: context / runtime / state / memory 的边界定义。
- `docs/git-management.md`: baseline commit、worktree 生命周期和提交边界。
- `memory/`: 记忆卡、journal 和人类可读视图。
- `openspec/`: proposal/design/task/archive 生命周期目录和模板。
- `scripts/`: worktree、context/runtime/state、记忆读写、spec 检查、验证编排。
- `tests/`: smoke tests。

## Core Workflows

1. 用 `scripts/sprint-init.sh` 初始化一次 Sprint。
2. 用 `scripts/state-read.sh` / `scripts/state-update.sh` 推进任务级短期状态，而不是污染长期记忆。
3. 用 `scripts/context-build.sh` 在指挥线程生成任务 context packet，供执行线程消费。
4. 用 `scripts/dispatch-create.sh` 把 `Supervisor` / `Executor` / `Skeptic` 角色物化为实际 assignment，并为 executor 建立或确认隔离 worktree。
5. 在实现前运行 `scripts/spec-first.sh` 确认是否必须先写 spec。
6. 用 `scripts/memory-write.sh` / `scripts/memory-manage.sh` 维护记忆卡和 journal，并用 `scripts/memory-refresh-views.sh` 刷新视图。
7. 用 `scripts/verify-loop.sh` 驱动技术层与用户层验证。
8. 用 `tests/smoke.sh` 验证 hooks、workflow、dispatch、context/state、memory 和 verify gate 的闭环。

## Git Management

- 用 `scripts/git-status-report.sh` 判断当前 repo 是否已有 baseline commit、是否可安全派发 worktree。
- 用 `scripts/git-bootstrap.sh` 生成首个 managed baseline commit；没有这个 commit，真实仓库里的 `git worktree` 流程不能启动。
- 用 `scripts/git-snapshot.sh` 统一输出当前 worktree 的 branch / HEAD / upstream / remote / dirty 真相。
- 用 `scripts/git-commit-task.sh` 把执行线程的改动收口成 execution commit，并把 commit 锚点写回 task state。
- 用 `scripts/worktree-create.sh` / `scripts/worktree-remove.sh` 管理 Expert worktree 生命周期。
- 用 `scripts/dispatch-create.sh` 从 `state.team` 派发多角色 assignment，并为 executor 物化 worktree。
- 指挥线程只负责基线、分支和验收边界；执行线程只在自己的 worktree 内提交。

## Thread Model

- 指挥线程是控制面：维护 `workspace/contracts/`、`workspace/state/`、`openspec/` 和最终验收标准。
- 执行线程是数据面：消费 `workspace/state/<task_id>/context.json`，在隔离 worktree 中编码并把结果写回 handoff / exploration / verification。
- 多 agent 并行不是靠聊天历史隐式维持，而是靠 `contract + state + context + worktree` 这四类显式工件维持。
- 长任务通过 `state.lease` 建模：目标、运行窗口、暂停原因、恢复时间点都写进 state，而不是塞进聊天历史。

## Verification

- `tests/smoke.sh`
- `scripts/test-hooks.sh`
- `scripts/test-memory.sh`
- `scripts/test-workflow.sh`
- `scripts/test-verify-loop.sh`

## Related Docs

- `docs/context-runtime-state-memory.md`
- `docs/git-management.md`
- `docs/long-term-agent-division.md`
- `memory 哲学二.md`
- `openspec/README.md`
- `.codex/skills/*/SKILL.md`
