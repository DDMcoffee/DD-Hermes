# DD Hermes V1 Closure Plan

Status date: April 22, 2026
Release status: `publish-complete`
Stable release anchor: `v1.0.0`
Follow-up line: `v1.0.1` docs and polish only

## Executive Summary

DD Hermes V1 should now be treated as finished at `v1.0.0`, not as an open-ended release candidate.
The public GitHub-facing surface is already published under MIT, the release tag and GitHub Release page already exist, and the minimum validation path already passes.

The correct closure move is not to keep expanding V1.
The correct closure move is to freeze the V1 contract, record the finish line explicitly, and route any further documentation, GitHub polish, or repository UX work into `v1.0.1` or later.

## Live Release Facts

The following facts define the current release truth:

- GitHub repository: `DDMcoffee/DD-Hermes`
- Visibility: `PUBLIC`
- Default branch: `main`
- Published release: `DD Hermes v1.0.0`
- Release tag: `v1.0.0`
- `origin/main` points to release commit `0649459fb28217e3a32a223089f870e60fceea23`
- `origin/codex/dd-hermes-v1.0.1-docs` continues follow-up documentation polish at `e52ca6a2fae0b0dcc5a9d97140932007f31ab7c3`

## Definition Of Done For V1

V1 is considered complete when all of the following are true:

1. The public entry surface is complete:
   - `README.md`
   - `docs/quickstart.md`
   - `docs/github-release-v1.md`
   - `docs/releases/github-v1.0.0.md`
   - `docs/releases/github-v1.0.0-short.md`
   - `CONTRIBUTING.md`
   - `LICENSE`
2. The repository promise is explicit:
   - MIT licensing is present
   - V1 is clearly defined as a GitHub-facing control-plane skeleton
   - `V2/` drafts are explicitly outside the V1 stability promise
3. The minimum executable validation passes:
   - `bash tests/smoke.sh schema`
   - `./scripts/demo-entry.sh`
4. The public docs do not depend on local absolute paths or target-repo private data.
5. The GitHub release anchors exist online:
   - public repo
   - `main`
   - tag `v1.0.0`
   - release page `DD Hermes v1.0.0`

## Closure Decision

The closure decision is:

- `V1` is already complete and published at `v1.0.0`.
- `v1.0.1` is a follow-up polish line, not part of the V1 release gate.
- A dirty local worktree does not reopen V1 unless the dirty files are intentionally part of the V1 release surface.

## Must / Should / Deferred

## Must

- Freeze the V1 scope at the already-published `v1.0.0` surface.
- Use the existing public entry files as the canonical V1 release surface.
- Keep the release boundary explicit:
  - V1 includes task artifacts, scripts, hooks, cross-repo guidance, and MIT reuse.
  - V1 does not include `V2/` drafts, target-repo business implementation, or new runtime ambitions.
- Keep the release evidence anchored to the published GitHub state rather than to the current dirty local checkout.
- Preserve the current validation baseline:
  - `bash tests/smoke.sh schema`
  - `./scripts/demo-entry.sh`

## Should

- Keep `v1.0.1` limited to release-experience polish:
  - deeper docs English-first conversion
  - GitHub social preview upload
  - optional issue or PR templates
  - minor release-copy cleanup
- Record one explicit maintainer-facing statement that V1 is published and complete, so later work does not keep treating V1 as still open.
- Keep unrelated local residue such as `V2/` deletions, `memory/views/*`, or `coffee-app` artifacts outside the V1 finish-line story.

## Deferred

- New active mainline work
- Control-plane protocol expansion
- Runtime, dispatch, or memory redesign
- Broader open-source repository packaging such as `.github/` templates or CODEOWNERS
- Any attempt to fold `V2/` design work back into the V1 release boundary

## Ordered Closure Steps

1. Confirm the published anchors:
   - `main`
   - `v1.0.0`
   - GitHub Release page
2. Run and preserve the minimum validation:
   - `bash tests/smoke.sh schema`
   - `./scripts/demo-entry.sh`
3. Treat the result as the final V1 sign-off condition.
4. State explicitly that DD Hermes V1 is complete at `v1.0.0`.
5. Route any additional improvements to `v1.0.1` or later.

## Acceptance Checklist

- `LICENSE` exists and is MIT.
- `README.md` and release docs tell one coherent story.
- `v1.0.0` exists on GitHub.
- `DD Hermes v1.0.0` exists as a non-draft, non-prerelease GitHub Release.
- `bash tests/smoke.sh schema` passes.
- `./scripts/demo-entry.sh` reaches the phase-done / no-active-mainline state.
- No follow-up item is incorrectly reclassified as a V1 blocker.

## Non-Goals

- Do not widen V1 just because more documentation can still be improved.
- Do not use branch hygiene as evidence that V1 itself is incomplete.
- Do not turn polish work into a hidden V1 re-release.
- Do not encode live active-mainline conclusions into the stable V1 promise.

## Recommended Final Wording

Use the following wording when describing V1 status:

```text
DD Hermes V1 is published and complete at v1.0.0. The stable public surface is the GitHub-facing control-plane skeleton under MIT; any further work belongs to v1.0.1 polish or V2, not to the V1 release scope.
```

## Multi-Agent Synthesis

This plan was synthesized from three independent review angles:

- Product/Public Surface: the public promise is already coherent and user-visible.
- Engineering/Repo Integrity: release anchors and validation already exist; current residue is branch hygiene, not a V1 content blocker.
- Release Closure: the only safe finish line is to freeze V1 at `v1.0.0` and move all further polish to `v1.0.1` or later.
