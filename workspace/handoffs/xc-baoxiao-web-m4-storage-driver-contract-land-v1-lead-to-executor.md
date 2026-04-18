---
handoff_id: xc-baoxiao-web-m4-storage-driver-contract-land-v1-lead-to-executor
task_id: xc-baoxiao-web-m4-storage-driver-contract-land-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: land the verified M4 storage-driver-contract branch onto local web-main without losing the user's existing WIP
---

# Handoff: XC BaoXiaoAuto Web M4 Storage Driver Contract Landing

## Purpose

Make the tightened storage-driver boundary the real local `web-main` baseline, while preserving the user's existing unfinished edits.

## Instruction Set

1. Use the target main worktree at `/Volumes/Coding/XC-BaoXiaoAuto`.
2. Record the current six-path dirty baseline before landing.
3. Fast-forward `web-main` with `git merge --ff-only codex/xc-baoxiao-web-m4-storage-driver-contract-v1`.
4. Run `npm run test`, `npm run typecheck`, and `npm run build` in `products/web`.
5. Confirm the same six dirty paths remain after landing.
6. Record the landing evidence in DD Hermes state.

## Constraints

- Do not push anything.
- Do not alter the content of the user's six dirty paths.
- Do not mix in any follow-on M5 work during landing.
