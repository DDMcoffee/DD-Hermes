---
handoff_id: xc-baoxiao-web-m5-operational-readiness-v1-lead-to-executor
task_id: xc-baoxiao-web-m5-operational-readiness-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: expose operational readiness facts on the admin overview page
---

# Handoff: XC BaoXiaoAuto Web M5 Operational Readiness

## Purpose

Make the admin overview answer whether the current web line is still local-only or ready for more formal environment validation, using system facts instead of narrative docs.

## Instruction Set

1. Use the isolated target worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-operational-readiness-v1-lead`.
2. Add failing tests first for:
   - operational readiness summary logic
   - admin overview data shape needed by the page
3. Implement the smallest service and page changes needed to surface readiness facts.
4. Keep DingTalk as placeholder-only; do not enable any external integration.
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch the user's six dirty paths on local target `web-main`.
- Do not widen this into actual deployment work.
- Do not mix landing work into this execution slice.
