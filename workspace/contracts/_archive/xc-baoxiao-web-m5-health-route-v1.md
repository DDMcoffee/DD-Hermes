---
schema_version: 2
task_id: xc-baoxiao-web-m5-health-route-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Give XC-BaoXiaoAuto web a machine-readable operational-readiness snapshot for M5, so environment checks and future monitors can read the same readiness truth that admins see in the UI.
user_value: The web line gains a scriptable readiness surface and clearer blocker wording for formal environment validation, without prematurely implementing real monitoring infrastructure or external integrations.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo web slice across readiness logic, admin service, and one API route. It changes deployment-readiness behavior but stays within an isolated worktree and a narrow write set.
non_goals:
  - Do not implement real HTTPS, cloud monitoring, or DingTalk integration.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - Operational readiness logic accounts for default or placeholder auth secret posture.
  - A dedicated health route exposes a sanitized machine-readable readiness snapshot.
  - Regression tests cover the new readiness rule and route behavior.
drift_risk: This slice could drift into full deployment setup or a broad admin-dashboard redesign. Stop once the readiness snapshot is machine-readable and the new blocker logic is test-backed.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: 4df74ce9931f4a334b997a3145a8ad02d20e2243
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "sanitized readiness labels and blocker wording"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw secret values or .env contents"
    - "raw file contents from target_repo .gitignore-protected paths"

acceptance:
  - `src/lib/operational-readiness.ts` and its tests cover auth-secret readiness.
  - A new readiness health route returns machine-readable readiness JSON.
  - Standard web gate passes on the isolated worktree.
blocked_if:
  - The route would require exposing secrets or sensitive runtime details.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m5-health-route-v1.md
---

# Sprint Contract

## Context

The first M5 slice made readiness visible to admins in the UI, but that truth still cannot be consumed by scripts or future monitors. At the same time, the readiness logic still ignores one real deployment blocker: leaving `AUTH_SECRET` on a development placeholder.

This slice keeps M5 honest by turning readiness into a machine-readable surface and by making auth-secret posture part of the same decision model.

## Scope

- In scope:
  - extend operational-readiness logic with auth-secret posture
  - expose a sanitized readiness health route
  - cover the new behavior with tests
- Out of scope:
  - real monitoring system integration
  - HTTPS or storage-driver rollout work
  - DingTalk or WeCom implementation
  - landing to local `web-main`

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `4df74ce9931f4a334b997a3145a8ad02d20e2243`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m5-health-route-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m5-health-route-v1/state.json`

## Acceptance

- Readiness logic explicitly flags development-placeholder auth secret usage.
- A dedicated route returns machine-readable readiness JSON without leaking secrets.
- The slice stays within M5 readiness and monitoring groundwork.

## Product Gate

- The route must stay sanitized and deployment-focused.
- Stop if the work starts turning into a full operations console or external monitor setup.

## Verification

- Target repo side:
  - focused vitest run for readiness helper, service, and health route
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m5-health-route-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-health-route-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m5-health-route-v1/state.json`

## Open Questions

- Keep the route response coarse enough for monitoring use, but expressive enough to explain why the system is not yet ready.
