---
handoff_id: xc-baoxiao-web-m4-artifact-download-hardening-v1-lead-to-executor
task_id: xc-baoxiao-web-m4-artifact-download-hardening-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: harden the artifact download route with stable filenames and explicit storage failure responses
---

# Handoff: XC BaoXiaoAuto Web M4 Artifact Download Hardening

## Purpose

Make the artifact download route more honest and usable by preserving file extensions in downloaded filenames and returning explicit errors when stored objects are unavailable.

## Instruction Set

1. Use the isolated target worktree at `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-artifact-download-hardening-v1-lead`.
2. Add failing tests first for:
   - success response headers including a usable filename with extension
   - storage-read failure returning explicit JSON
3. Implement the smallest route-local helpers needed to pass those tests.
4. Keep report generation and reports page code untouched.
5. Run the standard web gate and record the results in DD Hermes state.

## Constraints

- Do not touch the user's six dirty paths on local target `web-main`.
- Do not widen this into report-center UI work.
- Do not mix landing work into this execution slice.
