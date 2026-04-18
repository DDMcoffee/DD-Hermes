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
- `Product Anchor` 是恒定席位，默认映射到 `Supervisor`：负责把模糊需求压成清晰任务，持续校准 `product_goal / user_value / non_goals`，防止开发任务偏离 DD Hermes 北极星。
- Expert 负责在独立 worktree 中实现，不在主工作区直接混写。
- `Quality Anchor` 是恒定席位，默认映射到 `Skeptic`：负责架构一致性、命名、错误处理、性能、安全和证据缺口的最后审查，并给出改进建议与参考范例。
- 默认不再拆成两个聊天线程；由当前线程统一维护 `contract + state + context`，并在同一线程内切换 `Lead / Explorer / Executor / Skeptic` 角色推进实现与验收。
- 当前线程是唯一默认对话面；其他聊天线程只作为系统内部执行面或历史来源存在，由系统自行生成、吸收、关闭，不要求用户手动管理。
- `state` 只保存短期控制面，`memory` 只保存跨会话知识；两者不能互相替代。
- 架构性问题默认先走 `3-explorer-then-execute`，先收三份不同视角结论，再由主线程归并裁决。

## Dangerous Ops

- 默认拦截 `rm -rf`、`git push --force`、`DROP`、`TRUNCATE`、`.env` 写入、`chmod 777`。
- 推送前必须先确认目标 remote。
- `constraint` 记忆只允许引用和验证，不允许通过 memory 流程改写 policy。

## Self-Reference Ops

任何新 proposal / contract 若主题是 DD Hermes 自身 harness 能力（runtime / router / dispatch / memory runtime / 新脚本 / 新协议 / 新 schema 等），默认触发如下硬规则：

- 必须附 `provable_need` 字段：引用当前真实 slice 的 file path 与观测到的具体瓶颈。
- 缺 `provable_need` 或来源只是“为了控制面更整齐 / 为了 harness 更自洽” → 自动降级 `deferred`，不得进 mainline。
- harness 自指 slice 不得占用 mainline，除非已立的真实 slice 里有直接依赖。
- `deferred` 条目每季度回顾一次，仍无 `provable_need` → 归档为 `wont-fix`。
- Product Anchor 在没有 active mainline 时主动写 PRD / RICE / Epic 视为漂移征兆，必须立即叫停并记入 `memory/journal/` 的漂移事件流。
- 此段与 `Truth Sources` 里的 `AGENTS.md` 治理层级同级，`memory/task/*` 不得无规划地重启 harness 自指条目。

## Coordination Rules

- 每个 S2/S3 Sprint 必须绑定一个 contract、至少一个 handoff 和至少一个 exploration log；S0/S1 按下方 `Task Size Gradation` 宽松规则。
- 每个活跃任务必须有 `workspace/state/<task_id>/state.json`，由指挥线程推进；S0 可简化为只记录 `last_commit` 一行 log。
- 每个 S2/S3 新任务默认都要声明 `product_goal / user_value / non_goals / drift_risk`，并把产品锚点与质量锚点写进 state；S0/S1 可省略（但任务若属于已立 mainline 的子切片，仍受父 mainline 的同套声明约束）。
- `BLOCKED` 是有效探索结果，不视为失败。
- handoff 必须写清 scope、已决策事项、风险和下一步检查；S0/S1 可省略 handoff。
- workspace 产物只做运行时协作，不替代长期知识库。
- S2/S3 进入实现阶段前，必须至少有 `contract + state + context + handoff + worktree`；S1 可省略 handoff 与 exploration；S0 只需 commit + state 一行 log。

## Task Size Gradation

所有新任务的 `contract`（或 S0 的 state.json）必须显式声明 `size`；默认禁止直接用 S2，需在 contract 写一句理由说明为何不是更低级别。

- **S0 chore**：改一行注释、拼写、rename 类微改动。
  - 必选：`git commit` + `state-update` 一行 log
  - 可省：contract / handoff / closeout / exploration / archive
- **S1 slice**：单点小功能、小 bug、文档更新。
  - 必选：极简 contract（`id / size / intent / acceptance`）+ `state.json` + `git commit`
  - 可省：handoff / closeout / exploration；archive 做 log append 即可
- **S2 task**：标准任务、跨文件、有风险（原默认形态）。
  - 必选：完整 `contract + state + handoff + verification + archive`
  - 可省：3-explorer（除非涉及架构或控制面）
- **S3 phase**：架构、控制面、跨 task、安全边界。
  - 必选：S2 全套 + `3-explorer-then-execute` + 独立 Quality Anchor 视角
  - 可省：无

补充规则：

- `contract` 的 `size` 是硬必填；缺则按 S2 对待并在 `quality-gate.sh` 标红。
- `size` 升级不需额外 exploration；降级需在 state log 里解释“为什么原以为需要更多工件，现在看不需要”。

## Multi-Agent Strategy

- `T0 单线程治理`：只用于治理、裁决、归档、状态回填、文档修订、trace 收口这类不产生 execution slice 的任务。
- `T1 单线程探查`：用于事实不明、需要先核对仓库真相的任务；角色为 `Lead + Explorer`，但仍在同一线程内推进。
- `T2 单线程实现`：用于单一、边界清晰、写集可控的实现切片；前提是 `contract + state + context + handoff + worktree` 已齐备。
- `T3 单线程强校验`：用于架构、策略、控制面、线程模型、权限/安全边界、状态机和高回归风险任务；顺序为 `Product Anchor -> Explorer -> Executor -> Quality Anchor -> Judge`。
- `T4 双证据档`：用于需要两条独立证据链才能证明正确性的任务，例如公共 schema / protocol、并发状态机、跨切片集成、上线前关键路径。
- `Product Anchor` 与 `Quality Anchor` 是恒定席位，不要求长期运行两个子 agent；它们必须作为协议层常驻角色在每轮任务里出现。
- 若 `discussion.policy == 3-explorer-then-execute`，任何执行形态都必须先有 `synthesis_path`，否则不得进入实现阶段。
- 若 `state.team.role_integrity.independent_skeptic == false`，必须显式标记为 `degraded`，不得宣称“已完成独立监督”。
- 若任务只是收口已有能力的 task-bound traceability，优先由当前线程单线程完成，不为文档回填额外开新聊天线程。

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
