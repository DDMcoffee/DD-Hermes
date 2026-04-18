# Exploration Log: xc-baoxiao-web-m3-export-review-gate-v1

## Observed Gap

- `products/web/apps/web/src/server/services/report-service.ts` currently exports bundle artifacts as long as the trip exists; no readiness guard checks `trip.needsReview`, expense warnings, match state, or document parse failures.
- `products/web/apps/web/src/components/reports/reports-page.tsx` shows only trip status plus a `生成材料` button, so the user cannot see why a trip is still unsafe to export.

## Available Signals Already In Repo

- Parser worker writes `parseStatus` and `parseError` on `Document`.
- Expense parsing writes `needsReview` and `warning`.
- Auto-match writes `matchStatus`, where `REVIEW` and `UNMATCHED` already imply unresolved matching work.
- Trip detail already stores `needsReview`, but report generation ignores it.

## Slice Decision

Instead of expanding into parser-quality tuning, this slice will make the product honest about readiness:

1. classify export blockers from existing trip / document / expense signals;
2. block export in backend;
3. expose blocker reasons at the report entry surface.

This keeps scope inside M3's "safe landing under uncertainty" line and avoids a larger parser or review-dashboard project.
