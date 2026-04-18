---
handoff_id: xc-baoxiao-web-m3-export-review-gate-v1-lead-to-executor
task_id: xc-baoxiao-web-m3-export-review-gate-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: add export-readiness classification and block report generation when review blockers remain
---

# Handoff: XC BaoXiaoAuto Web M3 Export Review Gate

## Purpose

Turn the existing review signals (`needsReview`, `warning`, `parseStatus`, `parseError`, review match state) into a concrete export gate so reimbursement materials are not generated from unresolved parsing state.

## Instruction Set

1. Create an isolated target worktree from target repo `web-main` at `c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9`.
2. Write failing tests first for:
   - blocker classification / readiness logic
   - `generateBundleForTrip` rejecting blocked trips
3. Implement the smallest shared readiness helper needed by both backend and report entry UI.
4. Update the reports surface to show readiness and blocker reasons before export.
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch the user's six dirty paths on local target `web-main`.
- Do not change parser extraction heuristics or OCR behavior.
- Do not widen the slice into a general review-console redesign.
