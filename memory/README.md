# Memory Model

本仓库把记忆建模为可治理对象，而不是摘要堆。

## Boundary

- `memory/`: 跨会话、可治理、可冲突保留的长期知识。
- `workspace/state/`: 任务级短期控制状态，不进入长期知识库。
- `workspace/state/<task_id>/context.json`: 为某次执行装配的上下文包，可随时重建。
- `runtime`: 当前执行面能力快照，只能观测，不能直接当 policy 或 memory 写回。

## Object Kinds

- `user`
- `task`
- `world`
- `self`

## Required Frontmatter

- `id`
- `type`
- `content`
- `source`
- `scope`
- `confidence`
- `created_at`
- `last_validated_at`
- `decay_policy`
- `status`

## Journal

`memory/journal/*.jsonl` 是 append-only 事件流，用来保存 provenance、冲突、修正和衰减记录。

## Views

`scripts/memory-refresh-views.sh` 会根据记忆卡和 journal 刷新：

- `memory/views/index.md`
- `memory/views/active.md`
- `memory/views/conflicts.md`
- `memory/views/expired.md`
