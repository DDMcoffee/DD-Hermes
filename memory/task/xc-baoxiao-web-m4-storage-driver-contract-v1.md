---
id: xc-baoxiao-web-m4-storage-driver-contract-v1
kind: task
status: done
created_at: 2026-04-19T00:00:00Z
updated_at: 2026-04-19T01:17:00Z
task_id: xc-baoxiao-web-m4-storage-driver-contract-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: codex/xc-baoxiao-web-m4-storage-driver-contract-v1
target_repo_ref: de5ef1fe8b13d6111132a53867f52fcf922b445b
cross_repo: true
size: S2
task_class: T2
related_slices:
  - xc-baoxiao-web-m4-artifact-download-hardening-v1
  - xc-baoxiao-web-m4-pdf-boundary-visibility-v1
---

# xc-baoxiao-web-m4-storage-driver-contract-v1 (Memory Hint)

## Why this memory card exists

This slice tightens the M4 storage boundary by making driver unavailability explicit and shared across upload and download entrypoints.

## Completed outcome

- `storage.ts` now exposes a stable unavailable-driver contract
- upload and artifact-download entrypoints return explicit 503 JSON when storage is unavailable
- standard web gate passed after the change

## Re-entry hint

If the next M4 slice continues storage or export work, build on this contract instead of adding more route-local string matching for storage failures.
