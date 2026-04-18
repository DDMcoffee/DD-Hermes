---
handoff_id: xc-baoxiao-web-m5-stale-task-alert-v1-lead-to-executor
task_id: xc-baoxiao-web-m5-stale-task-alert-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: implement stale running task detection for M5 readiness surfaces
---

# Handoff: XC BaoXiaoAuto Web M5 Stale Task Alert

## Purpose

Differentiate normal in-flight async work from likely stuck task execution, using only the task data already present in the repo.

## Instruction Set

1. Use the isolated worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-stale-task-alert-v1-lead`.
2. Write failing tests first for stale-task readiness behavior and service output.
3. Implement the smallest server-side changes needed to surface stale-task posture.
4. Re-run focused tests, then the full web gate.
5. Record execution evidence in DD Hermes state.

## Constraints

- Do not invent a monitoring backend.
- Do not redesign the worker protocol.
- Do not touch target main worktree WIP.
