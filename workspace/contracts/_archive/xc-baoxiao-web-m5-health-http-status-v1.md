---
schema_version: 2
task_id: xc-baoxiao-web-m5-health-http-status-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Make the M5 operational-readiness route usable by basic monitoring and smoke checks by aligning HTTP status with readiness state.
user_value: Operators and future monitors can distinguish ready vs blocked state without parsing JSON only, improving the practical value of the existing readiness route before any external integration work begins.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo web slice over a single API route and its tests. It changes externally observable readiness behavior but stays in an isolated worktree with a narrow write set.
non_goals:
  - Do not implement a monitoring backend or alert delivery.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - `/api/health/operational-readiness` returns `503` when readiness status is blocked.
  - The same route returns `200` when readiness status is ready.
  - Regression tests cover both status-code paths.
drift_risk: This slice could drift into generic healthcheck redesign or monitoring-platform work. Stop once HTTP status semantics match readiness state and tests cover both cases.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: f9c891f3bf9504146f0e831f302f550b72920e8c
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "health route status-code semantics"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw secret values or .env contents"
    - "raw file contents from target_repo .gitignore-protected paths"

acceptance:
  - route test covers both blocked and ready responses.
  - health route status code reflects readiness status.
  - standard web gate passes on the isolated worktree.
blocked_if:
  - Changing route status would break an existing documented contract discovered in repo truth sources.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m5-health-http-status-v1.md
---

# Sprint Contract

## Context

The readiness route now exposes useful JSON, but for M5 "monitoring eve" it still forces every consumer to parse body content before distinguishing ready from blocked. A basic health endpoint should communicate that coarse state directly through HTTP semantics.

This slice keeps the payload intact and only upgrades the route contract so blocked readiness returns a non-2xx status.

## Scope

- In scope:
  - add red tests for blocked vs ready route status
  - update the route to map readiness status to HTTP status
  - rerun full web gate on the isolated worktree
- Out of scope:
  - payload schema redesign
  - external monitor integration
  - landing to local `web-main`

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `f9c891f3bf9504146f0e831f302f550b72920e8c`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m5-health-http-status-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m5-health-http-status-v1/state.json`

## Acceptance

- Basic monitors can use the route status code without losing the existing JSON payload.
- The route stays narrow and does not expand into a new healthcheck protocol.

## Product Gate

- Keep the route semantics explainable: `ready -> 200`, `blocked -> 503`.
- Stop if the work starts inventing extra status categories or a new health payload format.

## Verification

- Target repo side:
  - focused vitest run for the health route
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m5-health-http-status-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-health-http-status-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m5-health-http-status-v1/state.json`

## Open Questions

- None for scope. Use the existing readiness status values and avoid introducing new route-level states.
