# OpenSpec Lifecycle

本仓库把 OpenSpec 作为 proposal -> design -> task -> archive 的执行协议。

## Directories

- `openspec/proposals/`: 提案
- `openspec/designs/`: 设计
- `openspec/tasks/`: 执行任务
- `openspec/archive/`: 归档

## Required Fields

所有 OpenSpec 文档都必须保留：

- `status`
- `owner`
- `scope`
- `decision_log`
- `checks`
- `links`

提案模板还必须固定：

- `What`
- `Why`
- `Non-goals`
- `Acceptance`
- `Verification`

## Relationship With Templates

- `.codex/templates/OPENSPEC-*.md` 是 agent-facing 模板
- `openspec/*.template.md` 是 repo-facing 可复制模板

