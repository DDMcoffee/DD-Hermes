---
schema_version: 2
task_id: xc-baoxiao-web-alpha2-land-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Advance XC-BaoXiaoAuto `web-main` locally to the verified alpha.2 release-prep commit while preserving the user's unrelated uncommitted WIP.
user_value: The Web small version stops being "ready on a side branch" and becomes the actual local `web-main` baseline, without losing the user's current unfinished edits.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: Cross-repo integration step with branch movement, temporary WIP preservation, and gate re-verification. Bounded but operationally sensitive enough to stay S2.
non_goals:
  - Do not push remote branches or tags.
  - Do not modify the substance of the user's six existing WIP edits.
  - Do not add new product work beyond landing alpha.2 on local web-main.
product_acceptance:
  - Local `web-main` advances to commit `c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9`.
  - The user's pre-existing WIP is restored after the fast-forward.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on local `web-main` after the branch move.
  - DD Hermes state records the landing evidence.
drift_risk: This slice could drift into release publication or user-WIP cleanup. Stop if WIP restoration is not clean or if the landing step requires touching unrelated files.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: a6619de50df5474233cbe8a33b718817950fb196
cross_repo_boundary:
  allowed_back:
    - "pre/post HEAD commit SHA"
    - "stash creation and restoration status"
    - "test/typecheck/build exit codes"
    - "restored dirty path count"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - `web-main` locally points at the alpha.2 release-prep commit and gate passes there.
  - The six-path WIP is restored on top after verification.
  - DD Hermes captures contract, handoff, state, closeout, archive, and final landing SHA.
blocked_if:
  - `git stash pop` does not restore cleanly.
  - `merge --ff-only` refuses because target history moved unexpectedly.
  - The gate fails after landing for reasons beyond the already-verified alpha.2 prep commit.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-alpha2-land-v1.md
---

# Sprint Contract

## Context

`xc-baoxiao-web-alpha2-prep-v1` produced a verified local release-prep branch at `c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9`, but the actual `web-main` worktree still sat on the older base commit because it carried six unrelated uncommitted edits. The user asked to continue, so the next honest step is to land alpha.2 into local `web-main` without losing those edits.

Path-overlap was checked before proceeding: the six WIP paths do not overlap the alpha.2 branch diff surface. That makes temporary stash / fast-forward / gate / pop a bounded and reversible landing strategy.

## Scope

- In scope:
  - temporary stash of existing WIP
  - local fast-forward of `web-main` to alpha.2 prep commit
  - re-running standard web gate on landed `web-main`
  - restoring the original WIP
- Out of scope:
  - remote push, PR, or tag creation
  - editing the content of the user's WIP
  - new feature or test work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `a6619de50df5474233cbe8a33b718817950fb196`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-alpha2-land-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-alpha2-land-v1/state.json`

## Acceptance

- Local `web-main` advances to `c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9`.
- Standard web gate passes on landed `web-main`.
- Original WIP is restored after verification.

## Product Gate

- This slice exists to make alpha.2 real on local `web-main`, not merely ready on a side branch.
- Stop if preserving the user's WIP becomes unreliable.

## Verification

- Target repo side:
  - `git status --short`
  - `git stash push -u`
  - `git merge --ff-only codex/xc-baoxiao-web-alpha2-prep-v1`
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
  - `git stash pop`
- DD Hermes side:
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-alpha2-land-v1/state.json`
