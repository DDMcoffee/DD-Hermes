---
schema_version: 2
from: lead
to: lead
scope: xc-baoxiao-web-trip-import-preview-v1 cross-repo execution slice
product_rationale: The product gap is still in trips management itself: users can OCR single screenshots indirectly, but they cannot import a multi-row trip list from the place they actually manage trips.
goal_drift_risk: The task would drift if it turned into a general document-ingestion redesign or a new Trip schema project instead of a preview-first trip import slice.
user_visible_outcome: A user can upload a list screenshot from the trips page, review parsed rows, and create selected trips in batch without retyping them.
files:
  - services/parser-worker/app/parsers/screenshot_parser.py
  - services/parser-worker/app/tasks.py
  - services/parser-worker/app/db.py
  - services/parser-worker/tests/test_parsers.py
  - products/web/apps/web/src/server/services/trip-service.ts
  - products/web/apps/web/src/server/routers/trip.ts
  - products/web/apps/web/src/components/trips/trips-page.tsx
  - products/web/apps/web/src/server/services/trip-service.test.ts
  - products/web/apps/web/src/server/routers/trip import tests or equivalent target-side tests
decisions:
  - Do not reuse the existing single-screenshot auto-create path for list screenshots.
  - Preserve round-trip and AM/PM details by appending them into notes.
  - Keep the flow preview-first: upload and parse do not create trips until explicit confirmation.
risks:
  - OCR text from list screenshots can be noisier than the single-trip parser currently assumes.
  - The slice is single-threaded and uses degraded review.
next_checks:
  - Write failing tests first for multi-row screenshot parsing and preview/confirm behavior.
  - Keep new import logic separate from the old auto-create screenshot path.
  - Re-run full target-side web gate before landing.
---

# Lead Handoff

## Context

The target repo already supports manual trip creation and OCR-driven single-screenshot trip insertion, but the user needs a list-screenshot import path with preview confirmation. This execution slice should add a new path, not mutate the old one into ambiguous mixed behavior.

## Required Fields

- `from`
- `to`
- `scope`
- `product_rationale`
- `goal_drift_risk`
- `user_visible_outcome`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Trips page exposes a preview-first screenshot import flow.
- Parser-worker supports multi-row list screenshot candidates.
- Batch creation uses only the selected preview rows.

## Product Check

- Stay inside the trips page and current Trip schema, with notes as the only overflow field for list-only detail.

## Verification

- red-green parser tests for list screenshot parsing
- target-side focused tests for import preview and batch create
- `npm run test`
- `npm run typecheck`
- `npm run build`

## Open Questions

- None.
