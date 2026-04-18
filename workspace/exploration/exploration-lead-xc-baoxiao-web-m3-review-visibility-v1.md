# Exploration Log: xc-baoxiao-web-m3-review-visibility-v1

## Observed Gap

- `documents-page.tsx` shows raw `parseStatus` and task status, but not `parseError`, task error, or whether the document still blocks review.
- `expenses-page.tsx` shows `needsReview` and `matchStatus`, but the explanation remains implicit and mixed into a plain `warning` column.
- `trip-detail-page.tsx` still shows mostly raw table values, so the page does not explain why a trip remains in review.

## Existing Signals Available

- `Document`: `parseStatus`, `parseError`, latest task status/error, linked expense
- `Expense`: `needsReview`, `warning`, `matchStatus`
- `Trip`: `needsReview`, related documents, related expenses

## Slice Decision

Keep the next M3 step purely interpretive:

1. define one shared display helper for readable review state;
2. reuse it across documents, expenses, and trip detail;
3. prove the wording logic with a focused unit test.

This keeps the slice aligned with "待复核链路可解释" and avoids expanding into parser work.
