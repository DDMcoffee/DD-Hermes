---
schema_version: 2
task_id: xc-baoxiao-web-m5-operational-readiness-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Give XC-BaoXiaoAuto web administrators a concrete readiness view for the next stage, so the system can answer whether it is still local-only or ready for more formal environment validation without guessing.
user_value: Admins can see the current deployment posture, storage posture, async-task pressure, and external-integration status in one place instead of piecing it together from docs and logs.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo M5 slice across admin overview service and UI with clear acceptance and low integration risk, but it changes administrator-facing operational behavior and therefore needs S2 traceability.
non_goals:
  - Do not implement HTTPS, Nginx, or cloud monitoring itself.
  - Do not enable DingTalk or any other external integration.
  - Do not land this branch onto target `web-main` in the same slice.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - Admin overview shows an explicit operational readiness section.
  - The readiness section reflects current app URL posture, storage driver posture, async-task pressure, and DingTalk placeholder status.
  - Regression tests cover the readiness summary logic and overview data shape.
drift_risk: This slice could drift into real deployment work or a broad admin dashboard redesign. Stop once readiness facts are visible and backed by testable summary logic.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: de5ef1fe8b13d6111132a53867f52fcf922b445b
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "sanitized readiness statuses and task counts"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "real production secrets or private URLs beyond configured appBaseUrl scheme/host summary"

acceptance:
  - `admin.overview` exposes the data needed for an operational readiness summary.
  - Admin overview page renders a readable readiness section with current blockers or ready signals.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on the target worktree.
blocked_if:
  - Surfacing readiness facts requires real deployment or infrastructure changes.
  - The slice cannot stay local to admin overview service, helper logic, and page rendering.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m5-operational-readiness-v1.md
---

# Sprint Contract

## Context

With M4 now landed, the next stage is not more export plumbing but operational clarity. The roadmap says M5 should make the web line "适合更正式环境验证", but the current admin overview only shows aggregate counts. It does not answer simple readiness questions like:

- are we still on local HTTP?
- is storage still local-only or already on a formal driver path?
- is DingTalk still placeholder-only?
- is async work currently piling up or failing?

This slice keeps scope on surfacing those facts in the admin overview.

## Scope

- In scope:
  - admin overview data shape for operational readiness
  - a small readiness summary helper with testable logic
  - admin overview page rendering for readiness facts
- Out of scope:
  - real deployment changes
  - enabling external integrations
  - landing / cleanup work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `de5ef1fe8b13d6111132a53867f52fcf922b445b`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m5-operational-readiness-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m5-operational-readiness-v1/state.json`

## Acceptance

- Admin overview explicitly shows current readiness posture.
- The page can honestly answer whether this is still local-only or ready for a more formal environment validation pass.
- Standard web gate passes after the change.

## Product Gate

- This slice stays on roadmap M5's "更正式环境验证前夜".
- Stop if the work expands into real HTTPS / monitoring / DingTalk implementation.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for readiness helper and admin overview service
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m5-operational-readiness-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m5-operational-readiness-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m5-operational-readiness-v1/state.json`

## Open Questions

- None for scope. If a readiness summary helper is needed, keep it pure and small so the admin page only renders facts instead of embedding policy logic.
