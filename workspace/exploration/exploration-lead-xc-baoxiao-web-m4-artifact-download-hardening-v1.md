# Exploration Log: xc-baoxiao-web-m4-artifact-download-hardening-v1

## Observed Gap

- `/api/artifacts/[id]/download` uses `artifact.title` directly as the download filename, but generated titles such as `TRIP-001 报销预览` do not include a file extension.
- The same route lets `storage.readObject(...)` throw straight through, which turns an artifact-storage problem into an unstructured route failure.

## Existing Signals Available

- The route already has `artifact.storageKey`, `artifact.mimeType`, and `artifact.title`.
- Generated artifact storage keys keep the original extension from `keyHint`.
- The app already uses Vitest route tests for other API routes, so this behavior can be locked down without a browser flow.

## Slice Decision

Keep the next M4 step narrow and route-local:

1. add a route test for the missing-extension filename behavior;
2. add a route test for storage-read failure;
3. implement the smallest route helpers needed to derive a usable filename and return explicit failure JSON;
4. leave report generation and UI unchanged.
