---
handoff_id: xc-baoxiao-web-m4-pdf-boundary-visibility-v1-lead-to-executor
task_id: xc-baoxiao-web-m4-pdf-boundary-visibility-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: make the export HTML/PDF boundary explicit in task result and UI wording
---

# Handoff: XC BaoXiaoAuto Web M4 PDF Boundary Visibility

## Purpose

Make completed export tasks explain whether a PDF was generated. Users should be able to tell when the current environment only produced HTML instead of silently inferring that from artifact count.

## Instruction Set

1. Use the isolated target worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-pdf-boundary-visibility-v1-lead`.
2. Add failing tests first for:
   - completed export-task wording when PDF is unavailable
   - completed task result semantics from `generateBundleForTrip`
3. Implement the smallest service and display changes needed to surface that boundary.
4. Keep wording product-facing; do not expose raw Playwright internals unless no stable summary exists.
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch the user's six dirty paths on local target `web-main`.
- Do not widen this into storage-driver redesign or landing work.
- Do not change download-route behavior in this slice.
