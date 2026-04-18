---
handoff_id: xc-baoxiao-web-m4-report-task-visibility-v1-lead-to-executor
task_id: xc-baoxiao-web-m4-report-task-visibility-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: surface the latest export-task state on the reports page
---

# Handoff: XC BaoXiaoAuto Web M4 Report Task Visibility

## Purpose

Make the reports page explain the latest export task state, so users can tell whether report generation is pending, running, failed, or completed without inferring it from missing artifacts.

## Instruction Set

1. Use the isolated target worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-report-task-visibility-v1-lead`.
2. Add failing tests first for:
   - latest export-task display wording
   - trip-list query shape needed by reports page
3. Implement the smallest query and UI changes needed to surface that state.
4. Reuse existing readable task-status wording where possible.
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch the user's six dirty paths on local target `web-main`.
- Do not widen this into a broader reports-page redesign.
- Do not mix landing work into this execution slice.
