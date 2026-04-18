---
id: xc-baoxiao-web-docs-roadmap-v1
kind: task
status: done
created_at: 2026-04-18T00:00:00Z
updated_at: 2026-04-18T12:57:16Z
task_id: xc-baoxiao-web-docs-roadmap-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: web-main
target_repo_ref: a6619de50df5474233cbe8a33b718817950fb196
cross_repo: true
size: S1
task_class: T2
related_slices:
  - xc-baoxiao-web-gate-green-v1
related_memory:
  - memory/user/user-pref-xc-baoxiao-integrations-placeholder.md
  - memory/self/recalibration-2026-04-18-learnings.md
---

# xc-baoxiao-web-docs-roadmap-v1 (Memory Hint)

## Why this memory card exists

Second real cross-repo slice after DD Hermes recalibration. Purpose: create a low-risk roadmap document in XC-BaoXiaoAuto web docs that summarizes current status and the next milestones without entering code or integration work.

## Key facts to remember

- Target repo: `/Volumes/Coding/XC-BaoXiaoAuto`, branch `web-main`.
- Execution stays target-repo side in an isolated worktree because the main worktree has pre-existing uncommitted changes.
- Primary output is a new roadmap file under `docs/web/`.
- DingTalk and WeCom stay as placeholders; manual upload remains the current entry path.

## Redaction boundary

- DD Hermes may record doc paths, commit SHAs, milestone names, and verification exit codes.
- DD Hermes must not record raw business samples, names, amounts, invoice numbers, or full-precision operational dates.

## Success shape

- A maintainer can read one roadmap doc and immediately see:
  - current web line status,
  - what is intentionally deferred,
  - what to build next.

## Completed outcome

- Target-side worktree branch: `codex/xc-baoxiao-web-docs-roadmap-v1`
- Target-side commit: `7756c9eedea99de4218fff416e5c13882f0c4935`
- Landed file: `docs/web/roadmap.md`
- Main target worktree remained untouched; the pre-existing six-path WIP stayed in place outside this slice.

## Stop conditions

- Worktree isolation unavailable.
- Scope drifts beyond doc-only changes.
- Repo evidence is too weak to state roadmap facts honestly.
