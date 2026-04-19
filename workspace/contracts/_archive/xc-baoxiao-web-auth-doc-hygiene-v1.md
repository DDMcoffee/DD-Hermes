---
schema_version: 2
task_id: xc-baoxiao-web-auth-doc-hygiene-v1
size: S1
owner: lead
experts:
  - lead
product_goal: Clean up the six leftover XC-BaoXiaoAuto web-main WIP paths against the latest landed baseline, so only current-relevant auth and local-run docs changes remain.
user_value: Maintainers get a clean local web-main with edge-safe auth wiring and runnable local setup docs, instead of carrying ambiguous residue.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo cleanup slice over a small write set on the target repo, with review plus verification but no architecture expansion.
non_goals:
  - Do not push to any remote.
  - Do not reopen roadmap or M5 scope.
  - Do not preserve stale residue that is not justified by the current landed baseline.
product_acceptance:
  - The leftover WIP is reviewed against current web-main and either landed or dropped with justification.
  - Auth middleware uses a shared edge-safe config instead of importing the full auth stack.
  - Local setup docs and app-level env example describe a runnable non-Docker path.
drift_risk: This slice would drift if it reopened broader auth redesign, storage work, or release planning instead of only resolving the existing dirty paths.
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: ec44bf504be0d3fdd45518ba8a9332b99e968a68
cross_repo_boundary:
  allowed_back:
    - target-side commit SHA
    - relative changed file paths
    - git clean/dirty status summary
    - test/typecheck/build exit codes
    - sanitized review findings
  forbidden_back:
    - raw PII (employee names, invoice numbers, amounts, phone, ID, full date)
    - raw secret values or .env contents
    - raw file contents from target_repo .gitignore-protected paths
acceptance:
  - The stale `products/web/packages/db/src/index.ts` residue is either justified or removed.
  - The retained auth and docs changes land onto local target `web-main`.
  - Target-side `npm run test`, `npm run typecheck`, and `npm run build` pass after cleanup.
blocked_if:
  - The retained auth split breaks middleware or NextAuth wiring.
  - The target repo exposes unrelated failures that make the cleanup result ambiguous.
memory_reads: []
memory_writes:
  - memory/task/xc-baoxiao-web-auth-doc-hygiene-v1.md
---

# Sprint Contract

## Context

XC-BaoXiaoAuto `web-main` was already carrying a clean landed M5 baseline, but the main worktree still had six dirty paths that mixed valid unfinished auth/docs cleanup with at least one likely stale residue. That ambiguity made the repository harder to trust because `git status` no longer meant "new work since the last landed slice".

This slice treats the current landed baseline as the source of truth, reviews each leftover path against that baseline, drops what is no longer justified, and lands what still closes a real gap.

## Required Fields

- `task_id`
- `size`
- `owner`
- `experts`
- `target_repo`
- `execution_host`
- `target_repo_ref`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Scope

- In scope: review and resolve `docs/web/README.md`, `products/web/apps/web/src/auth.ts`, `products/web/apps/web/src/middleware.ts`, `products/web/apps/web/.env.example`, `products/web/apps/web/src/auth.config.ts`, and `products/web/packages/db/src/index.ts`
- Out of scope: new auth features, cloud storage work, remote push, and any non-Web product line work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `ec44bf504be0d3fdd45518ba8a9332b99e968a68`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-auth-doc-hygiene-v1-lead-to-lead.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-auth-doc-hygiene-v1/state.json`

## Acceptance

- Only current-relevant WIP survives the review.
- Local `web-main` is clean after landing.
- The retained auth and docs changes are validated by the standard web gate.

## Product Gate

- Stay on "clean latest baseline plus real local-run/auth gap closure", not "broader auth redesign".
- Stop if the target-side verification no longer isolates this residue cleanup from unrelated failures.

## Verification

- Target repo side:
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/check-artifact-schemas.sh --task-id xc-baoxiao-web-auth-doc-hygiene-v1`

## Open Questions

- None. The only open decision in this slice is whether each dirty path still matches the current baseline, and that is resolved by review plus gate results.
