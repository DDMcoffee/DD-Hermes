---
schema_version: 2
task_id: xc-baoxiao-web-m4-export-failure-state-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Make the XC-BaoXiaoAuto web export path fail honestly by converting post-enqueue bundle-generation errors into explicit failed tasks instead of leaving them stuck in RUNNING.
user_value: When report generation breaks after the task has already been enqueued, operators can see a real FAILED task with an error message instead of a misleading running task that never completes.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo service and test slice that changes failure semantics on a core async workflow. It is small in file count, but it affects product-visible operational truth and therefore needs S2 traceability.
non_goals:
  - Do not redesign the reports UI.
  - Do not change artifact content or export formats.
  - Do not land this branch onto target `web-main` in the same slice.
product_acceptance:
  - Bundle-generation failures after enqueue produce a FAILED async task with the same error message surfaced to the caller.
  - Successful bundle generation keeps the existing completed-task behavior.
  - Regression tests cover the new failed-task path.
drift_risk: This slice could drift into artifact download UX, storage-driver abstraction work, or a broader export-center redesign. Stop once failed-task semantics are reliable and verified.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: 95bb706de73aaccd0820f0facd7a235d98408423
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "task status names and artifact count summaries"
    - "sanitized error-message class names"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "real storage-root absolute paths from runtime env"

acceptance:
  - `generateBundleForTrip` marks the async task as FAILED when export work throws after enqueue.
  - The thrown error message remains visible to the caller.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on the target worktree.
blocked_if:
  - Fixing the failure path requires touching the user's six dirty paths on target `web-main`.
  - Export failure semantics turn out to depend on a broader task-runner redesign.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m4-export-failure-state-v1.md
---

# Sprint Contract

## Context

The web line now blocks export when review blockers remain, and the readable review-state has already landed on `web-main`. The next M4 gap is operational honesty during bundle generation itself: once `generateBundleForTrip` enqueues a `GENERATE_BUNDLE` task, any later storage or database failure currently throws out of the function without marking that task as failed. That leaves the system with a misleading `RUNNING` task and no durable failure record.

This slice keeps scope tight. It only corrects post-enqueue failure handling in the report-generation service and proves that behavior with tests.

## Scope

- In scope:
  - `generateBundleForTrip` failed-task completion semantics
  - regression tests for post-enqueue export failure
  - standard web gate on the isolated target worktree
- Out of scope:
  - reports page redesign
  - download-route changes
  - landing / cleanup / push work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `95bb706de73aaccd0820f0facd7a235d98408423`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m4-export-failure-state-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m4-export-failure-state-v1/state.json`

## Acceptance

- Async export tasks fail honestly instead of lingering in `RUNNING`.
- The caller still receives the underlying failure message.
- Success-path export behavior remains intact.

## Product Gate

- This slice stays on roadmap M4's "异常时有可定位的反馈".
- Stop if the work expands into download UX or storage abstraction redesign.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for the new failed-task behavior
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m4-export-failure-state-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-export-failure-state-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m4-export-failure-state-v1/state.json`

## Open Questions

- None for scope. If the failure path exposes an error-shape mismatch, the only allowed extension is a tiny helper to normalize the message.
