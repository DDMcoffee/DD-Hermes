---
schema_version: 2
task_id: xc-baoxiao-web-alpha2-prep-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Prepare a single XC-BaoXiaoAuto Web alpha.2 release-prep branch that combines the completed roadmap and M2 regression-hardening work, updates the web version metadata, and proves the combined result still passes the standard web gate.
user_value: The web line gets a coherent "small version complete" branch instead of scattered feature branches, with version metadata and verification evidence ready for eventual integration into `web-main`.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: Cross-repo integration slice combining two completed branches plus version metadata updates. Bounded to docs/tests/version files, but still requires clean integration and gate re-verification.
non_goals:
  - Do not push or tag remote release refs from DD Hermes.
  - Do not merge directly into the dirty target main worktree.
  - Do not pull in the unrelated six-path WIP currently living in the target main worktree.
  - Do not expand scope into M3 parsing-quality implementation.
product_acceptance:
  - A clean target-side integration branch exists containing the roadmap slice, M2 gate-hardening slice, and alpha.2 version metadata updates.
  - `products/web/VERSION` and `products/web/CHANGELOG.md` reflect `0.1.0-alpha.2`.
  - `cd /Volumes/Coding/XC-BaoXiaoAuto/products/web && npm run test && npm run typecheck && npm run build` remain green on the integrated branch.
  - DD Hermes state records the integrated target commit SHA and redacted verification summary.
drift_risk: This slice could drift into release automation, tagging policy, or unrelated cleanup of target-side WIP. Stop if the work ceases to be a clean local integration and verification branch.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: a6619de50df5474233cbe8a33b718817950fb196
cross_repo_boundary:
  allowed_back:
    - "target-side integration branch name and commit SHA"
    - "version/changelog file paths"
    - "test/typecheck/build exit codes"
    - "redacted commit subjects and diff stat"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - Alpha.2 prep branch contains both prior completed slice commits and version metadata updates.
  - Standard web gate passes on the integrated branch.
  - DD Hermes captures contract, handoff, state, closeout, archive, and target commit SHA for the slice lifecycle.
blocked_if:
  - Cherry-picking the completed slice commits produces non-trivial conflicts.
  - The combined branch fails the web gate for reasons beyond the integrated slice scope.
  - Target-side WIP contamination cannot be avoided.
memory_reads:
  - memory/user/user-pref-xc-baoxiao-integrations-placeholder.md
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-alpha2-prep-v1.md
---

# Sprint Contract

## Context

Two cross-repo web slices are now complete but isolated on separate target-side branches:

- `7756c9eedea99de4218fff416e5c13882f0c4935` — roadmap document
- `ecb92e97c7298918d4681cbf9ec8315d53b4ad04` — M2 regression hardening

The user asked to keep pushing toward a small version finish. The clean next step is not M3 yet; it is to assemble those completed results into one local release-prep branch, update Web version metadata to `0.1.0-alpha.2`, and re-run the normal web gate on the integrated result.

The target repo main worktree is still dirty at six unrelated paths, so direct merge into the current `web-main` checkout would be sloppy and unsafe. Integration must happen inside a dedicated target-side worktree created from the clean `web-main` base commit.

## Scope

- In scope:
  - new target-side release-prep worktree and branch
  - cherry-pick completed roadmap and M2 commits
  - `products/web/VERSION`
  - `products/web/CHANGELOG.md`
  - standard web gate verification
- Out of scope:
  - remote push / PR / tagging
  - modifying unrelated target-side WIP
  - new feature work beyond combining already-completed slices

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `a6619de50df5474233cbe8a33b718817950fb196`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-alpha2-prep-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-alpha2-prep-v1/state.json`
- Worktree: `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-alpha2-prep-v1-lead`

## Acceptance

- Integrated branch contains roadmap, M2 tests, and alpha.2 metadata updates.
- `npm run test`, `npm run typecheck`, and `npm run build` pass on the integrated branch.
- DD Hermes state records the integrated target commit SHA and verification summary.

## Product Gate

- This slice exists to turn "almost ready" into a coherent small-version release-prep branch, not to widen the release scope.
- Stop and recalibrate if integration work starts dragging in the dirty main-worktree edits or any new feature slice.

## Verification

- Target repo side:
  - create isolated integration worktree
  - cherry-pick roadmap and M2 commits
  - update version metadata
  - run `npm run test`
  - run `npm run typecheck`
  - run `npm run build`
- DD Hermes side:
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-alpha2-prep-v1/state.json`

## Open Questions

- Whether a local release tag should be created after the integrated branch is verified. Defer; do not do it automatically in this slice.
