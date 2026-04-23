# DD Hermes Artifact Schemas (v2)

This document defines the task artifacts that execution lanes must produce and that DD Hermes must be able to validate without relying on verbal agreement.

## 1) Sprint Contract

- Path: `workspace/contracts/<task_id>.md`
- Required frontmatter fields:
  - `task_id`
  - `owner`
  - `experts`
  - `acceptance`
  - `blocked_if`
  - `memory_reads`
  - `memory_writes`
- Additional frontmatter required when `schema_version: 2`:
  - `schema_version`
  - `product_goal`
  - `user_value`
  - `task_class`
  - `quality_requirement`
  - `task_class_rationale`
  - `non_goals`
  - `product_acceptance`
  - `drift_risk`
- Required sections:
  - `## Context`
  - `## Scope`
  - `## Required Fields`
  - `## Acceptance`
  - `## Verification`
  - `## Open Questions`
- Additional section required when `schema_version: 2`:
  - `## Product Gate`

## 2) Handoff (Lead/Expert)

- Paths:
  - `workspace/handoffs/<task_id>-lead-to-<expert>.md`
  - `workspace/handoffs/<task_id>-<expert>-to-lead.md`
- Required frontmatter fields:
  - `from`
  - `to`
  - `scope`
  - `files`
  - `decisions`
  - `risks`
  - `next_checks`
- Additional frontmatter required when `schema_version: 2`:
  - `schema_version`
  - `product_rationale`
  - `goal_drift_risk`
  - `user_visible_outcome`
- Required sections:
  - `## Context`
  - `## Required Fields`
  - `## Acceptance`
  - `## Verification`
  - `## Open Questions`
- Additional section required when `schema_version: 2`:
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
- Additional top-level keys required when `state_version >= 2`:
  - `product`
  - `quality`
  - `verdicts`
- Notes:
  - `check-artifact-schemas` proves structural completeness.
  - `thread-switch-gate`, `dispatch.create`, and `quality-gate` continue to consume `discussion`, `lease`, `product`, `quality`, and execution-closeout semantics.
  - A schema pass does not automatically mean a task may enter execution or claim completion.
- Required `team` keys:
  - `supervisors`
  - `executors`
  - `skeptics`
  - `scale_out_recommended`
  - `scale_out_triggers`
  - `role_integrity`
- Additional `team` keys required when `state_version >= 2`:
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
- Compatibility note:
  - If an older state has not yet been backfilled with `skeptic_lane`, `state.read`, `context.build`, and `check-artifact-schemas` should derive that verdict at runtime instead of breaking historical archives.
- Required fields for each verdict:
  - `status`
  - `ready`
  - `reasons`
  - `updated_at`
- Additional fields carried by `execution_closeout`:
  - `closeout_path`
  - `selected_by`
  - `candidate_count`
  - `semantic_valid`
  - `ready_for_execution_slice_done`
  - `execution_commit`
  - `quality_review_status`
  - `status` may be `ready`, `blocked`, or `not-required`

## 4) Execution Closeout

- Path: `workspace/closeouts/<task_id>-<expert>.md`
- Required frontmatter fields:
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
- Additional frontmatter required when `schema_version: 2`:
  - `schema_version`
  - `quality_review_status`
  - `quality_findings_summary`
- Semantic completion requirements for `execution slice done`:
  - `execution_commit` must not be empty and should match `state.git.latest_commit`
  - `verified_steps` must not be empty and must not remain a template placeholder
  - `verified_files` must not be empty and must not remain a template placeholder
  - `quality_review_status` must be `approved` or `degraded-approved`
  - `quality_findings_summary` must contain a real review summary instead of a placeholder sentence
- For `task_class_bucket == no-execution` (`T0` and `T1`):
  - `execution_closeout.status` should be `not-required`
  - `execution_closeout.ready` should be `true`
  - `ready_for_execution_slice_done` should be `true`
  - Even if a bootstrap placeholder closeout file exists, archive truth should not remain blocked.
- Required sections:
  - `## Context`
  - `## Required Fields`
  - `## Completion`
  - `## Verification`
  - `## Open Questions`
- Additional section required when `schema_version: 2`:
  - `## Quality Review`

## 5) State Events (`events.jsonl`)

- Path: `workspace/state/<task_id>/events.jsonl`
- Required fields per line:
  - `event_id`
  - `source` - `"state"` for state events, distinguishing them from `memory/journal/*.jsonl`
  - `task_id`
  - `op` - `state_init`, `state_refresh`, `state_update`, or `context_build`
  - `timestamp`
  - `actor`

## 6) Context Summary (`context.json`)

- Generated by `context-build.sh` inside `context_path`.
- Stdout from `context-build.sh` returns only:
  - `context_path`
  - `runtime_path`
  - `state_path`
  - `memory_count`
  - `handoff_count`
  - `exploration_count`
- The execution-facing `context_summary` lives inside the generated `context.json`.
- Key fields:
  - `runtime_generated_at` - ISO timestamp showing when the context was built
  - `runtime_stale_warning` - non-empty string if the previous runtime snapshot was older than 60 minutes
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
  - Distinguish “the structure is complete” from “the task may honestly claim execution slice done or task done.”

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
  - `pre_remove_warnings` - array of pre-remove validation warnings

## Validation Entry

- `scripts/check-artifact-schemas.sh --task-id <task_id>` is the field-validation entrypoint.
- The command also returns `semantic_valid` and `ready_for_execution_slice_done`, so DD Hermes can distinguish structural completeness from actual execution completion truth.
- For `T0` and `T1` tasks in the `no-execution` bucket, `execution_closeout` should explicitly return `not-required` instead of faking a blocked closeout.
- `scripts/test-artifact-schemas.sh` and `tests/smoke.sh schema` should both cover this validation surface.
