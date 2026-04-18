---
id: xc-baoxiao-web-m2-core-gates-v1
kind: task
status: done
created_at: 2026-04-18T00:00:00Z
updated_at: 2026-04-18T13:15:36Z
task_id: xc-baoxiao-web-m2-core-gates-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: web-main
target_repo_ref: a6619de50df5474233cbe8a33b718817950fb196
cross_repo: true
size: S2
task_class: T2
related_slices:
  - xc-baoxiao-web-gate-green-v1
  - xc-baoxiao-web-docs-roadmap-v1
related_memory:
  - memory/user/user-pref-xc-baoxiao-integrations-placeholder.md
  - memory/self/recalibration-2026-04-18-learnings.md
---

# xc-baoxiao-web-m2-core-gates-v1 (Memory Hint)

## Why this memory card exists

This slice translates roadmap M2 into a real cross-repo test-hardening task. It does not expand the product surface; it thickens the current regression signal around the existing manual-upload workflow.

## Key facts to remember

- Target repo main worktree is still dirty; execution must stay inside a dedicated target-side worktree.
- Preferred test focus is service/route regression coverage, not broad Playwright expansion.
- Current high-value chains are upload, task visibility, and report bundle generation.

## Success shape

- More than one narrow utility test exists.
- The web gate still passes after adding regression tests.

## Completed outcome

- Target-side worktree branch: `codex/xc-baoxiao-web-m2-core-gates-v1`
- Target-side commit: `ecb92e97c7298918d4681cbf9ec8315d53b4ad04`
- Added coverage for:
  - `src/app/api/jobs/[id]/route.test.ts`
  - `src/server/services/document-service.test.ts`
  - `src/server/services/report-service.test.ts`
- Minimal non-test production change: `products/web/apps/web/vitest.config.ts` gained workspace alias resolution for `@xc/contracts` and `@xc/db`.
