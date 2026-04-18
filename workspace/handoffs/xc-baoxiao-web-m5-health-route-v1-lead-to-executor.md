---
handoff_id: xc-baoxiao-web-m5-health-route-v1-lead-to-executor
task_id: xc-baoxiao-web-m5-health-route-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: implement a machine-readable M5 readiness route and extend readiness logic with auth-secret posture
---

# Handoff: XC BaoXiaoAuto Web M5 Health Route

## Purpose

Turn the current admin-only readiness view into a scriptable readiness snapshot, while adding one real deployment blocker that the UI slice did not yet encode.

## Instruction Set

1. Use the isolated worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-health-route-v1-lead`.
2. Write failing tests first for auth-secret readiness and the new route.
3. Implement the smallest server-side changes needed to expose sanitized readiness JSON.
4. Re-run focused tests, then the full web gate.
5. Record execution evidence in DD Hermes state.

## Constraints

- Do not expose raw secret values.
- Do not implement real external monitoring or deployment plumbing.
- Do not touch target main worktree WIP.
