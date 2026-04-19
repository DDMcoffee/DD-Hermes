---
schema_version: 2
task_id: xc-baoxiao-web-trip-import-preview-v1
size: S2
owner: lead
experts:
  - lead
product_goal: Add a trip-import flow to XC-BaoXiaoAuto web so users can upload a trip-list screenshot, preview parsed trips, and batch-create selected trips from the trips page.
user_value: Users no longer need to retype trip rows from external systems; they can confirm OCR results first and then create multiple trips in one action.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This slice is a bounded cross-repo feature spanning parser-worker, web API/router/service, and trips UI, but it remains within one product line and one target repo.
non_goals:
  - Do not add a new Trip schema field for round-trip or time-of-day labels.
  - Do not auto-create trips immediately after upload without preview confirmation.
  - Do not change the existing single-screenshot auto-create path.
product_acceptance:
  - Trips page exposes a screenshot-import entry.
  - Uploading a list screenshot returns parsed trip candidates for preview confirmation.
  - Confirmed candidates create trips in batch, with round-trip and AM/PM hints preserved in notes.
drift_risk: This slice would drift if it tried to redesign document ingestion, replace the existing single-screenshot OCR flow, or remodel the Trip schema instead of adding a preview-first import path.
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: both
target_repo_ref: cd61c15d6a2c2d3561fd949d1304f45b21b23247
cross_repo_boundary:
  allowed_back:
    - target-side commit SHA
    - relative changed file paths
    - test/typecheck/build exit codes
    - sanitized parser and UI behavior summaries
  forbidden_back:
    - raw PII (employee names, invoice numbers, amounts, phone, ID, full date)
    - raw secret values or .env contents
    - raw file contents from target_repo .gitignore-protected paths
acceptance:
  - Parser-worker can return multiple preview candidates from a list screenshot without inserting trips.
  - Web layer exposes preview and confirm-create operations for trip import.
  - Trips page supports upload, preview, selection, and batch create.
blocked_if:
  - OCR result structure from the current screenshot format cannot be made stable enough for preview candidates.
  - The new import flow would require a Trip schema migration instead of fitting current fields plus notes.
memory_reads: []
memory_writes:
  - memory/task/xc-baoxiao-web-trip-import-preview-v1.md
---

# Sprint Contract

## Context

The current trips page only supports manual creation. XC-BaoXiaoAuto already has OCR support for a single trip-detail screenshot, but the user’s real workflow includes importing a list screenshot that contains multiple trip rows from another system. That list shape does not fit the current single-screenshot auto-create path.

This slice adds a new preview-first import flow on the trips page. The parser should extract multiple candidates from one screenshot, the user should review the parsed rows before creation, and the final batch-create step should map extra details such as round-trip and AM/PM hints into existing Trip fields plus `notes`.

## Required Fields

- `task_id`
- `size`
- `owner`
- `experts`
- `target_repo`
- `execution_host`
- `target_repo_ref`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Scope

- In scope:
  - parser-worker support for trip-list screenshot preview candidates
  - web-side import preview and confirm-create endpoints
  - trips page upload + preview + selection + batch-create UI
  - regression tests for parser, service/router, and UI helpers where appropriate
- Out of scope:
  - changing the Trip Prisma schema
  - replacing the existing document-page upload flow
  - background auto-creation without explicit user confirmation

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `both`
- `target_repo_ref`: `cd61c15d6a2c2d3561fd949d1304f45b21b23247`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-trip-import-preview-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-trip-import-preview-v1/state.json`

## Acceptance

- List-screenshot OCR returns preview candidates instead of directly inserting trips.
- Confirmed candidates create selected trips into `trip.list` and preserve extra list-only hints in `notes`.
- Standard target-side web gate passes on the implementation branch.

## Product Gate

- Keep the import entry inside trips management and centered on preview-first batch creation.
- Stop if the change starts merging with the existing document-management ingestion flow or requires schema redesign.

## Verification

- Target repo side:
  - focused tests for parser and trip import service/router pieces
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/check-artifact-schemas.sh --task-id xc-baoxiao-web-trip-import-preview-v1`
  - `./hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-trip-import-preview-v1/state.json`

## Open Questions

- None. The preview-first behavior and notes-mapping rule are already fixed by the current conversation.
