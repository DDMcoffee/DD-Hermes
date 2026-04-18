---
schema_version: 2
task_id: xc-baoxiao-web-docs-roadmap-v1
size: S1
owner: lead
experts:
  - lead

product_goal: Publish a web roadmap document in XC-BaoXiaoAuto that states the current web product-line status, keeps DingTalk and WeCom as placeholders, and makes the next 3-5 milestones explicit for future execution.
user_value: A XC-BaoXiaoAuto maintainer or collaborator can open one roadmap file and immediately understand what the web line already has, what is intentionally deferred, and what should be built next.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: Narrow single-file cross-repo documentation slice with a clear output and low regression risk. Implementation still occurs in target_repo, so this is execution rather than exploration-only T1.
non_goals:
  - Do not modify XC-BaoXiaoAuto application code, database schema, or integration behavior.
  - Do not rewrite unrelated existing docs outside the roadmap file unless a minimal link update is required.
  - Do not change the DingTalk or WeCom placeholder policy; they stay documented as deferred.
  - Do not copy any raw business samples, names, invoice data, or full-precision dates into DD Hermes tracked files.
product_acceptance:
  - A roadmap document exists under `docs/web/` in XC-BaoXiaoAuto and is committed on target repo side.
  - The document states current web status from repo evidence, calls out manual upload as the current entry path, and documents DingTalk/WeCom as placeholders.
  - The document lists 3-5 concrete milestones in execution order and keeps scope at documentation/planning level.
  - DD Hermes state records the target commit SHA and a redacted evidence summary.
drift_risk: This slice could drift into product redesign, README cleanup, or direct implementation planning detached from repo truth. Stop if the work no longer improves a single roadmap document backed by current code/docs evidence.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: a6619de50df5474233cbe8a33b718817950fb196
cross_repo_boundary:
  allowed_back:
    - "target_repo current HEAD and slice commit SHA"
    - "changed doc path names"
    - "redacted status summary of current web capabilities"
    - "milestone labels and non-sensitive acceptance bullets"
    - "verification exit codes for markdown/git checks"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - `docs/web/roadmap.md` (or an equivalent new roadmap file under `docs/web/`) is written and committed in target_repo.
  - The roadmap is traceable to current repo evidence and does not contradict the integration-placeholder preference.
  - DD Hermes captures contract, handoff, state, closeout, archive, and target commit SHA for the slice lifecycle.
blocked_if:
  - target_repo worktree cannot be created cleanly from current HEAD.
  - required roadmap facts are too ambiguous to summarize without inventing product status.
  - scope expands beyond a doc-only slice.
memory_reads:
  - memory/user/user-pref-xc-baoxiao-integrations-placeholder.md
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-docs-roadmap-v1.md
---

# Sprint Contract

## Context

DD Hermes completed M1-M6 recalibration and needs a second real cross-repo slice that exercises the protocol without code-build risk. The chosen slice is a pure documentation task in XC-BaoXiaoAuto web product line: write a roadmap that reflects the repo's current web status, preserves the user's explicit integration-placeholder preference, and gives the next few milestones a stable landing page.

At pickup time the target repo is still on `web-main` at `a6619de50df5474233cbe8a33b718817950fb196`, with pre-existing uncommitted changes in the main worktree including `docs/web/README.md`. To avoid mixing this slice with unrelated WIP, execution happens in a target-side isolated worktree created from the clean HEAD commit.

## Scope

- In scope: `docs/web/roadmap.md` as the primary output; minimal supporting link update if needed under `docs/web/README.md` inside the isolated worktree only.
- Out of scope: application code, package files, DB schema, parser worker, auth, middleware, deployment, CI, and any DingTalk/WeCom implementation work.

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `a6619de50df5474233cbe8a33b718817950fb196`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-docs-roadmap-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-docs-roadmap-v1/state.json` `verification` block, redacted per `cross_repo_boundary`
- Worktree: target-side isolated worktree under `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-docs-roadmap-v1-lead`

## Acceptance

- The roadmap file is present under `docs/web/` and committed on target repo side.
- The roadmap includes:
  - current web status grounded in existing docs/code,
  - explicit placeholder language for DingTalk/WeCom,
  - 3-5 milestones ordered by execution priority.
- DD Hermes state records target-side verification and final commit SHA.

## Product Gate

- This slice stays attached to the web product line by describing the current product surface and next milestones, not by proposing harness changes or speculative platform work.
- Stop and recalibrate if the document starts depending on facts not supported by the current repo, or if the work naturally turns into "rewrite all web docs."

## Verification

- Target repo side:
  - `git status --short`
  - `git rev-parse HEAD`
  - `git worktree add ...`
  - markdown content review by file diff
  - `git diff --stat`
  - `git commit`
- DD Hermes side:
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-docs-roadmap-v1/state.json`

## Open Questions

- Whether `docs/web/README.md` should receive a one-line link to the roadmap if the roadmap lands as a new sibling file. Resolve only if the delta is clearly helpful and isolated.
