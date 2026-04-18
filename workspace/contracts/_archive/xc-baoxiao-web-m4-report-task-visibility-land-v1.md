---
schema_version: 2
task_id: xc-baoxiao-web-m4-report-task-visibility-land-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Advance local XC-BaoXiaoAuto `web-main` to the verified M4 report-task-visibility commit while preserving the user's unrelated uncommitted WIP.
user_value: The latest export-task visibility becomes the real local web baseline, without consuming or overwriting the user's unfinished edits.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo landing step with temporary WIP preservation, branch movement, and post-landing verification. It is operationally sensitive enough for S2 traceability but does not require architecture-scale exploration.
non_goals:
  - Do not push remote branches or tags.
  - Do not modify the substance of the user's existing six-path WIP.
  - Do not add new product work beyond landing the verified M4 report-task-visibility slice on local `web-main`.
product_acceptance:
  - Local `web-main` advances from `f70c59170aa8889df73868bb26fc0ca254424341` to `2a6293508e9efd521073b5604f02f3660315e2b1`.
  - The user's pre-existing six-path WIP is restored after the fast-forward.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on local `web-main` after landing.
drift_risk: This slice could drift into branch cleanup, release prep, or follow-on M4 work. Stop if WIP restoration is not clean or if landing would touch unrelated dirty files.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: 2a6293508e9efd521073b5604f02f3660315e2b1
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "dirty-path count and restored path names"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - Local `web-main` fast-forwards to `2a6293508e9efd521073b5604f02f3660315e2b1`.
  - The original six dirty paths are restored after landing.
  - Standard web gate passes on local `web-main`.
blocked_if:
  - The landing cannot be expressed as a clean fast-forward from local `web-main`.
  - Restoring the user's WIP after the merge is not clean.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m4-report-task-visibility-land-v1.md
---

# Sprint Contract

## Context

The M4 report-task-visibility slice already exists as a verified side branch commit. The next operational step is to make that reports-page visibility the actual local `web-main` baseline, while preserving the same six unrelated uncommitted edits that already exist on the target main worktree.

This slice changes branch state, not product scope. It only lands the already-verified payload and reruns the standard web gate on the landed baseline.

## Scope

- In scope:
  - protect the six-path dirty `web-main` worktree
  - fast-forward local `web-main` to `2a6293508e9efd521073b5604f02f3660315e2b1`
  - rerun standard web gate on landed `web-main`
  - record DD Hermes landing evidence
- Out of scope:
  - new product work
  - remote push / PR / tag creation
  - worktree cleanup

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `2a6293508e9efd521073b5604f02f3660315e2b1`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m4-report-task-visibility-land-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m4-report-task-visibility-land-v1/state.json`

## Acceptance

- Local `web-main` becomes the verified M4 report-task-visibility baseline.
- The same six-path WIP survives intact.
- Standard web gate still passes after landing.

## Product Gate

- This slice stays purely on local baseline advancement.
- Stop if the work expands into cleanup or new reports behavior.

## Verification

- Target repo side:
  - `git stash push -u`
  - `git merge --ff-only codex/xc-baoxiao-web-m4-report-task-visibility-v1`
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
  - `git stash pop`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m4-report-task-visibility-land-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m4-report-task-visibility-land-v1/state.json`

## Open Questions

- None for scope. If the fast-forward is blocked, stop and treat that as the landing result.
