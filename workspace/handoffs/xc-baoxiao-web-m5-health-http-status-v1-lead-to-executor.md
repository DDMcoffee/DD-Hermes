---
handoff_id: xc-baoxiao-web-m5-health-http-status-v1-lead-to-executor
task_id: xc-baoxiao-web-m5-health-http-status-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: align M5 operational-readiness route HTTP status with readiness state
---

# Handoff: XC BaoXiaoAuto Web M5 Health HTTP Status

## Purpose

Make the readiness route directly consumable by simple monitors by mapping `ready` and `blocked` to different HTTP statuses.

## Instruction Set

1. Use the isolated worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-health-http-status-v1-lead`.
2. Write failing tests first for blocked and ready route status behavior.
3. Implement the smallest route change needed to satisfy those tests.
4. Re-run focused tests, then the full web gate.
5. Record execution evidence in DD Hermes state.

## Constraints

- Do not redesign the route payload.
- Do not implement a monitoring backend.
- Do not touch target main worktree WIP.
