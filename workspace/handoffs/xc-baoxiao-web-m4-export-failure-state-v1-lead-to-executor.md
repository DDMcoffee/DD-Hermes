---
handoff_id: xc-baoxiao-web-m4-export-failure-state-v1-lead-to-executor
task_id: xc-baoxiao-web-m4-export-failure-state-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: make post-enqueue bundle-generation failures complete the async task as FAILED
---

# Handoff: XC BaoXiaoAuto Web M4 Export Failure State

## Purpose

Make the export path fail honestly. Once `generateBundleForTrip` has created a `GENERATE_BUNDLE` task, any later failure should leave a durable `FAILED` record instead of a stale `RUNNING` task.

## Instruction Set

1. Use the isolated target worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-export-failure-state-v1-lead`.
2. Add a failing test first for the post-enqueue failure path in `report-service.test.ts`.
3. Implement the smallest service change needed to:
   - call `completeTask(task.id, { status: "FAILED", error: ... })`
   - preserve the thrown error message for the caller
4. Keep the success path behavior unchanged.
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch the user's six dirty paths on local target `web-main`.
- Do not widen this into report-center UI work.
- Do not mix landing work into this execution slice.
