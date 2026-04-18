---
schema_version: 2
task_id: xc-baoxiao-web-m4-report-task-visibility-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Make the XC-BaoXiaoAuto web reports page explain the latest export task state so users can see whether bundle generation is pending, running, failed, or completed without guessing from missing artifacts.
user_value: When export generation fails or is still running, the reports page surfaces that state and reason directly instead of leaving users with only a button and a silent artifact list.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo UI and service slice across a few files with clear acceptance and low integration risk, but it changes product-facing behavior on a core M4 flow and therefore needs S2 traceability.
non_goals:
  - Do not change report-generation semantics.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - Reports page shows the latest bundle-task state per trip in readable Chinese.
  - Failed bundle tasks expose the error reason on the reports page.
  - Regression tests cover the new status wording and trip-query shape.
drift_risk: This slice could drift into a broader reports-page redesign or task-runner refactor. Stop once the latest export task state is visible and readable on the reports page.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: f70c59170aa8889df73868bb26fc0ca254424341
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "task status names and sanitized error summaries"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "real storage-root absolute paths from runtime env"

acceptance:
  - `trip.list` exposes the latest `GENERATE_BUNDLE` task needed by the reports page.
  - Reports page renders readable bundle-task state and failure reason.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on the target worktree.
blocked_if:
  - Surfacing the latest export task state requires a broader backend schema change.
  - The slice cannot stay local to reports page and trip-list query shape.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m4-report-task-visibility-v1.md
---

# Sprint Contract

## Context

The web line now records honest export failure state and hardened download behavior, but the reports page still leaves a visibility gap: it only shows export readiness and artifacts. If bundle generation fails after the user clicks "生成材料", there is now a durable failed task in the backend, but the reports page still does not expose that state directly.

This slice keeps scope on that visibility gap. It only surfaces the latest export task state already present in the data model.

## Scope

- In scope:
  - latest `GENERATE_BUNDLE` task on `trip.list`
  - readable bundle-task display on reports page
  - regression tests for task-status wording and query shape
- Out of scope:
  - report-generation logic changes
  - broader reports-page redesign
  - branch landing / cleanup work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `f70c59170aa8889df73868bb26fc0ca254424341`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m4-report-task-visibility-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m4-report-task-visibility-v1/state.json`

## Acceptance

- Reports page explains the latest export task state in readable Chinese.
- Failed export tasks expose their reason without requiring backend inspection.
- Standard web gate passes after the change.

## Product Gate

- This slice stays on roadmap M4's "异常时有可定位的反馈".
- Stop if the work expands into task-runner refactoring or broader page redesign.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for the new report-task helper
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m4-report-task-visibility-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-report-task-visibility-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m4-report-task-visibility-v1/state.json`

## Open Questions

- None for scope. If task-state wording wants a tiny helper, keep it shared with existing task-status display rather than inventing page-local labels.
