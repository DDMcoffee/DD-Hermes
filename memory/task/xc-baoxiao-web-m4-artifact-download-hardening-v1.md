---
id: xc-baoxiao-web-m4-artifact-download-hardening-v1
kind: task
status: done
created_at: 2026-04-18T00:00:00Z
updated_at: 2026-04-18T15:02:00Z
task_id: xc-baoxiao-web-m4-artifact-download-hardening-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: codex/xc-baoxiao-web-m4-artifact-download-hardening-v1
target_repo_ref: d7d19cb875f2ff89f70885fe0b1d226578e9b9b3
cross_repo: true
size: S2
task_class: T2
related_slices:
  - xc-baoxiao-web-m4-export-failure-state-v1
  - xc-baoxiao-web-m4-export-failure-state-land-v1
---

# xc-baoxiao-web-m4-artifact-download-hardening-v1 (Memory Hint)

## Why this memory card exists

This slice hardens the artifact download route so the last step of the export path is explicit and usable.

## Completed outcome

- `/api/artifacts/[id]/download` now derives a stable filename with extension from artifact metadata
- Storage-read failures return explicit JSON instead of collapsing into a generic route crash
- Standard web gate passed after the change

## Re-entry hint

If the next M4 slice continues download/export hardening, start from this route-local baseline before expanding into broader UI or storage cleanup.
