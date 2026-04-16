# DD Hermes

DD Hermes 是一个 workspace-first 的 Hermes agent harness，用来在 Codex IDE 中组织多 agent 协作、规范约束、上下文工程、状态治理、记忆治理、OpenSpec 生命周期和验证闭环。它兼容 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 的工作区思路，但不重造 Hermes 运行时、消息网关或 provider 层。

## 体验入口

- 先运行：`./scripts/demo-entry.sh`
- 它会直接显示当前 `Product Anchor / Quality Anchor / degraded ack` 真相。
- 当前最适合直接阅读的一页：`指挥文档/06-一期PhaseDone审计.md`
- 当前线程策略与任务拆分：`指挥文档/04-任务重校准与线程策略.md`
- 下一阶段路线说明：`指挥文档/08-恒定锚点策略.md`
- 当前 phase-2 规划主线：`dd-hermes-independent-quality-seat-v1`
- 上一条已归档主线：`dd-hermes-anchor-governance-v1`
- 对应 archive：`openspec/archive/dd-hermes-anchor-governance-v1.md`

## What This Repo Is

- 面向 Codex IDE 的工程 harness，而不是新的 agent runtime。
- 提供 Lead/Expert 协作模板、hooks、记忆卡模型、OpenSpec 模板和薄脚本。
- 默认工作模式是仓库内工作流优先；后续接 Hermes 外部实例时仍沿用相同协议。
- 默认在同一线程内推进：
  - `Lead / Explorer / Executor / Skeptic / Judge` 是逻辑角色，不是默认分裂出来的聊天线程。
  - 其中有两个恒定锚点：`Product Anchor` 默认映射到 `Supervisor`，`Quality Anchor` 默认映射到 `Skeptic`。
  - 隔离 worktree 仍然保留，但它表示代码隔离，不表示必须切到另一个聊天线程。
  - 当前线程是唯一默认对话面；其他聊天线程只作为系统内部执行面或历史来源，由系统自行管理。

## Out Of Scope

- 不实现新的 CLI 产品。
- 不实现向量数据库、复杂 RAG 或新的模型 provider。
- 不覆盖 Hermes 上游的 gateway、adapter、plugin loader。

## Project Map

- `AGENTS.md`: 主行为规范和模式触发词。
- `CLAUDE.md`: Claude Code 兼容 shim，不是主规范。
- `.codex/skills/`: `spec-first`、`deep-research`、`coding-harness`、`auto-verify`。
- `.codex/templates/`: Sprint、Handoff、Exploration、OpenSpec 模板。
- `hooks/`: 安全门、质量门、线程切换门、类型检查、会话日志、通知适配。
- `docs/coordination-endpoints.md`: 控制面 endpoint 语义和三层终点映射。
- `docs/artifact-schemas.md`: contract/handoff/state/closeout 字段级 schema。
- `docs/context-runtime-state-memory.md`: context / runtime / state / memory 的边界定义。
- `docs/decision-discussion.md`: 3-explorer 决策讨论协议。
- `docs/git-management.md`: baseline commit、worktree 生命周期和提交边界。
- `docs/textbook-agent.md`: 教材记录 agent 的职责和每日总结结构。
- `指挥文档/`: 给指挥线程和项目负责人看的中文目标、终点和执行收尾文档。
  - 目录长期限制为 `7` 份 Markdown 以内。
  - `06-一期PhaseDone审计.md` 是当前单一体验入口说明。
  - `04-任务重校准与线程策略.md` 记录当前主线、线程裁决和任务拆分。
  - `08-恒定锚点策略.md` 固定产品锚点与质量锚点的职责、触发点和降级规则。
  - `./scripts/demo-entry.sh` 会把这些事实收成一个只读体验入口。
- `memory/`: 记忆卡、journal 和人类可读视图。
- `openspec/`: proposal/design/task/archive 生命周期目录和模板。
- `scripts/`: worktree、context/runtime/state、记忆读写、spec 检查、验证编排。
- `tests/`: smoke tests。

## Core Workflows

1. 用 `scripts/sprint-init.sh` 初始化一次 Sprint。
2. 用 `scripts/state-read.sh` / `scripts/state-update.sh` 推进任务级短期状态，而不是污染长期记忆；其中 `product` 与 `quality` 字段是恒定锚点的真实落盘位置。
3. 用 `scripts/context-build.sh` 生成任务 context packet，供当前线程进入实现阶段前消费。
4. 用 `scripts/dispatch-create.sh` 把 `Supervisor` / `Executor` / `Skeptic` 角色物化为实际 assignment，并把 `Product Anchor / Quality Anchor` 作为常驻席位暴露出来；若 `Skeptic` 不独立，输出必须显式标记降级。
5. 用 `scripts/coordination-endpoint.sh` 统一调用 `state.read/state.update/context.build/dispatch.create/closeout.check`，避免在编排层直接分散拼接子脚本。
6. 在实现前运行 `scripts/spec-first.sh` 确认是否必须先写 spec。
7. 用 `scripts/memory-write.sh` / `scripts/memory-manage.sh` 维护记忆卡和 journal，并用 `scripts/memory-refresh-views.sh` 刷新视图。
8. 用 `scripts/verify-loop.sh` 驱动技术层与用户层验证。
9. 用 `scripts/decision-init.sh` 建立 3-explorer 决策讨论包，再由主线程收敛。
10. 涉及架构/控制面/线程模型的任务，初始化时应优先进入 `3-explorer-then-execute`，不要靠人工补切。
11. 用 `scripts/execution-thread-prompt.sh` 生成当前线程进入实现阶段时的检查清单；它是兼容入口，不再默认表示新开聊天线程。
12. 用 `scripts/textbook-record.sh` 记录教材条目，用 `scripts/textbook-summary.sh` 生成日总结草稿。
13. 用 `scripts/check-artifact-schemas.sh` 校验 contract/handoff/state/closeout 必填字段。
14. 用 `scripts/git-integrate-task.sh` 合并执行分支回主分支，含 pre-check（handoff / verification / dirty）和 state 回写。
15. 用 `scripts/lease-check.sh` 检查任务 lease 是否超时，支持 `--auto-pause` 自动暂停。
16. 用 `scripts/session-analytics.sh` 分析会话日志，统计工具使用、错误频率、碎片化得分，自动建议 KB 条目。
17. 用 `scripts/memory-decay-schedule.sh` 扫描超龄记忆卡并执行 confidence 衰减。
18. 用 `hooks/thread-switch-gate.sh` 在进入实现阶段前检查 synthesis 是否完成且具有真实执行边界、lease 是否暂停、executor 是否分配。
19. 用 `tests/smoke.sh` 验证 hooks、workflow、dispatch、endpoint、discussion、context/state、memory 和 verify gate 的闭环。

## Git Management

- 用 `scripts/git-status-report.sh` 判断当前 repo 是否已有 baseline commit、是否可安全派发 worktree。
- 用 `scripts/git-bootstrap.sh` 生成首个 managed baseline commit；没有这个 commit，真实仓库里的 `git worktree` 流程不能启动。
- 用 `scripts/git-snapshot.sh` 统一输出当前 worktree 的 branch / HEAD / upstream / remote / dirty 真相。
- 用 `scripts/git-commit-task.sh` 把当前实现切片的改动收口成 execution commit，并把 commit 锚点写回 task state。
- 用 `scripts/git-integrate-task.sh` 将执行分支合并回主分支（integration commit），并更新 state。
- 用 `scripts/worktree-create.sh` / `scripts/worktree-remove.sh` 管理 Expert worktree 生命周期。
- 用 `scripts/dispatch-create.sh` 从 `state.team` 派发多角色 assignment，并为 executor 物化 worktree；同时暴露 `independent_skeptic` / `role_conflicts` 真相，避免“名义三角色、实际同一人兼岗”。
- 当前线程负责基线、分支和验收边界；代码改动仍然只在自己的 worktree 内提交。

## Thread Model

- 当前主线程同时承担规划、实现、复核和验收，但通过 `Lead / Explorer / Executor / Skeptic / Judge` 的角色切换保持职责分离。
- 两个恒定锚点不靠长寿命子 agent 维持，而靠 `contract + state + context + gate` 四层显式工件维持：
  - `Product Anchor` 负责目标、用户价值、非目标和漂移校准。
  - `Quality Anchor` 负责架构一致性、错误处理、性能、安全和证据缺口的最终审查。
- 隔离 worktree 是数据面隔离，不是聊天线程隔离；代码改动仍优先发生在 worktree 中。
- 多 agent 并行不是靠聊天历史隐式维持，而是靠 `contract + state + context + worktree` 这四类显式工件维持。
- 长任务通过 `state.lease` 建模：目标、运行窗口、暂停原因、恢复时间点都写进 state，而不是塞进聊天历史。
- 涉及架构或方向性选择时，默认先走 `3-explorer-then-execute`：先多视角收敛，再在当前线程内进入实现。

## Verification

- `tests/smoke.sh`
- `scripts/test-artifact-schemas.sh`
- `scripts/test-coordination-endpoint.sh`
- `scripts/test-hooks.sh`
- `scripts/test-memory.sh`
- `scripts/test-workflow.sh`
- `scripts/test-verify-loop.sh`

## Related Docs

- `docs/context-runtime-state-memory.md`
- `docs/decision-discussion.md`
- `docs/git-management.md`
- `docs/textbook-agent.md`
- `docs/long-term-agent-division.md`
- `memory 哲学二.md`
- `openspec/README.md`
- `.codex/skills/*/SKILL.md`
