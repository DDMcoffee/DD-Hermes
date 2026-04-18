---
schema_version: 2
task_id: xc-baoxiao-web-m4-pdf-boundary-visibility-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Make the XC-BaoXiaoAuto web export flow explain the HTML/PDF boundary explicitly, so a completed bundle task no longer silently hides that PDF generation was skipped in the current environment.
user_value: When report export finishes without a PDF, users can see that HTML is ready and PDF was not generated, instead of guessing from a smaller artifact count.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo behavior slice across service and UI-display code with low architectural risk, but it changes product-facing export semantics on the current M4 path and therefore needs S2 traceability.
non_goals:
  - Do not implement a real background task runner.
  - Do not change artifact download behavior or storage-driver selection.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - Completed export tasks distinguish between “PDF 已生成” and “仅 HTML 已生成”.
  - The latest export-task detail shown in the reports page explains when PDF is unavailable in the current environment.
  - Regression tests cover both task-result semantics and user-facing wording.
drift_risk: This slice could drift into a broader export pipeline refactor or storage abstraction redesign. Stop once the completed-task result and display make the HTML/PDF boundary explicit.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: 2a6293508e9efd521073b5604f02f3660315e2b1
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "sanitized task-result fields and user-facing status wording"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "real storage-root absolute paths from runtime env"

acceptance:
  - `generateBundleForTrip` records whether PDF was generated in the completed task result.
  - Export-task display wording explains the no-PDF fallback path in readable Chinese.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on the target worktree.
blocked_if:
  - Clarifying the PDF boundary requires a schema migration or task-table change.
  - The slice cannot stay local to report-task result semantics and display wording.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m4-pdf-boundary-visibility-v1.md
---

# Sprint Contract

## Context

The web line now exposes export readiness, export failures, artifact download errors, and the latest export-task state. One M4 ambiguity still remains: when Playwright is unavailable, bundle generation completes with helper markdown, verification markdown, and claim HTML only, but users are not told that PDF generation was skipped. They only see a smaller artifact count and must infer the boundary themselves.

This slice keeps scope on making that HTML/PDF boundary explicit in the task result and the reports page wording.

## Scope

- In scope:
  - completed export-task result semantics for PDF generated vs skipped
  - readable completed-task wording on the reports page
  - regression tests for task result and wording
- Out of scope:
  - storage-driver redesign
  - download-route behavior changes
  - landing / cleanup work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `2a6293508e9efd521073b5604f02f3660315e2b1`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m4-pdf-boundary-visibility-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m4-pdf-boundary-visibility-v1/state.json`

## Acceptance

- Completed export tasks say whether PDF was generated.
- Reports page explains the “HTML ready, PDF unavailable” fallback without forcing users to inspect artifacts manually.
- Standard web gate passes after the change.

## Product Gate

- This slice stays on roadmap M4's "明确 HTML/PDF 生成的可用边界".
- Stop if the work expands into a broader export-pipeline refactor or storage abstraction redesign.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for report-task wording and report-service result semantics
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m4-pdf-boundary-visibility-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-pdf-boundary-visibility-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m4-pdf-boundary-visibility-v1/state.json`

## Open Questions

- None for scope. If wording needs a small helper change, keep it inside the existing export-task display path rather than inventing a second page-local status system.
