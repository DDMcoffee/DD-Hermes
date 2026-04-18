---
schema_version: 2
task_id: xc-baoxiao-web-m5-stale-task-alert-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Give XC-BaoXiaoAuto web an explicit M5 signal for stale running tasks, so administrators can distinguish normal queue pressure from likely stuck worker or async-task execution.
user_value: The web line gains a concrete pre-monitoring alert for stuck work, improving confidence before more formal environment validation without prematurely wiring real monitoring infrastructure.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo web slice across readiness logic, admin service, and tests. It changes deployment-readiness behavior but stays within an isolated worktree and a narrow write set.
non_goals:
  - Do not implement a real monitoring backend or notification system.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - Admin readiness logic distinguishes stale running tasks from normal running tasks.
  - A stale-task signal is exposed through the same overview and health-route surfaces.
  - Regression tests cover the stale-task detection rule and service shape.
drift_risk: This slice could drift into generic dashboard expansion or production monitoring work. Stop once stale-task detection is visible and test-backed.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: 43446505f03a382fe57f8ea837cf744019f0ca27
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "sanitized stale-task blocker wording"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw secret values or .env contents"
    - "raw file contents from target_repo .gitignore-protected paths"

acceptance:
  - `src/lib/operational-readiness.ts` and tests cover stale running task posture.
  - `src/server/services/admin-service.ts` exposes stale task count for readiness consumers.
  - Standard web gate passes on the isolated worktree.
blocked_if:
  - The stale-task rule needs raw monitoring data that does not exist in repo truth sources.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m5-stale-task-alert-v1.md
---

# Sprint Contract

## Context

M5 now has a machine-readable readiness route, but it still cannot tell the difference between healthy in-flight work and likely stuck async execution. For a pre-monitoring milestone, that is a meaningful blind spot: a queue with one genuinely stale running task should not look the same as a queue that is merely busy.

This slice adds a narrow stale-task detection rule and feeds it into the existing readiness surfaces.

## Scope

- In scope:
  - detect stale running tasks from existing async-task timestamps
  - feed stale-task count into readiness logic
  - cover the new behavior with tests
- Out of scope:
  - external alert delivery
  - worker heartbeat protocol redesign
  - landing to local `web-main`

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `43446505f03a382fe57f8ea837cf744019f0ca27`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m5-stale-task-alert-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m5-stale-task-alert-v1/state.json`

## Acceptance

- Running tasks that have not updated within the defined stale window are surfaced as explicit readiness blockers.
- Normal running tasks still show as signals, not blockers.
- The health route and admin readiness view stay aligned through shared service/helper logic.

## Product Gate

- Keep the rule coarse and explainable.
- Stop if the work expands into generic monitoring platform work.

## Verification

- Target repo side:
  - focused vitest run for readiness helper and admin-service
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m5-stale-task-alert-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-stale-task-alert-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m5-stale-task-alert-v1/state.json`

## Open Questions

- Use a fixed stale threshold that is easy to reason about; avoid turning this slice into worker-heartbeat protocol work.
