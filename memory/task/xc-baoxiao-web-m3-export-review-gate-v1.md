---
id: xc-baoxiao-web-m3-export-review-gate-v1
kind: task
status: done
created_at: 2026-04-18T00:00:00Z
updated_at: 2026-04-18T13:45:00Z
task_id: xc-baoxiao-web-m3-export-review-gate-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: codex/xc-baoxiao-web-m3-export-review-gate-v1
target_repo_ref: c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9
cross_repo: true
size: S2
task_class: T2
related_slices:
  - xc-baoxiao-web-alpha2-land-v1
---

# xc-baoxiao-web-m3-export-review-gate-v1 (Memory Hint)

## Why this memory card exists

This slice establishes the first real M3 safety rule for the web line: unresolved review blockers must stop bundle export, and the reason set must be visible before export is attempted.

## Completed outcome

- Added `src/lib/report-readiness.ts` as one shared blocker classifier for trip/document/expense review state
- `generateBundleForTrip` now rejects blocked trips instead of generating artifacts unconditionally
- `reports-page.tsx` now shows export readiness and blocker reasons
- Standard web gate passed after the change

## Re-entry hint

If the next slice continues M3, start from this branch or its landed descendant and keep building on the same rule: uncertainty should become explicit product-state, not hidden implementation detail.
