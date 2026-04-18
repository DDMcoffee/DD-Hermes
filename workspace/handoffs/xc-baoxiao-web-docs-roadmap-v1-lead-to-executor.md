---
handoff_id: xc-baoxiao-web-docs-roadmap-v1-lead-to-executor
task_id: xc-baoxiao-web-docs-roadmap-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: target-side isolated worktree execution for web roadmap document
---

# Handoff: XC BaoXiaoAuto Web Roadmap Doc Slice

## Purpose

Lead has instantiated the DD Hermes slice artifacts. Executor lane now performs target-repo work in an isolated worktree, writes the roadmap document, commits the target-side change, and returns a redacted evidence summary for DD Hermes closeout.

## Pre-conditions

- DD Hermes side:
  - `workspace/contracts/xc-baoxiao-web-docs-roadmap-v1.md` exists.
  - `workspace/state/xc-baoxiao-web-docs-roadmap-v1/state.json` exists with `status=active`.
  - Integration placeholder preference has been read from `memory/user/user-pref-xc-baoxiao-integrations-placeholder.md`.
- Target repo side:
  - `/Volumes/Coding/XC-BaoXiaoAuto` exists and `HEAD` matches `a6619de50df5474233cbe8a33b718817950fb196` at pickup unless a fresh probe records otherwise.
  - Main worktree may be dirty; do not edit inside it.

## Instruction Set

1. Create or reuse a target-side worktree for this slice:
   - preferred path: `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-docs-roadmap-v1-lead`
   - branch name: `codex/xc-baoxiao-web-docs-roadmap-v1`
2. Read current truth sources in target repo:
   - `docs/web/报销系统 Web 界面搭建方案.md`
   - `docs/web/README.md`
   - `docs/shared/REPO_MAP.md`
   - `products/web/CHANGELOG.md`
   - web app routes / service files only as needed to confirm current surface
3. Write a new roadmap document under `docs/web/roadmap.md` with this structure:
   - current status
   - explicit non-goals / placeholder integrations
   - milestone list (3-5 items)
   - evidence anchors pointing to existing docs/code paths
4. Only if clearly useful, add a minimal link from `docs/web/README.md` to the new roadmap.
5. Commit target-side doc changes in the worktree. Do not touch the dirty main worktree.

## Evidence Return Protocol

Return a redacted summary block containing:

- target_repo HEAD used for the worktree
- target-side branch name
- changed doc paths
- git diff stat
- commit SHA
- whether `docs/web/README.md` also changed
- verification commands and exit codes

## Stop Conditions

- Worktree creation fails or target HEAD unexpectedly differs in a way that invalidates current planning.
- Required roadmap facts are not recoverable from current repo truth sources.
- Scope pressure pushes beyond doc-only changes.

## Anti-patterns

- Do not edit XC-BaoXiaoAuto application code.
- Do not commit from the dirty main worktree.
- Do not restate DingTalk/WeCom as near-term implementation; keep them as placeholders.
- Do not copy raw sensitive sample content into DD Hermes artifacts.
