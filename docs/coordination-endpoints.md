# DD Hermes Coordination Endpoints (v1)

本文档把 `指挥文档/02-三层终点定义.md` 落成可执行的 endpoint/schema 约定；实现阶段的进入条件与停止条件也已经并入该页。

## 三层终点映射

- `execution slice done`
  - Expert 在隔离 worktree 产出 execution commit。
  - 回写 expert handoff、verification 证据和 state git 锚点。
- `task done`
  - Lead 完成 integration commit，并通过任务级验收。
  - state 切到 `done`，且可追溯到 integration 证据。
- `project phase done`
  - OpenSpec 与项目目标文档收口，阶段边界和完成标准明确。
  - 不再是“脚手架存在”，而是“阶段契约已验证”。

## Endpoint Surface

DD Hermes 当前用脚本表达 endpoint，等价于以下控制面接口。
统一入口脚本：`scripts/coordination-endpoint.sh --endpoint <name> --task-id <task_id>`。

### 1) `state.read`

- Router entry: `scripts/coordination-endpoint.sh --endpoint state.read --task-id <task_id>`
- Implementation: `scripts/state-read.sh --task-id <task_id>`
- Purpose: 读取任务控制面与派生摘要。
- Response required fields:
  - `state`
  - `summary`
  - `summary.verification_complete`
  - `summary.has_context`
  - `summary.has_runtime_report`
  - `summary.has_supervisor`
  - `summary.independent_skeptic`
  - `summary.quality_seat_mode`
  - `summary.quality_seat_status`
  - `summary.quality_seat_reasons`
  - `summary.degraded_ack_ready`
  - `summary.role_conflicts`
  - `summary.product_gate_ready`
  - `summary.quality_review_ready`

### 2) `state.update`

- Router entry: `scripts/coordination-endpoint.sh --endpoint state.update --task-id <task_id> < payload.json`
- Implementation: `scripts/state-update.sh --task-id <task_id> < payload.json`
- Purpose: 更新控制面并写入 `events.jsonl`。
- Request common fields:
  - `status`, `mode`, `current_focus`, `active_expert`
  - `append_verified_steps`, `append_verified_files`, `last_pass`
  - `commit_sha`, `commit_branch`, `context_path`, `runtime_report_path`
  - `supervisors`, `executors`, `skeptics`

### 3) `context.build`

- Router entry: `scripts/coordination-endpoint.sh --endpoint context.build --task-id <task_id> --agent-role <role>`
- Implementation: `scripts/context-build.sh --task-id <task_id> --agent-role <role>`
- Purpose: 组装执行输入包。
- Response required fields:
  - `context_path`
  - `runtime_path`
  - `state_path`
  - `memory_count`
  - `context_summary.product_gate_ready`
  - `context_summary.quality_anchor_ready`
  - `context_summary.quality_seat_mode`
  - `context_summary.quality_seat_status`
  - `context_summary.degraded_ack_ready`

### 4) `dispatch.create`

- Router entry: `scripts/coordination-endpoint.sh --endpoint dispatch.create --task-id <task_id>`
- Implementation: `scripts/dispatch-create.sh --task-id <task_id>`
- Purpose: 从 `state.team` 物化 supervisor/executor/skeptic assignment。
- Response required fields:
  - `task_id`, `state_path`, `context_path`, `runtime_path`
  - `independent_skeptic`, `degraded`, `degraded_ack_ready`, `role_conflicts`
  - `quality_seat_mode`, `quality_seat_status`, `quality_seat_reasons`
  - `summary.supervisor_count`, `summary.executor_count`, `summary.skeptic_count`
  - `assignments`

### 5) `closeout.check`

- Router entry: `scripts/coordination-endpoint.sh --endpoint closeout.check --task-id <task_id>`
- Implementation: `scripts/check-artifact-schemas.sh --task-id <task_id>`
- Purpose: 校验 `contract/handoff/state/closeout` 必填字段是否完整。
- Response required fields:
  - `task_id`
  - `checked`
  - `artifacts`
  - `errors`
  - `valid`
  - `semantic_valid`
  - `ready_for_execution_slice_done`

### 6) `lease.check`

- Router entry: `scripts/coordination-endpoint.sh --endpoint lease.check --task-id <task_id>`
- Implementation: `scripts/lease-check.sh --task-id <task_id>`
- Purpose: 检查任务 lease 是否超时，并可通过 `AUTO_PAUSE=1` 自动暂停。
- Response required fields:
  - `lease_status`, `exceeded`, `should_pause`
  - `elapsed_minutes`, `remaining_minutes`
  - `active_expert`, `lease_conflict`, `lease_conflict_reason`

### 7) `thread.gate`

- Router entry: `scripts/coordination-endpoint.sh --endpoint thread.gate --task-id <task_id>`
- Implementation: `hooks/thread-switch-gate.sh --task-id <task_id> --target execution`
- Purpose: 线程切换门卫 — 在派发执行线程前检查前置条件。
- Gate checks:
  - `discussion.policy == 3-explorer-then-execute` 时 `synthesis_path` 必须存在
  - `lease.status` 不能是 `paused`
  - `state.team.executors` 不能为空
  - `product gate` 必须完整，不能缺少 `user_value / non_goals / product_acceptance / drift_risk`
  - `quality anchor` 必须已分配
  - 若 `role_integrity.degraded == true`，必须先有显式 `degraded ack`
- Response required fields:
  - `pass`, `target_thread`, `blocked_reason`

### 8) `git.integrate`

- Router entry: `EXPERT=<agent_id> scripts/coordination-endpoint.sh --endpoint git.integrate --task-id <task_id>`
- Implementation: `scripts/git-integrate-task.sh --task-id <task_id> --expert <agent_id>`
- Purpose: 将执行分支合并回主分支（integration commit），含前置检查。
- Pre-checks: handoff 存在、verification.last_pass 为 true、worktree 无脏文件。
- Response required fields:
  - `task_id`, `integrated_branch`, `commit_sha`
  - `pre_check_warnings`, `handoff_found`, `verification_pass`

### 9) `session.analytics`

- Router entry: `scripts/coordination-endpoint.sh --endpoint session.analytics --task-id <any>`
- Implementation: `scripts/session-analytics.sh --days 7`
- Purpose: 分析会话日志，统计工具使用/错误频率/碎片化，自动建议 KB 条目。
- Response required fields:
  - `session_count`, `tool_usage`, `error_frequency`
  - `fragmentation_score`, `kb_suggestions`

### 10) `memory.decay`

- Router entry: `scripts/coordination-endpoint.sh --endpoint memory.decay --task-id <any>`
- Implementation: `scripts/memory-decay-schedule.sh --dry-run`
- Purpose: 扫描超龄记忆卡并报告衰减候选（默认 dry-run 模式）。
- Response required fields:
  - `candidates`, `count`, `max_age_days`

### 11) `journal.compact`

- Router entry: `scripts/coordination-endpoint.sh --endpoint journal.compact --task-id <any>`
- Implementation: `scripts/journal-compact.sh --dry-run`
- Purpose: 将超龄 journal 文件归档到 `memory/journal/archive/`（默认 dry-run）。
- Response required fields:
  - `compacted`, `kept`, `dry_run`

## Closeout Flow

1. `scripts/sprint-init.sh` 初始化 sprint 时，自动生成 `workspace/closeouts/<task_id>-<expert>.md`。
2. Expert 在 execution slice 收尾时补充 closeout 内容、提交 execution commit。
3. `scripts/check-artifact-schemas.sh` 与 `tests/smoke.sh schema` 负责字段级护栏。

## Gate Rules

- 若 `summary.independent_skeptic == false`，不得宣称“独立质疑位已覆盖”，应标注为 degraded。
- 若 `summary.quality_seat_status == blocked`，不得进入 execution，也不得宣称质量位已经可用。
- 若 `degraded_ack_ready == false`，不得进入 execution。
- 若 closeout 结构不完整或 `ready_for_execution_slice_done == false`，不得判定 `execution slice done`。
- 若 state 未写入 commit 锚点和 verification 证据，不得判定 `task done`。
