# Exploration Log: xc-baoxiao-web-m4-export-failure-state-v1

## Observed Gap

- `generateBundleForTrip` enqueues a `GENERATE_BUNDLE` task before any artifact writes happen.
- If storage or artifact creation fails after enqueue, the function throws without calling `completeTask(... FAILED ...)`.
- Dashboard and admin surfaces count `RUNNING` tasks, so this leaves an operationally dishonest state: the export is already dead, but the task still looks in progress.

## Existing Signals Available

- `completeTask` already supports `FAILED` with `error`.
- The mutation surface already surfaces thrown error messages back to the client.
- The existing report-service tests already mock `enqueueTask`, `completeTask`, storage saves, and DB writes.

## Slice Decision

Keep the next M4 step purely about honest async-task state:

1. add a failing test for a post-enqueue export error;
2. catch that failure inside `generateBundleForTrip`;
3. mark the task `FAILED` with the error text, then rethrow;
4. leave the success path and artifact payload unchanged.
