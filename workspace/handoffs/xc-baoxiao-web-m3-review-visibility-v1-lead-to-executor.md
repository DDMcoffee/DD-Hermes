---
handoff_id: xc-baoxiao-web-m3-review-visibility-v1-lead-to-executor
task_id: xc-baoxiao-web-m3-review-visibility-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: make review state readable on documents, expenses, and trip detail pages
---

# Handoff: XC BaoXiaoAuto Web M3 Review Visibility

## Purpose

Turn existing review signals into readable product-state on the main M3 review surfaces, so users can tell what still needs attention without interpreting raw backend enums.

## Instruction Set

1. Use the isolated target worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m3-review-visibility-v1-lead`.
2. Write failing tests first for the shared review-display formatting behavior.
3. Implement the smallest shared helper needed to render readable review explanations.
4. Apply that helper to:
   - `documents-page.tsx`
   - `expenses-page.tsx`
   - `trip-detail-page.tsx`
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch parser worker code.
- Do not touch the user's six dirty paths on local target `web-main`.
- Do not widen this into a broader design refresh.
