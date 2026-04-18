---
schema_version: 2
task_id: xc-baoxiao-web-m2-core-gates-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Thicken XC-BaoXiaoAuto web regression signals around the current core workflow so upload, task-status lookup, and report bundle generation can break loudly instead of silently.
user_value: A XC-BaoXiaoAuto maintainer gets a more trustworthy web gate: key business paths fail in `npm test` before regressions slip into later manual testing.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: Cross-repo implementation slice with multiple test files and moderate behavior coupling, but still bounded to the web app test surface without architecture or harness changes.
non_goals:
  - Do not add new product features, pages, or external integrations.
  - Do not rewrite the parser worker or database schema.
  - Do not touch the dirty target main worktree directly.
  - Do not convert this slice into full E2E infrastructure work.
product_acceptance:
  - Regression tests exist for at least these chains: upload classification/enqueue, task status authorization, report bundle artifact generation.
  - `cd /Volumes/Coding/XC-BaoXiaoAuto/products/web && npm run test` stays green with the new tests.
  - `npm run typecheck` and `npm run build` remain green after the test additions.
  - DD Hermes state records the target-side commit SHA and redacted verification summary.
drift_risk: This slice could drift into broad QA hardening, Playwright infrastructure, or service refactoring unrelated to current core workflow. Stop if a test requires redesigning app structure rather than adding bounded regression coverage.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: a6619de50df5474233cbe8a33b718817950fb196
cross_repo_boundary:
  allowed_back:
    - "test file paths and test count deltas"
    - "typecheck/test/build exit codes"
    - "target-side branch and commit SHA"
    - "redacted error summaries and failing test names"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - Target-side test additions cover upload, jobs lookup, and report export behavior without changing app features.
  - Web gate commands remain green after the test additions.
  - DD Hermes captures contract, handoff, state, closeout, archive, and target commit SHA for the slice lifecycle.
blocked_if:
  - Target-side worktree cannot be created cleanly from current HEAD.
  - Existing test harness cannot exercise the target behaviors without disproportionate harness surgery.
  - Fixing newly exposed failures requires application redesign outside the testing scope.
memory_reads:
  - memory/user/user-pref-xc-baoxiao-integrations-placeholder.md
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m2-core-gates-v1.md
---

# Sprint Contract

## Context

`xc-baoxiao-web-docs-roadmap-v1` concluded that the next real product step should be M2: strengthen regression signals for the current core workflow. The existing Web gate is structurally correct but still too thin: Vitest coverage is essentially one utility test, while the actual product-critical paths are upload, async task visibility, and report bundle generation.

The target repo remains on `web-main` at `a6619de50df5474233cbe8a33b718817950fb196`, and the main worktree still carries six unrelated uncommitted modifications. As with the previous cross-repo slices, implementation must happen inside a dedicated target-side worktree so those unrelated edits remain untouched.

## Scope

- In scope:
  - `products/web/apps/web/src/**/*.test.ts`
  - minimal production-code seams only if tests cannot be written against current module boundaries
  - upload, jobs lookup, and report bundle flows inside `apps/web`
- Out of scope:
  - Playwright expansion beyond what already exists
  - new APIs, UI changes, parser algorithm changes, deployment, integrations

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `a6619de50df5474233cbe8a33b718817950fb196`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m2-core-gates-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m2-core-gates-v1/state.json` `verification` block, redacted per `cross_repo_boundary`
- Worktree: `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m2-core-gates-v1-lead`

## Acceptance

- Upload regression tests prove classification/enqueue behavior for representative file kinds.
- Jobs route tests prove unauthenticated denial and employee-vs-admin task visibility semantics.
- Report generation tests prove artifact creation and trip/task state transitions on the happy path.
- `npm run test`, `npm run typecheck`, and `npm run build` remain green.

## Product Gate

- This slice stays tied to current Web product value by making the existing manual-upload workflow safer to change.
- Stop and recalibrate if meaningful coverage can only be added by introducing a new testing framework or redesigning service boundaries wholesale.

## Verification

- Target repo side:
  - create isolated worktree
  - run baseline `npm run test`
  - run red-green TDD cycles for each new test file
  - run final `npm run test`, `npm run typecheck`, `npm run build`
- DD Hermes side:
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m2-core-gates-v1/state.json`

## Open Questions

- Whether one small seam export is needed in `report-service.ts` to test bundle rendering without over-mocking. Decide during RED phase; avoid changing behavior.
