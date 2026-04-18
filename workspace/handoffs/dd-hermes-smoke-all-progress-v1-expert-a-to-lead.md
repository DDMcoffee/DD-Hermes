---
schema_version: 2
from: expert-a
to: lead
scope: dd-hermes-smoke-all-progress-v1 smoke progress execution slice
product_rationale: This slice makes the authoritative smoke gate legible while it is running, so a maintainer can tell whether `bash tests/smoke.sh all` is still advancing and where it stopped.
goal_drift_risk: The task would drift if it expanded into generic smoke refactoring, runner redesign, or broad verification cleanup instead of staying centered on top-level progress truth.
user_visible_outcome: A maintainer running the full smoke gate can now see top-level `start/done/fail` section markers on stderr without losing the final stdout JSON success contract.
files:
  - tests/smoke.sh
  - workspace/contracts/dd-hermes-smoke-all-progress-v1.md
  - openspec/proposals/dd-hermes-smoke-all-progress-v1.md
  - openspec/designs/dd-hermes-smoke-all-progress-v1.md
  - openspec/tasks/dd-hermes-smoke-all-progress-v1.md
  - workspace/handoffs/dd-hermes-smoke-all-progress-v1-expert-a-to-lead.md
decisions:
  - Put progress truth on stderr and keep stdout success JSON unchanged.
  - Route section execution through one wrapper so `all` and explicit `SMOKE_PROGRESS=1` share the same behavior.
  - Harden the `entry` smoke fixture so it asserts residue growth instead of assuming one synthetic task id must always appear in the top residue summary.
risks:
  - Expert-worktree `bash tests/smoke.sh all` is not authoritative because this worktree does not include root-only untracked runtime state directories such as `workspace/state/dd-hermes-backlog-truth-hygiene-v1`.
  - Final acceptance still depends on shared-root verification after integration, not on worktree-local full-suite output.
next_checks:
  - Lead should integrate execution commit `309e1472189d419a56e98e87271b4d2b582bc13e`.
  - Lead should rerun `bash tests/smoke.sh all` from the shared root and confirm stderr progress plus final stdout JSON success.
  - If shared-root verification passes, cut archive evidence instead of leaving this slice as an active loose end.
---

# Expert Handoff

## Context

This handoff returns the first execution slice for `dd-hermes-smoke-all-progress-v1`. The slice lives on branch `dd-hermes-smoke-all-progress-v1-expert-a` as commit `309e1472189d419a56e98e87271b4d2b582bc13e`.

## Required Fields

- `from`
- `to`
- `scope`
- `product_rationale`
- `goal_drift_risk`
- `user_visible_outcome`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- `tests/smoke.sh` emits top-level `start/done/fail` progress truth on stderr for the authoritative `all` path.
- The final stdout JSON success line remains unchanged.
- The new progress-contract smoke path passes.

## Product Check

- The slice stays on smoke orchestration observability and does not expand into generic runner redesign.

## Verification

- `bash -n tests/smoke.sh` -> pass
- `bash tests/smoke.sh progress` -> pass
- `bash tests/smoke.sh entry` -> pass
- worktree-local `bash tests/smoke.sh all` now surfaces exact fail locations, but its schema phase is non-authoritative because this worktree lacks shared-root untracked runtime state fixtures
- execution commit: `309e1472189d419a56e98e87271b4d2b582bc13e` (`feat(dd-hermes-smoke-all-progress-v1): add smoke progress truth`)

## Open Questions

- None. The remaining question is purely shared-root verification after integration.
