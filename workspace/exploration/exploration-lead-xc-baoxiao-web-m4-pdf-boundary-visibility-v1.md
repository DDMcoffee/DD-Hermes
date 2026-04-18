# Exploration Log: xc-baoxiao-web-m4-pdf-boundary-visibility-v1

## Observed Gap

- `generateBundleForTrip` silently skips PDF when Playwright is unavailable and still marks the task `COMPLETED`.
- Reports page currently only shows `已生成 N 份材料`, so users have to infer that "PDF 没有出来" from a smaller artifact count.

## Existing Signals Available

- Export-task `resultJson` already carries structured completion data.
- `describeReportTaskState` already owns readable export-task wording on the reports page.
- The current slice can stay inside report-service result semantics plus report-task display wording; no schema change is required.

## Slice Decision

Keep the next M4 step narrow:

1. record `pdfGenerated` for completed bundle tasks;
2. optionally record a stable sanitized fallback reason when PDF is skipped;
3. update export-task display wording to explain the no-PDF boundary;
4. prove the result semantics and wording with focused tests.
