# Exploration Log: xc-baoxiao-web-m4-report-task-visibility-v1

## Observed Gap

- Reports page only shows export readiness and artifacts; it does not show the latest `GENERATE_BUNDLE` task state.
- Backend task state is now honest (`FAILED`, `RUNNING`, etc.), but that operational truth is still not visible where users trigger exports.

## Existing Signals Available

- `Trip` already has a `tasks` relation.
- `AsyncTask` already stores `taskType`, `status`, `errorMsg`, and `resultJson`.
- Existing `review-display.ts` already has readable task-status wording that can be reused.

## Slice Decision

Keep the next M4 step narrow:

1. expose the latest `GENERATE_BUNDLE` task on `trip.list`;
2. define one small helper for export-task display text;
3. render that state on the reports page;
4. prove the wording and query shape with focused tests.
