---
schema_version: 2
task_id: xc-baoxiao-web-m4-artifact-download-hardening-v1
from: lead
to: lead
scope: xc-baoxiao-web-m4-artifact-download-hardening-v1 S2 cross-repo completion
execution_commit: f70c59170aa8889df73868bb26fc0ca254424341
target_execution_commit: f70c59170aa8889df73868bb26fc0ca254424341
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: codex/xc-baoxiao-web-m4-artifact-download-hardening-v1
state_path: workspace/state/xc-baoxiao-web-m4-artifact-download-hardening-v1/state.json
context_path: workspace/state/xc-baoxiao-web-m4-artifact-download-hardening-v1/context.json
runtime_path: workspace/state/xc-baoxiao-web-m4-artifact-download-hardening-v1/runtime.json
cross_repo: true
size: S2
task_class: T2
verified_steps:
  - "target-side: added failing route tests for filename extension and storage-read failure"
  - "target-side: hardened artifact download route with derived filename helpers and explicit storage error responses"
  - "target-side: focused vitest run passed for artifact download route"
  - "target-side: npm run test exit 0 (7 files, 20 tests)"
  - "target-side: npm run typecheck exit 0"
  - "target-side: npm run build exit 0"
verified_files:
  - workspace/contracts/_archive/xc-baoxiao-web-m4-artifact-download-hardening-v1.md
  - workspace/handoffs/xc-baoxiao-web-m4-artifact-download-hardening-v1-lead-to-executor.md
  - workspace/exploration/exploration-lead-xc-baoxiao-web-m4-artifact-download-hardening-v1.md
  - workspace/closeouts/xc-baoxiao-web-m4-artifact-download-hardening-v1-lead.md
  - memory/task/xc-baoxiao-web-m4-artifact-download-hardening-v1.md
verified_files_target_side:
  - products/web/apps/web/src/app/api/artifacts/[id]/download/route.ts
  - products/web/apps/web/src/app/api/artifacts/[id]/download/route.test.ts
quality_review_status: degraded-approved
quality_findings_summary:
  - "Artifact downloads now keep a usable filename with extension instead of relying on title-only names that drop the file type."
  - "Storage-read failures now return explicit route errors, so artifact problems no longer collapse into an unstructured route crash."
  - "The slice stayed route-local and did not drift into report generation or reports page UI work."
open_risks:
  - "The same pre-existing Edge Runtime warnings still appear during build, though build exits 0."
  - "This slice does not yet land onto local web-main."
  - "Broader artifact lifecycle cleanup remains separate from download-route hardening."
next_actions:
  - "Archive contract and commit DD Hermes lifecycle artifacts"
  - "Run hooks/quality-gate.sh against the updated state.json"
  - "If continuing M4, either land this branch onto local web-main or take the next export/download hardening slice from here"
---

# Execution Closeout

## Context

After making export generation fail honestly, the next M4 weakness was the final download handoff itself. Generated artifacts were downloaded under title-only names that dropped the extension, and a missing storage object would throw through the route instead of returning a diagnosable response.

## Completion

- Added route tests for success filename behavior and storage-read failure.
- Hardened `/api/artifacts/[id]/download` to derive a usable filename with extension from existing artifact metadata.
- Added explicit JSON error responses for unreadable storage objects.

## Verification

- Focused red-green cycle passed for:
  - `src/app/api/artifacts/[id]/download/route.test.ts`
- `npm run test` passed in `products/web` with `7` test files and `20` tests.
- `npm run typecheck` passed in `products/web`.
- `npm run build` passed in `products/web`.

## Quality Review

- The product gain is at the handoff edge: successful downloads are more usable, and failures are no longer opaque.
- The change stayed route-local and intentionally did not modify report generation or reports page behavior.
- Degraded review is explicitly acknowledged: single-thread execution, no independent skeptic claimed.
