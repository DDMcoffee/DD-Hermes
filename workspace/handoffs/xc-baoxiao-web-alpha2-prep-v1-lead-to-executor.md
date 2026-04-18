---
handoff_id: xc-baoxiao-web-alpha2-prep-v1-lead-to-executor
task_id: xc-baoxiao-web-alpha2-prep-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: target-side alpha.2 integration and release-prep verification
---

# Handoff: XC BaoXiaoAuto Web Alpha.2 Prep

## Purpose

Lead has instantiated the alpha.2 integration slice. Executor lane now creates a clean target-side integration worktree, assembles the completed roadmap and M2 commits, updates version metadata, and re-runs the standard web gate on the combined result.

## Input Commits

- roadmap slice: `7756c9eedea99de4218fff416e5c13882f0c4935`
- M2 test-hardening slice: `ecb92e97c7298918d4681cbf9ec8315d53b4ad04`

## Instruction Set

1. Create a new target-side worktree from clean `web-main`:
   - path: `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-alpha2-prep-v1-lead`
   - branch: `codex/xc-baoxiao-web-alpha2-prep-v1`
2. Cherry-pick the roadmap commit.
3. Cherry-pick the M2 test-hardening commit.
4. Update:
   - `products/web/VERSION` -> `0.1.0-alpha.2`
   - `products/web/CHANGELOG.md` -> add `0.1.0-alpha.2` entry summarizing roadmap + M2 regression hardening
5. Run standard web gate:
   - `npm run test`
   - `npm run typecheck`
   - `npm run build`
6. Commit the integrated branch as a release-prep checkpoint.

## Constraints

- Do not touch the dirty target main worktree.
- Do not pull unrelated WIP into the integration branch.
- Do not create tags or push remotes in this slice.

## Evidence Return Protocol

Return a redacted summary containing:

- worktree path and branch
- cherry-picked commits
- version/changelog files changed
- gate exit codes
- final target commit SHA
