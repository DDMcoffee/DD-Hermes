---
id: xc-baoxiao-web-trip-import-preview-v1
kind: task
status: done
created_at: 2026-04-19T07:28:31Z
updated_at: 2026-04-19T07:28:31Z
task_id: xc-baoxiao-web-trip-import-preview-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: web-main
target_repo_ref: 5e1477784822236a6e4617d12117a35f567cd567
cross_repo: true
size: S2
task_class: T2
related_slices:
  - xc-baoxiao-web-auth-doc-hygiene-v1
---

# xc-baoxiao-web-trip-import-preview-v1 (Memory Hint)

## Why this memory card exists

This slice adds the first preview-first trip import path on the web line, specifically for multi-row list screenshots from external trip systems.

## Completed outcome

- trips page now supports `导入截图`
- upload kind `trip_list_screenshot` uses OCR to produce preview candidates instead of auto-creating trips
- selected preview rows create trips in batch
- `往返` and `上午/下午` details are preserved in `notes`
- local `web-main` advanced to `5e1477784822236a6e4617d12117a35f567cd567`

## Re-entry hint

If later iterations need to improve OCR quality, start from parser fixtures and worker behavior first; the preview-confirm UI contract is already in place.
