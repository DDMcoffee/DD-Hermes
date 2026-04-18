---
handoff_id: xc-baoxiao-web-m4-storage-driver-contract-v1-lead-to-executor
task_id: xc-baoxiao-web-m4-storage-driver-contract-v1
from_role: lead
to_role: executor
created_at: 2026-04-19T00:00:00Z
scope: tighten the storage-driver-unavailable contract and surface it at upload/download entrypoints
---

# Handoff: XC BaoXiaoAuto Web M4 Storage Driver Contract

## Purpose

Make storage-driver unavailability a stable boundary contract so upload and download entrypoints return explicit 503 responses instead of leaking raw storage exceptions.

## Instruction Set

1. Use the isolated target worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-storage-driver-contract-v1-lead`.
2. Add failing tests first for:
   - artifact download when storage driver is unavailable
   - file upload when storage driver is unavailable
3. Implement the smallest storage-contract and route changes needed to surface that boundary.
4. Do not implement real COS behavior; only clarify the unavailable-driver contract.
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch the user's six dirty paths on local target `web-main`.
- Do not widen this into deployment or COS implementation work.
- Do not mix landing work into this execution slice.
