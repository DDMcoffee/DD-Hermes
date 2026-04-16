# Claude Code Compatibility Shim

这个仓库的主规范文件是 `AGENTS.md`，不是 `CLAUDE.md`。

保留本文件只有一个目的：

- 给未来可能接入的 Claude Code / Claude-style 工作流一个兼容入口
- 避免把 Claude 相关约定完全散落到别处

## What This File Does

- 不提供离线能力
- 不解决认证、订阅或账号过期问题
- 不替代 `AGENTS.md`

## Source Of Truth

请优先读取：

1. `AGENTS.md`
2. `.codex/skills/*/SKILL.md`
3. `.codex/templates/`
4. `openspec/`
5. `memory/`

## Minimal Claude Mapping

- 探索模式 / 开发模式：按 `AGENTS.md` 的工作流执行
- 先规划再编码：按 `spec-first` 和 OpenSpec 生命周期执行
- 多 agent 协作：按 Sprint Contract、Handoff、worktree 约定执行
- 记忆治理：按 `write -> manage -> read` 闭环执行
- 验证闭环：按 `auto-verify` 和 `hooks/quality-gate.sh` 执行

## Authentication Reality

如果你本机安装了 Claude Code CLI，但 Claude.ai 订阅已过期，那么这个文件本身不会让它继续可用。Claude Code 是否能运行，取决于 CLI 当前是否还能通过有效认证访问 Anthropic 模型：

- 有效的 Claude.ai Pro / Max 登录
- 或有效的 Anthropic Console API key / billing
- 或企业侧 Bedrock / Vertex 配置

没有这些，`CLAUDE.md` 只是兼容文档，不是可执行能力。
