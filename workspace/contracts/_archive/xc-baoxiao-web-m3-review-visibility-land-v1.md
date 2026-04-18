---
schema_version: 2
task_id: xc-baoxiao-web-m3-review-visibility-land-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Advance local XC-BaoXiaoAuto `web-main` to the verified M3 review-visibility commit while preserving the user's unrelated uncommitted WIP.
user_value: The readable M3 review-state surfaces stop being isolated on a side branch and become the actual local `web-main` baseline, without losing current unfinished edits.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo landing step with branch movement, temporary WIP preservation, and gate re-verification; sensitive enough for S2, but not an architecture-scale task.
non_goals:
  - Do not push remote branches or tags.
  - Do not modify the substance of the user's existing six-path WIP.
  - Do not add new product work beyond landing the M3 review-visibility slice on local `web-main`.
product_acceptance:
  - Local `web-main` advances from `1f4a53998d6482d703f84e8d4a07c83423045f1d` to `95bb706de73aaccd0820f0facd7a235d98408423`.
  - The user's pre-existing WIP is restored after the fast-forward.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on local `web-main` after landing.
  - DD Hermes state records the landing evidence.
drift_risk: This slice could drift into branch cleanup, release publication, or new M3 feature work. Stop if WIP restoration is not clean or if landing would touch unrelated dirty files.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: 1f4a53998d6482d703f84e8d4a07c83423045f1d
cross_repo_boundary:
  allowed_back:
    - "pre/post HEAD commit SHA"
    - "stash creation and restoration status"
    - "test/typecheck/build exit codes"
    - "restored dirty path count"
    - "relative changed file paths"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - Local `web-main` points at the M3 review-visibility commit and the standard web gate passes there.
  - The same six-path WIP is restored on top after verification.
  - DD Hermes captures contract, handoff, exploration, state, closeout, archive, and final landing SHA.
blocked_if:
  - `git stash pop` does not restore cleanly.
  - `merge --ff-only` refuses because target history moved unexpectedly.
  - The web gate fails after landing for reasons beyond the already-verified M3 branch commit.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m3-review-visibility-land-v1.md
---

# Sprint Contract

## Context

`xc-baoxiao-web-m3-review-visibility-v1` produced a verified target-side commit at `95bb706de73aaccd0820f0facd7a235d98408423`, but the actual local `web-main` worktree still sits at `1f4a53998d6482d703f84e8d4a07c83423045f1d` because it carries six unrelated uncommitted edits. The user asked to continue, so the next honest step is to land this M3 slice onto local `web-main` without losing those edits.

Path overlap was checked before proceeding: the six dirty paths on `web-main` do not overlap the review-visibility branch diff surface (`documents-page.tsx`, `expenses-page.tsx`, `trip-detail-page.tsx`, `review-display.ts`, `review-display.test.ts`). That keeps temporary stash / fast-forward / gate / pop a bounded landing strategy.

## Scope

- In scope:
  - temporary stash of existing WIP
  - local fast-forward of `web-main` to the M3 review-visibility commit
  - re-running the standard web gate on landed `web-main`
  - restoring the original WIP
- Out of scope:
  - remote push, PR, or tag creation
  - editing the content of the user's WIP
  - new feature or cleanup work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `1f4a53998d6482d703f84e8d4a07c83423045f1d`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m3-review-visibility-land-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m3-review-visibility-land-v1/state.json`

## Acceptance

- Local `web-main` advances to `95bb706de73aaccd0820f0facd7a235d98408423`.
- Standard web gate passes on landed `web-main`.
- Original WIP is restored after verification.

## Product Gate

- This slice exists to make readable M3 review state real on local `web-main`, not merely ready on a side branch.
- Stop if preserving the user's WIP becomes unreliable.

## Verification

- Target repo side:
  - `git status --short`
  - `git stash push -u`
  - `git merge --ff-only codex/xc-baoxiao-web-m3-review-visibility-v1`
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
  - `git stash pop`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m3-review-visibility-land-v1 --agent-role commander`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m3-review-visibility-land-v1/state.json`

## Open Questions

- None for the landing itself. If `git stash pop` conflicts despite the non-overlap check, stop and treat that as the blocking condition.
