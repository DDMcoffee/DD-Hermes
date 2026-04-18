---
id: xc-baoxiao-web-gate-green-v1
kind: task
status: active
created_at: 2026-04-18T00:00:00Z
updated_at: 2026-04-18T00:00:00Z
task_id: xc-baoxiao-web-gate-green-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
cross_repo: true
size: S2
task_class: T2
related_slices:
  - dd-hermes-m4-cross-repo-protocol
related_memory:
  - memory/world/xc-baoxiao-sample-data-location.md
  - memory/user/user-pref-xc-baoxiao-integrations-placeholder.md
---

# xc-baoxiao-web-gate-green-v1 (Memory Hint)

## Why this memory card exists

First real cross-repo slice after DD Hermes M1-M4 recalibration. Purpose: establish a trustworthy `npm typecheck / test / build` green-gate baseline on XC-BaoXiaoAuto `web-main`, so downstream web slices have a reference point for "new regression vs pre-existing red".

## Key facts to remember

- Target repo: `/Volumes/Coding/XC-BaoXiaoAuto`, branch `web-main`, HEAD at slice start `a6619de50df5474233cbe8a33b718817950fb196`.
- Workdir inside target repo: `products/web/`.
- Three authoritative gate commands: `npm run typecheck`, `npm test`, `npm run build`.
- All gate commands run target-repo side only (`execution_host=target-repo`).
- DD Hermes side never executes `git push` or `npm install` for target repo.

## Redaction boundary (hard rule)

- DD Hermes git history must never contain: employee names, customer names, invoice numbers, amounts, phone, email, ID numbers, full-precision dates when tied to real transactions.
- Allowed to enter DD Hermes state: exit codes, counts, test names (not test bodies), file paths (not file contents), commit SHAs.
- Raw test/build stdout lives only on target side (or `/tmp/` scratch), never committed on DD Hermes side.

## Stop conditions

- Baseline red too deep: stop if cumulative fix pressure exceeds 2 hours.
- Fixes require changes outside `products/web/`: stop, out of scope.
- Network or registry fails `npm install`: stop, not this slice's problem.

## What this memory should trigger in future sessions

- When a maintainer asks about "XC-BaoXiaoAuto web gate status": look up this task_id, fetch last recorded SHA and exit codes.
- When planning downstream XC-BaoXiaoAuto web slices: use the SHA recorded here as the baseline-green reference.
- When a new cross-repo slice is proposed: reference this slice's cross_repo_boundary as the concrete example of redaction.
