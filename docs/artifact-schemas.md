# DD Hermes Artifact Schemas (v1)

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
- Sections required:
  - `## Context`
  - `## Scope`
  - `## Required Fields`
  - `## Acceptance`
  - `## Verification`
  - `## Open Questions`

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
- Sections required:
  - `## Context`
  - `## Required Fields`
  - `## Acceptance`
  - `## Verification`
  - `## Open Questions`

## 3) Task State

- Path: `workspace/state/<task_id>/state.json`
- Required top-level keys:
  - `task_id`
  - `status`
  - `mode`
  - `owner`
  - `experts`
  - `verification`
  - `runtime`
  - `git`
  - `memory`
  - `team`
  - `updated_at`
- Required team keys:
  - `supervisors`
  - `executors`
  - `skeptics`
  - `scale_out_recommended`
  - `scale_out_triggers`
  - `role_integrity`
- Required `team.role_integrity` keys:
  - `independent_skeptic`
  - `degraded`
  - `role_conflicts`
  - `role_overlap`

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
- Sections required:
  - `## Context`
  - `## Required Fields`
  - `## Completion`
  - `## Verification`
  - `## Open Questions`

## Validation Entry

- `scripts/check-artifact-schemas.sh --task-id <task_id>` 是字段校验入口。
- `scripts/test-artifact-schemas.sh` 与 `tests/smoke.sh schema` 都应覆盖该入口。
