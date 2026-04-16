---
id: user-pref-single-command-thread
type: preference
content: 用户只在当前主线程对话，其他聊天线程由系统自行生成、管理、吸收和关闭；不要求用户手动管理线程。
source: user-directive-2026-04-17
scope: thread-management
confidence: 1.0
created_at: 2026-04-17T00:00:00Z
last_validated_at: 2026-04-17T00:00:00Z
decay_policy: manual-review
status: active
---

# User Preference

## Context

- 用户要求以后只在当前线程对话。
- 其他线程可以由系统内部创建、吸收知识、处理并关闭。

## Implication

- 指挥线程默认保持唯一对话面。
- 外部线程只作为执行面或历史来源，不再要求用户参与管理。
