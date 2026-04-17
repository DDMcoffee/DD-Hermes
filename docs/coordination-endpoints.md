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
  - `summary.task_class`
  - `summary.task_class_bucket`
  - `summary.quality_requirement`
  - `summary.quality_requirement_ready`
  - `summary.quality_requirement_reasons`
  - `summary.task_policy_status`
  - `summary.manual_escalation_required`
  - `summary.manual_escalation_reasons`
  - `summary.independent_skeptic`
  - `summary.product_gate_status`
  - `summary.quality_anchor_status`
  - `summary.quality_review_gate_status`
  - `summary.degraded_ack_status`
  - `summary.quality_seat_mode`
  - `summary.quality_seat_status`
  - `summary.quality_seat_reasons`
  - `summary.skeptic_lane_status`
  - `summary.skeptic_lane_ready`
  - `summary.skeptic_lane_reasons`
  - `summary.execution_closeout_status`
  - `summary.execution_closeout_ready`
  - `summary.execution_closeout_reasons`
  - `summary.execution_closeout_path`
  - `summary.ready_for_execution_slice_done`
  - `summary.degraded_ack_ready`
  - `summary.verdicts_updated_at`
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
- Notes:
  - 对 lane 级 packet，可附加 `--agent-id <agent_id>`，输出 `context-<role>-<agent>.json / runtime-<role>-<agent>.json`，避免多个 lane 互相覆盖。
- Stdout response required fields:
  - `context_path`
  - `runtime_path`
  - `state_path`
  - `memory_count`
  - `handoff_count`
  - `exploration_count`
- `context_summary.*` 不在 stdout 返回值里，而是在生成出来的 `context.json` 内部：
  - `context_summary.product_gate_ready`
  - `context_summary.quality_anchor_ready`
  - `context_summary.product_gate_status`
  - `context_summary.quality_anchor_status`
  - `context_summary.quality_review_gate_status`
  - `context_summary.task_class`
  - `context_summary.quality_requirement`
  - `context_summary.quality_requirement_ready`
  - `context_summary.task_policy_status`
  - `context_summary.manual_escalation_required`
  - `context_summary.manual_escalation_reasons`
  - `context_summary.quality_seat_mode`
  - `context_summary.quality_seat_status`
  - `context_summary.skeptic_lane_status`
  - `context_summary.skeptic_lane_ready`
  - `context_summary.skeptic_lane_reasons`
  - `context_summary.execution_closeout_status`
  - `context_summary.execution_closeout_ready`
  - `context_summary.execution_closeout_reasons`
  - `context_summary.execution_closeout_path`
  - `context_summary.ready_for_execution_slice_done`
  - `context_summary.degraded_ack_ready`
  - `context_summary.degraded_ack_status`
  - `context_summary.verdicts_updated_at`

### 4) `dispatch.create`

- Router entry: `scripts/coordination-endpoint.sh --endpoint dispatch.create --task-id <task_id>`
- Implementation: `scripts/dispatch-create.sh --task-id <task_id>`
- Purpose: 从 `state.team` 物化 supervisor/executor/skeptic assignment。
- Response required fields:
  - `task_id`, `state_path`, `context_path`, `runtime_path`
  - `independent_skeptic`, `degraded`, `degraded_ack_ready`, `role_conflicts`
  - `degraded_ack_status`
  - `task_class`, `task_class_bucket`, `quality_requirement`, `task_policy_status`, `manual_escalation_required`, `manual_escalation_reasons`, `task_policy_reasons`
  - `quality_seat_mode`, `quality_seat_status`, `quality_seat_reasons`
  - `skeptic_lane_status`, `skeptic_lane_ready`, `skeptic_lane_reasons`
  - `summary.supervisor_count`, `summary.executor_count`, `summary.skeptic_count`
  - `assignments`
- 若 preflight 或 lane 物化在 `state_read`、`context_build` 或 `worktree_create` 阶段失败，必须返回协议内 blocked JSON，而不是 traceback。
  - 失败响应至少应包含 `blocked`, `stage`, `role`, `agent_id`, `child_command`, `child_exit_code`, `suggested_next_commands`

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
  - `execution_closeout`
  - `semantic_valid`
  - `ready_for_execution_slice_done`
- `execution_closeout.status` 对 `T0/T1` 应允许返回 `not-required`；这类任务不应因为 placeholder closeout 而被判成 blocked。

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
  - `task_class / quality_requirement` 必须完整，不能把执行任务留在未分类状态
  - 若 `T2` 已命中手动升级条件，则必须先把 `quality_requirement` 显式写成 `requires-independent`
  - 若 `role_integrity.degraded == true`，必须先有显式 `degraded ack`
  - 若 `quality_requirement == requires-independent`，则 `quality_seat_mode` 必须是 `independent`
  - 若 `quality_requirement == requires-independent`，则 `skeptic lane` 也必须已物化，不能只停留在 `independent_skeptic=true`
- Response required fields:
  - `pass`, `target_thread`, `blocked_reason`
  - `skeptic_lane_status`, `skeptic_lane_ready`, `skeptic_lane_reasons`

### 8) `quality.gate`

- Router entry: `scripts/coordination-endpoint.sh --endpoint quality.gate --task-id <task_id> < payload.json`
- Implementation: `hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json`
- Purpose: 完成态门卫，阻止“代码改了但证据不完整”时宣称完成。
- Checks:
  - `verified_steps` / `verified_files` 是否覆盖 changed code
  - `product_gate` 是否 ready
  - `task_class_policy` 是否完整
  - `degraded_ack` / `quality_review` / `quality_seat` 是否通过
  - closeout 语义是否已从占位态升级为真实 execution evidence
- 若 `task_class_bucket == no-execution`，则 closeout 应视为 `not-required`，不再要求 execution commit 证据。
- Response required fields:
  - `event`, `pass`, `missing_verification`, `uncovered_files`
  - `task_class`, `quality_requirement`, `manual_escalation_required`, `manual_escalation_reasons`, `task_policy_status`, `task_policy_reasons`
  - `product_gate_status`, `degraded_ack_status`, `quality_review_gate_status`
  - `quality_seat_mode`, `quality_seat_status`, `quality_seat_reasons`
  - `execution_closeout_status`, `execution_closeout_ready`, `execution_closeout_reasons`, `execution_closeout_path`
  - `ready_for_execution_slice_done`
  - `verdicts_updated_at`
  - `closeout_path`, `closeout_reasons`
  - `blocked_reason`, `required_next_step`

### 9) `git.integrate`

- Router entry: `EXPERT=<agent_id> scripts/coordination-endpoint.sh --endpoint git.integrate --task-id <task_id>`
- Implementation: `scripts/git-integrate-task.sh --task-id <task_id> --expert <agent_id>`
- Purpose: 将执行分支合并回主分支（integration commit），含前置检查。
- Pre-checks: handoff 存在、verification.last_pass 为 true、worktree 无脏文件。
- Response required fields:
  - `task_id`, `integrated_branch`, `commit_sha`
  - `pre_check_warnings`, `handoff_found`, `verification_pass`

### 10) `session.analytics`

- Router entry: `scripts/coordination-endpoint.sh --endpoint session.analytics --task-id <any>`
- Implementation: `scripts/session-analytics.sh --days 7`
- Purpose: 分析会话日志，统计工具使用/错误频率/碎片化，自动建议 KB 条目。
- Response required fields:
  - `session_count`, `tool_usage`, `error_frequency`
  - `fragmentation_score`, `kb_suggestions`

### 11) `memory.decay`

- Router entry: `scripts/coordination-endpoint.sh --endpoint memory.decay --task-id <any>`
- Implementation: `scripts/memory-decay-schedule.sh --dry-run`
- Purpose: 扫描超龄记忆卡并报告衰减候选（默认 dry-run 模式）。
- Response required fields:
  - `candidates`, `count`, `max_age_days`

### 12) `journal.compact`

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
- 若 `summary.quality_requirement_ready == false`，不得进入 execution。
- 若 `summary.manual_escalation_required == true`，不得继续把该 `T2` 任务当成 degraded-allowed；必须显式升级。
- 若 `degraded_ack_ready == false`，不得进入 execution。
- 若 `summary.quality_requirement == requires-independent` 且 `summary.independent_skeptic == false`，不得进入 execution。
- 若 closeout 结构不完整或 `ready_for_execution_slice_done == false`，不得判定 `execution slice done`。
- 对 `T0/T1` 的 `no-execution` 任务，`execution_closeout_status = not-required` 即为合法完成态，不需要伪造 execution slice。
- 若 `quality-gate` 未通过，不得宣称 `execution slice done` 或 `task done`。
- 若 state 未写入 commit 锚点和 verification 证据，不得判定 `task done`。
