---
schema_version: 2
task_id: xc-baoxiao-web-m4-export-failure-state-v1
from: lead
to: lead
scope: xc-baoxiao-web-m4-export-failure-state-v1 S2 cross-repo completion
execution_commit: d7d19cb875f2ff89f70885fe0b1d226578e9b9b3
target_execution_commit: d7d19cb875f2ff89f70885fe0b1d226578e9b9b3
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: codex/xc-baoxiao-web-m4-export-failure-state-v1
state_path: workspace/state/xc-baoxiao-web-m4-export-failure-state-v1/state.json
context_path: workspace/state/xc-baoxiao-web-m4-export-failure-state-v1/context.json
runtime_path: workspace/state/xc-baoxiao-web-m4-export-failure-state-v1/runtime.json
cross_repo: true
size: S2
task_class: T2
verified_steps:
  - "target-side: added a failing report-service test for post-enqueue export failure"
  - "target-side: updated generateBundleForTrip to complete the task as FAILED before rethrowing"
  - "target-side: focused vitest run passed for report-service"
  - "target-side: npm run test exit 0 (6 files, 16 tests)"
  - "target-side: npm run typecheck exit 0"
  - "target-side: npm run build exit 0"
verified_files:
  - workspace/contracts/_archive/xc-baoxiao-web-m4-export-failure-state-v1.md
  - workspace/handoffs/xc-baoxiao-web-m4-export-failure-state-v1-lead-to-executor.md
  - workspace/exploration/exploration-lead-xc-baoxiao-web-m4-export-failure-state-v1.md
  - workspace/closeouts/xc-baoxiao-web-m4-export-failure-state-v1-lead.md
  - memory/task/xc-baoxiao-web-m4-export-failure-state-v1.md
verified_files_target_side:
  - products/web/apps/web/src/server/services/report-service.ts
  - products/web/apps/web/src/server/services/report-service.test.ts
quality_review_status: degraded-approved
quality_findings_summary:
  - "Post-enqueue export failures now leave a durable FAILED task instead of a misleading RUNNING task."
  - "The caller still receives the underlying error message, so the fix improves operational truth without hiding failure details."
  - "The slice stayed inside report-service semantics and did not drift into UI, download-route, or landing work."
open_risks:
  - "The same pre-existing Edge Runtime warnings still appear during build, though build exits 0."
  - "This slice does not yet add download-route diagnostics or filename normalization."
  - "The changes still live on a side branch until a later landing slice moves them onto local web-main."
next_actions:
  - "Archive contract and commit DD Hermes lifecycle artifacts"
  - "Run hooks/quality-gate.sh against the updated state.json"
  - "If continuing M4, either land this branch onto local web-main or take the next export/download hardening slice from here"
---

# Execution Closeout

## Context

After the M3 review-state work, the next M4 gap was not presentation but operational honesty. `generateBundleForTrip` already created an async task before any storage writes, but a later failure would throw out of the service without finalizing the task state. That left the product with a dead export that still looked like it was running.

## Completion

- Added a failing regression test for a storage failure after `GENERATE_BUNDLE` had already been enqueued.
- Wrapped the post-enqueue export pipeline in `generateBundleForTrip` so the task is completed as `FAILED` with the same error message before the error is rethrown.
- Kept the success-path artifact creation and completed-task behavior unchanged.

## Verification

- Focused red-green cycle passed for:
  - `src/server/services/report-service.test.ts`
- `npm run test` passed in `products/web` with `6` test files and `16` tests.
- `npm run typecheck` passed in `products/web`.
- `npm run build` passed in `products/web`.

## Quality Review

- The product gain is operational truth: export work no longer leaves stale running tasks after it has already failed.
- This change is intentionally narrow and does not mix in download-route or UI behavior.
- Degraded review is explicitly acknowledged: single-thread execution, no independent skeptic claimed.
