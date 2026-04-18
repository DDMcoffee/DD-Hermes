---
schema_version: 2
task_id: xc-baoxiao-web-m4-storage-driver-contract-v1
from: lead
to: lead
scope: xc-baoxiao-web-m4-storage-driver-contract-v1 S2 cross-repo completion
execution_commit: de5ef1fe8b13d6111132a53867f52fcf922b445b
target_execution_commit: de5ef1fe8b13d6111132a53867f52fcf922b445b
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: codex/xc-baoxiao-web-m4-storage-driver-contract-v1
state_path: workspace/state/xc-baoxiao-web-m4-storage-driver-contract-v1/state.json
context_path: workspace/state/xc-baoxiao-web-m4-storage-driver-contract-v1/context.json
runtime_path: workspace/state/xc-baoxiao-web-m4-storage-driver-contract-v1/runtime.json
cross_repo: true
size: S2
task_class: T2
verified_steps:
  - "target-side: added failing tests for storage-driver-unavailable behavior on artifact download and upload routes"
  - "target-side: introduced a stable storage-driver-unavailable error contract in storage.ts"
  - "target-side: updated artifact download route to return explicit 503 JSON when storage is unavailable"
  - "target-side: updated upload route to return explicit 503 JSON when storage is unavailable"
  - "target-side: focused vitest run passed for upload/download route coverage"
  - "target-side: npm run test exit 0 (10 files, 28 tests)"
  - "target-side: npm run typecheck exit 0"
  - "target-side: npm run build exit 0"
verified_files:
  - workspace/contracts/_archive/xc-baoxiao-web-m4-storage-driver-contract-v1.md
  - workspace/handoffs/xc-baoxiao-web-m4-storage-driver-contract-v1-lead-to-executor.md
  - workspace/exploration/exploration-lead-xc-baoxiao-web-m4-storage-driver-contract-v1.md
  - workspace/closeouts/xc-baoxiao-web-m4-storage-driver-contract-v1-lead.md
  - memory/task/xc-baoxiao-web-m4-storage-driver-contract-v1.md
verified_files_target_side:
  - products/web/apps/web/src/server/lib/storage.ts
  - products/web/apps/web/src/app/api/artifacts/[id]/download/route.ts
  - products/web/apps/web/src/app/api/artifacts/[id]/download/route.test.ts
  - products/web/apps/web/src/app/api/uploads/route.ts
  - products/web/apps/web/src/app/api/uploads/route.test.ts
quality_review_status: degraded-approved
quality_findings_summary:
  - "Storage-driver unavailability is now a stable contract rather than a raw string-only failure mode."
  - "Upload and artifact-download entrypoints now converge on the same explicit 503 behavior when storage is unavailable."
  - "The slice stayed within roadmap M4's storage boundary tightening and did not drift into COS implementation."
open_risks:
  - "The same pre-existing Edge Runtime warnings still appear during build, though build exits 0."
  - "This slice does not yet land onto local web-main."
  - "Report generation still surfaces storage-driver failures through task failure messages, but that path was not expanded in this slice."
next_actions:
  - "Archive contract and commit DD Hermes lifecycle artifacts"
  - "Run hooks/quality-gate.sh against the updated state.json"
  - "If continuing M4, either land this branch onto local web-main or evaluate whether M4 can be declared locally complete"
---

# Execution Closeout

## Context

After clarifying export-task visibility and the HTML/PDF boundary, the remaining M4 storage gap was not implementation of COS itself but the interface contract when storage is unavailable. Upload and download entrypoints still leaked raw storage failures instead of sharing one explicit boundary.

## Completion

- Added a stable storage-driver-unavailable error contract in `storage.ts`.
- Updated artifact download to return explicit 503 JSON when storage is unavailable.
- Updated upload route to return the same explicit 503 JSON when storage is unavailable.
- Added regression coverage for both entrypoints.

## Verification

- Focused red-green cycle passed for:
  - `src/app/api/artifacts/[id]/download/route.test.ts`
  - `src/app/api/uploads/route.test.ts`
- `npm run test` passed in `products/web` with `10` test files and `28` tests.
- `npm run typecheck` passed in `products/web`.
- `npm run build` passed in `products/web`.

## Quality Review

- The product gain is contract clarity: storage-driver unavailability now has a stable operational meaning instead of depending on route-local guesswork.
- Upload and download behave consistently without pretending COS is already implemented.
- Degraded review is explicitly acknowledged: single-thread execution, no independent skeptic claimed.
