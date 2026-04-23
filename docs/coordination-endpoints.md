# DD Hermes Coordination Endpoints (v1)

This document turns the coordination model into executable endpoint contracts.
It translates the original planning notes into script-facing interfaces, and it makes the entry and stop conditions for implementation explicit.

## 三层终点映射

- `execution slice done`
  - An Expert produces an execution commit inside an isolated worktree.
  - The slice writes back expert handoff, verification evidence, and a state-side git anchor.
- `task done`
  - Lead completes the integration commit and passes task-level acceptance.
  - `state.status` moves to `done` and remains traceable to integration evidence.
- `project phase done`
  - OpenSpec and project-goal documents are closed out together.
  - The definition is no longer “the scaffold exists,” but “the phase contract has been verified.”

## Endpoint Surface

DD Hermes expresses its coordination surface through scripts.
The unified router entrypoint is:

```bash
scripts/coordination-endpoint.sh --endpoint <name> --task-id <task_id>
```

### 1) `state.read`

- Router entry: `scripts/coordination-endpoint.sh --endpoint state.read --task-id <task_id>`
- Implementation: `scripts/state-read.sh --task-id <task_id>`
- Purpose: Read the task control plane and emit a derived summary.
- Required response fields:
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
- Purpose: Update the control plane and append to `events.jsonl`.
- Common request fields:
  - `status`, `mode`, `current_focus`, `active_expert`
  - `append_verified_steps`, `append_verified_files`, `last_pass`
  - `commit_sha`, `commit_branch`, `context_path`, `runtime_report_path`
  - `supervisors`, `executors`, `skeptics`

### 3) `context.build`

- Router entry: `scripts/coordination-endpoint.sh --endpoint context.build --task-id <task_id> --agent-role <role>`
- Implementation: `scripts/context-build.sh --task-id <task_id> --agent-role <role>`
- Purpose: Assemble the execution input packet.
- Lane-specific note:
  - For lane-level packets, append `--agent-id <agent_id>`.
  - This writes `context-<role>-<agent>.json` and `runtime-<role>-<agent>.json`, so parallel lanes do not overwrite one another.
- Stdout required fields:
  - `context_path`
  - `runtime_path`
  - `state_path`
  - `memory_count`
  - `handoff_count`
  - `exploration_count`
- `context_summary.*` fields do not appear on stdout.
  They live inside the generated `context.json`:
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
- Purpose: Materialize supervisor, executor, and skeptic assignments from `state.team`.
- Required response fields:
  - `task_id`, `state_path`, `context_path`, `runtime_path`
  - `independent_skeptic`, `degraded`, `degraded_ack_ready`, `role_conflicts`
  - `degraded_ack_status`
  - `task_class`, `task_class_bucket`, `quality_requirement`, `task_policy_status`, `manual_escalation_required`, `manual_escalation_reasons`, `task_policy_reasons`
  - `quality_seat_mode`, `quality_seat_status`, `quality_seat_reasons`
  - `skeptic_lane_status`, `skeptic_lane_ready`, `skeptic_lane_reasons`
  - `summary.supervisor_count`, `summary.executor_count`, `summary.skeptic_count`
  - `assignments`
- If preflight or lane materialization fails during `state.read`, `context.build`, or `worktree.create`, the endpoint must return protocol-level blocked JSON instead of a traceback.
- The minimum failure response should include:
  - `blocked`, `stage`, `role`, `agent_id`, `child_command`, `child_exit_code`, `suggested_next_commands`

### 5) `closeout.check`

- Router entry: `scripts/coordination-endpoint.sh --endpoint closeout.check --task-id <task_id>`
- Implementation: `scripts/check-artifact-schemas.sh --task-id <task_id>`
- Purpose: Validate required fields across `contract`, `handoff`, `state`, and `closeout` artifacts.
- Required response fields:
  - `task_id`
  - `checked`
  - `artifacts`
  - `errors`
  - `valid`
  - `execution_closeout`
  - `semantic_valid`
  - `ready_for_execution_slice_done`
- For `T0` and `T1` tasks, `execution_closeout.status` should be allowed to return `not-required`.
  Those tasks should not be marked blocked only because a placeholder closeout exists.

### 6) `lease.check`

- Router entry: `scripts/coordination-endpoint.sh --endpoint lease.check --task-id <task_id>`
- Implementation: `scripts/lease-check.sh --task-id <task_id>`
- Purpose: Check whether a task lease has expired and optionally auto-pause with `AUTO_PAUSE=1`.
- Required response fields:
  - `lease_status`, `exceeded`, `should_pause`
  - `elapsed_minutes`, `remaining_minutes`
  - `active_expert`, `lease_conflict`, `lease_conflict_reason`

### 7) `thread.gate`

- Router entry: `scripts/coordination-endpoint.sh --endpoint thread.gate --task-id <task_id>`
- Implementation: `hooks/thread-switch-gate.sh --task-id <task_id> --target execution`
- Purpose: Guard thread transitions before dispatching an execution lane.
- Gate checks:
  - When `discussion.policy == 3-explorer-then-execute`, `synthesis_path` must exist.
  - `lease.status` must not be `paused`.
  - `state.team.executors` must not be empty.
  - The product gate must be complete: `user_value`, `non_goals`, `product_acceptance`, and `drift_risk` cannot be missing.
  - A quality anchor must already be assigned.
  - `task_class` and `quality_requirement` must be complete; execution tasks cannot remain unclassified.
  - If a `T2` task hits a manual-escalation rule, `quality_requirement` must be written explicitly as `requires-independent` first.
  - If `role_integrity.degraded == true`, an explicit degraded acknowledgment must exist first.
  - If `quality_requirement == requires-independent`, then `quality_seat_mode` must be `independent`.
  - If `quality_requirement == requires-independent`, the skeptic lane must also be materialized; `independent_skeptic=true` alone is not enough.
- Required response fields:
  - `pass`, `target_thread`, `blocked_reason`
  - `skeptic_lane_status`, `skeptic_lane_ready`, `skeptic_lane_reasons`

### 8) `quality.gate`

- Router entry: `scripts/coordination-endpoint.sh --endpoint quality.gate --task-id <task_id> < payload.json`
- Implementation: `hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json`
- Purpose: Prevent “code changed but evidence is incomplete” from being reported as complete.
- Gate checks:
  - whether `verified_steps` and `verified_files` cover changed code
  - whether `product_gate` is ready
  - whether `task_class_policy` is complete
  - whether `degraded_ack`, `quality_review`, and `quality_seat` pass
  - whether closeout semantics have been upgraded from placeholder state to real execution evidence
- If `task_class_bucket == no-execution`, closeout should be treated as `not-required` and execution-commit evidence should not be demanded.
- Required response fields:
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
- Purpose: Merge an execution branch back into the main branch with pre-checks.
- Pre-checks:
  - handoff exists
  - `verification.last_pass == true`
  - worktree is clean
- Required response fields:
  - `task_id`, `integrated_branch`, `commit_sha`
  - `pre_check_warnings`, `handoff_found`, `verification_pass`

### 10) `session.analytics`

- Router entry: `scripts/coordination-endpoint.sh --endpoint session.analytics --task-id <any>`
- Implementation: `scripts/session-analytics.sh --days 7`
- Purpose: Analyze session logs, summarize tool usage and error frequency, measure fragmentation, and suggest KB candidates.
- Required response fields:
  - `session_count`, `tool_usage`, `error_frequency`
  - `fragmentation_score`, `kb_suggestions`

### 11) `memory.decay`

- Router entry: `scripts/coordination-endpoint.sh --endpoint memory.decay --task-id <any>`
- Implementation: `scripts/memory-decay-schedule.sh --dry-run`
- Purpose: Scan stale memory cards and report decay candidates in dry-run mode.
- Required response fields:
  - `candidates`, `count`, `max_age_days`

### 12) `journal.compact`

- Router entry: `scripts/coordination-endpoint.sh --endpoint journal.compact --task-id <any>`
- Implementation: `scripts/journal-compact.sh --dry-run`
- Purpose: Archive aged journal files into `memory/journal/archive/` in dry-run mode.
- Required response fields:
  - `compacted`, `kept`, `dry_run`

### 13) `successor.audit`

- Router entry: `scripts/coordination-endpoint.sh --endpoint successor.audit --task-id <any>`
- Implementation: `scripts/successor-evidence-audit.sh`
- Purpose: Audit successor evidence and separate committed live candidates, archived proof history, and working-tree residue.
