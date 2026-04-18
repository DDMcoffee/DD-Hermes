---
handoff_id: xc-baoxiao-web-m3-export-review-gate-land-v1-lead-to-executor
task_id: xc-baoxiao-web-m3-export-review-gate-land-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: land M3 export-review-gate onto local web-main while preserving existing WIP
---

# Handoff: XC BaoXiaoAuto Web M3 Export Review Gate Land

## Purpose

Land the already-verified M3 export-review-gate commit onto the actual local `web-main` branch in XC-BaoXiaoAuto, without losing the user's six existing uncommitted edits.

## Instruction Set

1. Record current `git status --short` and `HEAD`.
2. `git stash push -u` the six-path WIP with a slice-specific message.
3. `git merge --ff-only codex/xc-baoxiao-web-m3-export-review-gate-v1` on local `web-main`.
4. Run:
   - `npm run test`
   - `npm run typecheck`
   - `npm run build`
5. `git stash pop` to restore the original WIP.
6. Record final `HEAD` and restored dirty paths.

## Constraints

- Do not modify the substance of the restored WIP.
- Do not push, tag, or create remote refs.
- Stop immediately if stash restoration conflicts.
