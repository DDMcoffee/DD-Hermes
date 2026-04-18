# Exploration Log: xc-baoxiao-web-m4-storage-driver-contract-v1

## Observed Gap

- `UnsupportedCosStorageDriver` currently throws raw `Error` instances with a message, but there is no stable contract for callers to classify "storage driver unavailable".
- `/api/artifacts/[id]/download` can only distinguish missing files vs generic failure.
- `/api/uploads` has no explicit storage-unavailable handling path at all.

## Existing Signals Available

- Storage selection already centralizes in `getStorageDriver()`.
- Upload and download entrypoints are narrow and easy to regression-test.
- This slice can stay inside `storage.ts` plus two route files; no schema or COS implementation work is required.

## Slice Decision

Keep the next M4 step narrow:

1. add a stable unavailable-driver error contract in `storage.ts`;
2. map that contract to explicit 503 JSON in upload and download entrypoints;
3. prove the behavior with focused route tests.
