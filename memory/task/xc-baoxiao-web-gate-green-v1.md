---
id: xc-baoxiao-web-gate-green-v1
kind: task
status: done
created_at: 2026-04-18T00:00:00Z
updated_at: 2026-04-18T20:30:00Z
task_id: xc-baoxiao-web-gate-green-v1
target_repo: /Volumes/Coding/XC-BaoXiaoAuto
target_repo_branch: web-main
target_repo_baseline_green_sha: a6619de50df5474233cbe8a33b718817950fb196
cross_repo: true
size: S2
task_class: T2
outcome: all-green-at-baseline
closeout_path: workspace/closeouts/xc-baoxiao-web-gate-green-v1-lead.md
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

- When a maintainer asks about "XC-BaoXiaoAuto web gate status": look up this task_id, baseline-green SHA is `a6619de50df5474233cbe8a33b718817950fb196` (web-main, 2026-04-14 split commit).
- When planning downstream XC-BaoXiaoAuto web slices: use this SHA as the baseline-green reference. If M5b probe re-run on current HEAD shows red, compare diff against this SHA to isolate new regression.
- When a new cross-repo slice is proposed: reference this slice's cross_repo_boundary as the concrete example of redaction.

## Recorded gate results at SHA a6619de5 (2026-04-18 probe)

- `npm install` → exit 0 (286 packages, 3s)
- `npm run typecheck` → exit 0 (0 TS errors, next typegen + tsc --noEmit)
- `npm test` → exit 0 (1/1 vitest pass, 191ms, only test file is `apps/web/src/server/lib/matching.test.ts`)
- `npm run build` → exit 0 (Next.js compiled 11.6s, 15 static pages, 17 routes total)

## Known gaps at baseline (not part of this slice; for future slices)

- Only 1 test file in the entire web codebase — gate signal is weak for runtime behavior.
- 3 high-severity npm audit findings — security-focused slice needed later.
- No CI wiring — gate is local-only for now.
- Pre-existing uncommitted WIP at probe time: `auth.ts / middleware.ts / auth.config.ts / .env.example / docs/README / db/index.ts`. These are NOT part of the green baseline; they were stashed during probe.
