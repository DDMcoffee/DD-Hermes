# DD Hermes 协作规范

## Priority Order

1. 任务完成标准：结构、脚本和模板必须可运行、可检查、可复用。
2. 仓库既有模式：优先复用本仓库的模板、memory 模型和 hooks 接口。
3. 用户明确指令：无歧义时直接执行，不把可逆工程判断上抛。

## IMPACT 框架

- `Intent`: 先确认任务目标、成功标准、非目标。
- `Memory`: 先读需要的约束和上下文记忆，再执行。
- `Policy`: 把权限、安全和不可违反边界放在 memory 外层治理。
- `Action`: 先规划再编码；3 个以上文件改动先写 spec。
- `Check`: 技术层验证和用户层验证都要过。
- `Trace`: 重要决策、探索证据、handoff、session 统计都要落盘。

## Behavior Rules

- 中文优先。
- MCP 或本地事实源优先，避免凭记忆猜仓库状态。
- 先规划再编码；探索模式和开发模式必须显式切换。
- Lead 负责规划、拆分、验收、记忆升降级决策。
- Expert 负责在独立 worktree 中实现，不在主工作区直接混写。
- 指挥线程维护 `contract + state + context`，执行线程消费这些工件并产出 code + handoff + verification。
- `state` 只保存短期控制面，`memory` 只保存跨会话知识；两者不能互相替代。

## Dangerous Ops

- 默认拦截 `rm -rf`、`git push --force`、`DROP`、`TRUNCATE`、`.env` 写入、`chmod 777`。
- 推送前必须先确认目标 remote。
- `constraint` 记忆只允许引用和验证，不允许通过 memory 流程改写 policy。

## Coordination Rules

- 每个 Sprint 必须绑定一个 contract、至少一个 handoff 和至少一个 exploration log。
- 每个活跃任务还必须有一个 `workspace/state/<task_id>/state.json`，由指挥线程推进。
- `BLOCKED` 是有效探索结果，不视为失败。
- handoff 必须写清 scope、已决策事项、风险和下一步检查。
- workspace 产物只做运行时协作，不替代长期知识库。

## Git Rules

- 真实仓库在创建 Expert worktree 前必须先有一个 baseline commit。
- Lead 负责 baseline commit、worktree 生命周期和最终集成边界。
- Expert 只在自己的 worktree 上提交，不直接污染主工作区。
- worktree 回收前必须确认 handoff 和 verification 已落盘。

## Truth Sources

- `AGENTS.md` / `CLAUDE.md`
- `.codex/templates/`
- `openspec/`
- `memory/`
- `docs/context-runtime-state-memory.md`
- `docs/git-management.md`
- `workspace/contracts/` 与 `workspace/handoffs/`
- `workspace/state/`

## Escalation Rules

- 路径不存在时不静默创造业务路径；基础仓库骨架除外。
- 涉及删除、推送、权限升级、敏感文件写入时必须走 guard。
- 如果事实不明确，优先读取本地文档和状态文件，再考虑外部信息源。
