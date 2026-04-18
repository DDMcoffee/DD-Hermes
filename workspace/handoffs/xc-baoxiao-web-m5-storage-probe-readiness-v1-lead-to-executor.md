---
handoff_id: xc-baoxiao-web-m5-storage-probe-readiness-v1-lead-to-executor
task_id: xc-baoxiao-web-m5-storage-probe-readiness-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: make M5 readiness honest about whether local storage is actually writable
---

# Handoff: XC BaoXiaoAuto Web M5 Storage Probe Readiness

## Purpose

Remove the current false-positive where `STORAGE_DRIVER=local` automatically counts as ready, even if the configured storage root cannot persist files.

## Instruction Set

1. Work in `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-storage-probe-readiness-v1-lead`.
2. Add a failing test that shows readiness must block when local storage is not writable.
3. Implement the narrowest probe that can tell admin readiness whether local storage is usable.
4. Keep the change inside storage readiness, admin readiness aggregation, and tests.
5. Run focused red-green verification, then the standard web gate.

## Constraints

- Do not implement COS.
- Do not touch the user's six dirty paths on target main.
- Do not land onto `web-main` in this slice.
