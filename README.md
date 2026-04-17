# DD Hermes

DD Hermes 是一个 workspace-first 的 Hermes agent harness，用来在 Codex IDE 中组织多 agent 协作、上下文工程、状态治理、记忆治理、OpenSpec 生命周期和验证闭环。它兼容 [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) 的工作区思路，但不重造 Hermes 运行时、消息网关或 provider 层。

## 项目哲学

- harness 哲学
  - DD Hermes 是工程 harness，不是新的 agent runtime、CLI 产品或调度器。
- memory 哲学
  - `memory/` 只保存跨会话长期知识；当前任务控制面留在 `workspace/state/`，不能把摘要堆误当 memory 系统。
- Markdown 哲学
  - 关键判断、边界、handoff、验收和 closeout 必须落成仓库内可审计的 Markdown / JSON 工件，不能只留在聊天里。
- Hermes agent 哲学
  - 对用户只暴露一个主线程；对内通过 `Lead / Explorer / Executor / Skeptic / Judge` 角色切换、按需 worktree 和显式工件同步推进。
- 对抗式思辨哲学
  - 复杂问题先讨论再执行，默认保留反证位；不能让同一条实现链路自己定义目标、自己证明正确、自己宣布完成。

## 从头到尾落地链路

1. 先定哲学和边界
   - 读 `指挥文档/01-项目目标对齐.md`
   - 读 `指挥文档/09-今日输入整理.md`
   - 读 `docs/context-runtime-state-memory.md`
2. 再定当前主线和 gap
   - 运行 `./scripts/demo-entry.sh`
   - 读 `指挥文档/06-一期PhaseDone审计.md`
   - 读 `指挥文档/04-任务重校准与线程策略.md`
3. 再做对抗式规划
   - 架构、控制面、高回归风险任务先走 `3-explorer-then-execute`
   - accepted path 必须落成 `synthesis + contract + state + handoff`
4. 最后才进入执行
   - 以 bounded slice 进入 worktree / handoff / verification
   - 先做到 `execution slice done`，再谈 `task done` 或 `phase done`
5. 最后收口
   - 回写 closeout、state、验证证据和 archive / next-mainline 决策

## 继续开发入口

- 先运行：`./scripts/demo-entry.sh`
- `demo-entry.sh` 是唯一运行态入口；当前 mainline、最近 proof 和锚点真相都以它的输出为准。
- 如果当前没有 active mainline，入口必须直接说“暂无”，而不是伪造一个后续任务。
- 阅读顺序固定为：
  1. `指挥文档/06-一期PhaseDone审计.md`
  2. `指挥文档/04-任务重校准与线程策略.md`
  3. 如果存在 `current_mainline_task_id`，再读 `workspace/contracts/<current_mainline_task_id>.md`
  4. 如果存在 `current_mainline_task_id`，再读 `workspace/state/<current_mainline_task_id>/state.json`
  5. 如果存在 `current_mainline_task_id`，再读 `workspace/handoffs/<current_mainline_task_id>-lead-to-<expert>.md`
- 如果当前没有 active mainline，就回到最近 proof 的 `openspec/archive/*` 和 `04-任务重校准与线程策略.md` 来决定下一条窄主线。
- 如果当前 mainline 已经有 execution slice，再读 `workspace/handoffs/<current_mainline_task_id>-expert-to-lead.md` 和 `workspace/closeouts/<current_mainline_task_id>-<expert>.md`。

## 仓库边界

- 面向 Codex IDE 的工程 harness，而不是新的 agent runtime。
- 提供 `Lead / Explorer / Executor / Skeptic / Judge` 角色协议、hooks、记忆卡模型、OpenSpec 模板和薄脚本。
- 默认工作模式是仓库内工作流优先；后续接 Hermes 外部实例时仍沿用相同协议。
- 默认是单线程角色切换；worktree 代表代码隔离，不代表必须新开聊天线程。

## 明确不做

- 不实现新的 CLI 产品。
- 不实现向量数据库、复杂 RAG 或新的模型 provider。
- 不覆盖 Hermes 上游的 gateway、adapter、plugin loader。

## 文档分层

- `AGENTS.md`
  - 当前最高优先级的协作规范与任务策略。
- `指挥文档/`
  - 给当前主线程和项目负责人看的中文入口；优先回答哲学、规划和当前主线。
  - 长期限制为 `7` 个 Markdown 文件以内。
- `docs/`
  - 稳定协议文档，只写长期有效的控制面规则。
- `workspace/` + `openspec/`
  - 任务级真相源，当前做到哪、谁负责、下一步是什么，都在这里。
- `memory/`
  - 跨会话长期知识，不承载任务短期控制面。

## 当前只需要常看的协议文档

- `docs/context-runtime-state-memory.md`
- `docs/coordination-endpoints.md`
- `docs/artifact-schemas.md`
- `docs/git-management.md`

## 常用命令

- `./scripts/demo-entry.sh`
- `./scripts/state-read.sh --task-id <task_id>`
- `./scripts/context-build.sh --task-id <task_id> --agent-role commander`
- `./scripts/dispatch-create.sh --task-id <task_id>`
- `./scripts/check-artifact-schemas.sh --task-id <task_id>`
- `./hooks/thread-switch-gate.sh --task-id <task_id> --target execution`
- `./hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json`
- `bash tests/smoke.sh all`

## 当前不建议先读的文件

- `docs/long-term-agent-division.md`
  - 分工背景文档，不是当前主线状态源。
- `docs/textbook-agent.md`
  - 教材/记录辅助文档，不是继续开发主入口。
- `openspec/archive/*`
  - 归档 proof 与历史任务证据；只有在当前没有 active mainline 时，才把它当成继续开发的起点之一。
