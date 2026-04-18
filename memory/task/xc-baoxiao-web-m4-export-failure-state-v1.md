---
id: xc-baoxiao-web-m4-export-failure-state-v1
kind: task
status: done
created_at: 2026-04-18T00:00:00Z
updated_at: 2026-04-18T14:07:00Z
task_id: xc-baoxiao-web-m4-export-failure-state-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: codex/xc-baoxiao-web-m4-export-failure-state-v1
target_repo_ref: 95bb706de73aaccd0820f0facd7a235d98408423
cross_repo: true
size: S2
task_class: T2
related_slices:
  - xc-baoxiao-web-m3-export-review-gate-v1
  - xc-baoxiao-web-m3-review-visibility-v1
---

# xc-baoxiao-web-m4-export-failure-state-v1 (Memory Hint)

## Why this memory card exists

This slice makes the export path fail honestly after task enqueue: a post-enqueue bundle-generation error now finalizes the async task as `FAILED` instead of leaving it stuck in `RUNNING`.

## Completed outcome

- Added a regression test for post-enqueue export failure in `src/server/services/report-service.test.ts`
- `generateBundleForTrip` now calls `completeTask(... FAILED ...)` with the thrown error message before rethrowing
- Standard web gate passed after the change

## Re-entry hint

If the next M4 slice continues export hardening, build on this honest task-state baseline before touching download route or report-center UX.
