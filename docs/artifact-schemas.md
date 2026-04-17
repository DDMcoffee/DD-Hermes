# DD Hermes Artifact Schemas (v2)

本文档定义执行线程必须可校验的工件字段，不依赖口头约定。

## 1) Sprint Contract

- Path: `workspace/contracts/<task_id>.md`
- Frontmatter required:
  - `task_id`
  - `owner`
  - `experts`
  - `acceptance`
  - `blocked_if`
  - `memory_reads`
  - `memory_writes`
- Frontmatter additionally required when `schema_version: 2`:
  - `schema_version`
  - `product_goal`
  - `user_value`
  - `task_class`
  - `quality_requirement`
  - `task_class_rationale`
  - `non_goals`
  - `product_acceptance`
  - `drift_risk`
- Sections required:
  - `## Context`
  - `## Scope`
  - `## Required Fields`
  - `## Acceptance`
  - `## Verification`
  - `## Open Questions`
- Sections additionally required when `schema_version: 2`:
  - `## Product Gate`

## 2) Handoff (Lead/Expert)

- Paths:
  - `workspace/handoffs/<task_id>-lead-to-<expert>.md`
  - `workspace/handoffs/<task_id>-<expert>-to-lead.md`
- Frontmatter required:
  - `from`
  - `to`
  - `scope`
  - `files`
  - `decisions`
  - `risks`
  - `next_checks`
- Frontmatter additionally required when `schema_version: 2`:
  - `schema_version`
  - `product_rationale`
  - `goal_drift_risk`
  - `user_visible_outcome`
- Sections required:
  - `## Context`
  - `## Required Fields`
  - `## Acceptance`
  - `## Verification`
  - `## Open Questions`
- Sections additionally required when `schema_version: 2`:
  - `## Product Check`

## 3) Task State

- Path: `workspace/state/<task_id>/state.json`
- Required top-level keys:
  - `task_id`
  - `status`
  - `mode`
  - `current_focus`
  - `active_expert`
  - `blocked_reason`
  - `owner`
  - `experts`
  - `discussion`
  - `verification`
  - `runtime`
  - `lease`
  - `git`
  - `memory`
  - `contract_path`
  - `handoff_paths`
  - `exploration_paths`
  - `openspec`
  - `team`
  - `updated_at`
- Required top-level keys when `state_version >= 2`:
  - `product`
  - `quality`
  - `verdicts`
- 说明：
  - `check-artifact-schemas` 证明结构完整。
  - `thread-switch-gate` / `dispatch-create` / `quality-gate` 还会继续消费 `discussion`、`lease`、`product`、`quality` 与 closeout 语义，所以“schema pass”不等于“可以进入 execution 或可以宣称完成”。
- Required team keys:
  - `supervisors`
  - `executors`
  - `skeptics`
  - `scale_out_recommended`
  - `scale_out_triggers`
  - `role_integrity`
- Required team keys when `state_version >= 2`:
  - `product_anchors`
  - `quality_anchors`
  - `anchor_policy`
- Required `team.role_integrity` keys:
  - `independent_skeptic`
  - `degraded`
  - `degraded_ack_by`
  - `degraded_ack_at`
  - `role_conflicts`
  - `role_overlap`
- Required `product` keys when `state_version >= 2`:
  - `anchor`
  - `goal`
  - `user_value`
  - `task_class`
  - `quality_requirement`
  - `task_class_rationale`
  - `non_goals`
  - `product_acceptance`
  - `drift_risk`
  - `goal_status`
  - `goal_drift_flags`
  - `last_product_review_at`
- Required `quality` keys when `state_version >= 2`:
  - `anchor`
  - `review_status`
  - `review_findings`
  - `review_examples`
  - `last_review_at`
- Required `verdicts` keys when `state_version >= 2`:
  - `updated_at`
  - `task_policy`
  - `product_gate`
  - `quality_anchor`
  - `quality_review`
  - `degraded_ack`
  - `quality_seat_execution`
  - `quality_seat_completion`
  - `skeptic_lane`
  - `execution_closeout`
- 兼容说明：
  - 旧 state 若还没回填 `skeptic_lane`，`state-read / context-build / check-artifact-schemas` 应现场派生该 verdict，而不是把历史 archive 全部打坏。
- Required per-verdict keys:
  - `status`
  - `ready`
  - `reasons`
  - `updated_at`
- `execution_closeout` additionally carries:
  - `closeout_path`
  - `selected_by`
  - `candidate_count`
  - `semantic_valid`
  - `ready_for_execution_slice_done`
  - `execution_commit`
  - `quality_review_status`
  - `status` 允许 `ready` / `blocked` / `not-required`

## 4) Execution Closeout

- Path: `workspace/closeouts/<task_id>-<expert>.md`
- Frontmatter required:
  - `task_id`
  - `from`
  - `to`
  - `scope`
  - `execution_commit`
  - `state_path`
  - `context_path`
  - `runtime_path`
  - `verified_steps`
  - `verified_files`
  - `open_risks`
  - `next_actions`
- Frontmatter additionally required when `schema_version: 2`:
  - `schema_version`
  - `quality_review_status`
  - `quality_findings_summary`
- Semantic completion requirements for `execution slice done`:
  - `execution_commit` 不能为空，且应与 `state.git.latest_commit` 对齐
  - `verified_steps` 不能为空，且不能停留在模板占位值
  - `verified_files` 不能为空，且不能停留在模板占位值
  - `quality_review_status` 必须是 `approved` 或 `degraded-approved`
  - `quality_findings_summary` 必须是真实复核摘要，不是占位句
- 若 `task_class_bucket == no-execution`（`T0/T1`）：
  - `execution_closeout.status` 应为 `not-required`
  - `execution_closeout.ready` 应为 `true`
  - `ready_for_execution_slice_done` 应为 `true`
  - 即使存在 bootstrap 占位 closeout 文件，也不应继续把 archive truth 判成 blocked
- Sections required:
  - `## Context`
  - `## Required Fields`
  - `## Completion`
  - `## Verification`
  - `## Open Questions`
- Sections additionally required when `schema_version: 2`:
  - `## Quality Review`

## 5) State Events (`events.jsonl`)

- Path: `workspace/state/<task_id>/events.jsonl`
- Required fields per line:
  - `event_id`
  - `source` — `"state"` for state events, distinguishing from `memory/journal/*.jsonl`
  - `task_id`
  - `op` — `state_init`, `state_refresh`, `state_update`, `context_build`
  - `timestamp`
  - `actor`

## 6) Context Summary (in `context.json`)

- Generated by `context-build.sh` inside `context_path`.
- `context-build.sh` 的 stdout 只返回 `context_path / runtime_path / state_path / memory_count / handoff_count / exploration_count`。
- 真正给执行面消费的 `context_summary` 在生成出来的 `context.json` 内部。
- Key fields in `context_summary`:
  - `runtime_generated_at` — ISO timestamp of when the context was built
  - `runtime_stale_warning` — non-empty string if previous runtime snapshot was >60 min old
  - `task_class`, `task_class_bucket`, `task_class_rationale`
  - `quality_requirement`, `quality_requirement_source`, `quality_requirement_ready`, `quality_requirement_reasons`
  - `task_policy_status`
  - `manual_escalation_required`, `manual_escalation_reasons`
  - `product_gate_status`
  - `quality_anchor_status`
  - `quality_review_gate_status`
  - `degraded_ack_status`
  - `quality_seat_mode`, `quality_seat_status`, `quality_seat_reasons`
  - `skeptic_lane_status`, `skeptic_lane_ready`, `skeptic_lane_reasons`
  - `execution_closeout_status`, `execution_closeout_ready`, `execution_closeout_reasons`, `execution_closeout_path`
  - `ready_for_execution_slice_done`
  - `independent_skeptic`, `role_integrity_degraded`, `degraded_ack_required`, `degraded_ack_ready`, `role_conflicts`
  - `scale_out_recommended`, `scale_out_triggers`
  - `verdicts_updated_at`

## 7) Completion Gate (`quality-gate`)

- Generated by `hooks/quality-gate.sh`.
- Required fields:
  - `event`, `pass`, `missing_verification`, `uncovered_files`
  - `task_class`, `quality_requirement`, `manual_escalation_required`, `manual_escalation_reasons`, `task_policy_status`, `task_policy_reasons`
  - `product_gate_status`
  - `degraded_ack_status`
  - `quality_review_gate_status`
  - `quality_seat_mode`, `quality_seat_status`, `quality_seat_reasons`
  - `execution_closeout_status`, `execution_closeout_ready`, `execution_closeout_reasons`, `execution_closeout_path`
  - `ready_for_execution_slice_done`
  - `verdicts_updated_at`
  - `closeout_path`, `closeout_reasons`
  - `blocked_reason`, `required_next_step`
- Purpose:
  - 区分“结构完整”与“真的可以宣称 execution slice done / task done”。

## 8) Lease Check Output

- Generated by `lease-check.sh`.
- Required fields:
  - `lease_status`, `exceeded`, `should_pause`
  - `elapsed_minutes`, `remaining_minutes`
  - `active_expert`, `lease_conflict`, `lease_conflict_reason`

## 9) Worktree Remove Output

- Generated by `worktree-remove.sh`.
- Required fields:
  - `removed_worktree`, `branch`, `deleted_branch`
  - `pre_remove_warnings` — array of pre-remove validation warnings

## Validation Entry

- `scripts/check-artifact-schemas.sh --task-id <task_id>` 是字段校验入口。
- 该入口同时返回 `semantic_valid` 与 `ready_for_execution_slice_done`，用于区分“结构完整”与“真的可以宣称 execution slice done”。
- 对 `T0/T1` 这类 `no-execution` 任务，`execution_closeout` 应显式返回 `not-required`，而不是伪造一个 blocked closeout。
- `scripts/test-artifact-schemas.sh` 与 `tests/smoke.sh schema` 都应覆盖该入口。
