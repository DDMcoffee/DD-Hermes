---
schema_version: 2
task_id: xc-baoxiao-web-m4-storage-driver-contract-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Tighten the XC-BaoXiaoAuto web storage-driver boundary so local-vs-future-COS switching produces stable, explicit behavior instead of leaking raw storage exceptions through upload and download entrypoints.
user_value: When the configured storage driver is unavailable, users get a consistent, actionable 503 response instead of a generic route failure or opaque storage exception.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo behavior slice across storage and API boundary code with low architectural risk, but it changes operational behavior on a roadmap M4 path and therefore needs S2 traceability.
non_goals:
  - Do not implement the real COS storage driver.
  - Do not widen this into deployment or environment-setup work.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - Storage-driver unavailability is represented by a stable contract instead of ad hoc raw errors.
  - Upload and artifact-download entrypoints return explicit 503 JSON when storage is unavailable.
  - Regression tests cover the boundary behavior.
drift_risk: This slice could drift into full COS implementation or a broad error-handling sweep. Stop once storage-driver unavailability is explicitly classified and surfaced at the entrypoints.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: e68b140d5065d98cda6cf551ad404fa254541a48
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "sanitized storage error codes and user-facing status messages"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "real storage-root absolute paths from runtime env"

acceptance:
  - `storage.ts` exposes a stable way to classify driver-unavailable failures.
  - `/api/uploads` returns explicit 503 JSON when storage is unavailable.
  - `/api/artifacts/[id]/download` returns explicit 503 JSON when storage is unavailable.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on the target worktree.
blocked_if:
  - Tightening the storage contract requires real COS implementation work.
  - The slice cannot stay local to storage boundary classification plus upload/download entrypoints.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m4-storage-driver-contract-v1.md
---

# Sprint Contract

## Context

The web line now has more honest export and download behavior, but the storage abstraction still leaks an M4 hole: when the configured driver is unavailable, callers mostly just get raw errors. That means upload and download entrypoints do not yet share a stable contract for "storage is unavailable in this environment".

This slice keeps scope on the contract boundary, not on COS implementation itself.

## Scope

- In scope:
  - stable storage-driver-unavailable error classification
  - explicit 503 handling for upload and artifact-download entrypoints
  - regression tests for those entrypoints
- Out of scope:
  - real COS driver implementation
  - environment setup or deployment work
  - landing / cleanup work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `e68b140d5065d98cda6cf551ad404fa254541a48`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m4-storage-driver-contract-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m4-storage-driver-contract-v1/state.json`

## Acceptance

- Storage-driver unavailability becomes a stable contract instead of a raw string leak.
- Upload and download entrypoints both explain that storage is unavailable.
- Standard web gate passes after the change.

## Product Gate

- This slice stays on roadmap M4's "收紧本地存储与未来 COS 切换的接口约束".
- Stop if the work expands into real COS implementation.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for upload/download storage-unavailable cases
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m4-storage-driver-contract-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-storage-driver-contract-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m4-storage-driver-contract-v1/state.json`

## Open Questions

- None for scope. If a shared helper is needed, keep it inside `storage.ts` so the contract stays single-sourced.
