---
schema_version: 2
task_id: xc-baoxiao-web-m5-storage-probe-readiness-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Make M5 readiness honest about local storage availability by blocking when the configured local storage root is not writable.
user_value: Operators get a readiness signal that reflects whether uploads and artifact generation can actually persist files, instead of trusting `STORAGE_DRIVER=local` blindly.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo web slice over storage readiness plumbing, admin readiness aggregation, and tests. It changes operational behavior but stays inside an isolated worktree with a narrow write set.
non_goals:
  - Do not implement COS storage.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not change the user's six dirty paths on target `web-main`.
product_acceptance:
  - Readiness blocks when the configured local storage root is not writable.
  - Readiness continues to pass for a writable local storage root.
  - Regression tests cover the new storage-probe readiness behavior.
drift_risk: This slice could drift into general storage refactors or deployment automation. Stop once readiness truth reflects actual local storage writability and the new path is covered by tests.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: d899931e66861530533383cfe7ea40df662b312d
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "sanitized readiness blocker and signal strings"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw secrets from env or local config files"
    - "absolute production-only storage paths outside sanitized examples"

acceptance:
  - Admin readiness no longer marks local storage as ready without probing writability.
  - Storage-probe failures surface as explicit readiness blockers.
  - Standard web gate passes in the isolated worktree.
blocked_if:
  - The storage probe requires invasive driver redesign beyond a narrow readiness check.
  - Existing unrelated gate failures appear in the isolated worktree.
  - The slice expands beyond local storage readiness honesty.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m5-storage-probe-readiness-v1.md
---

# Sprint Contract

## Context

The current M5 readiness summary treats `STORAGE_DRIVER=local` as ready without proving the configured local root can actually accept writes. That is not operationally honest enough for deployment-groundwork. If the local root is missing or unwritable, uploads and export generation will fail despite readiness claiming otherwise.

## Scope

- In scope:
  - add a narrow storage readiness probe for the current driver
  - wire the probe into admin overview and operational readiness
  - cover the new behavior with tests
- Out of scope:
  - COS implementation
  - deployment scripts
  - landing onto local `web-main`

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `d899931e66861530533383cfe7ea40df662b312d`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m5-storage-probe-readiness-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m5-storage-probe-readiness-v1/state.json`

## Acceptance

- Readiness blocks when local storage cannot be written.
- Readiness stays ready when local storage is writable and other blockers are absent.
- The isolated worktree passes `npm run test`, `npm run typecheck`, and `npm run build`.

## Product Gate

- Keep the slice about readiness honesty, not storage architecture expansion.
- If a probe cannot be implemented narrowly, stop and record that instead of widening scope.

## Verification

- Target repo side:
  - focused vitest red-green run for storage readiness behavior
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m5-storage-probe-readiness-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-storage-probe-readiness-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m5-storage-probe-readiness-v1/state.json`

## Open Questions

- None for scope. Prefer a narrow probe helper over a broader storage-driver redesign.
