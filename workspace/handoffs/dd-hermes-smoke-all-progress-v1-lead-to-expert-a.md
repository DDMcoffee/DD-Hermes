---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-smoke-all-progress-v1 smoke orchestration observability slice
product_rationale: This slice should make the authoritative shared-root smoke gate legible while it is running, without reopening any broader verification or control-plane redesign work.
goal_drift_risk: The slice could drift into generic smoke refactoring or an external runner redesign if it stops serving the maintainer-visible question “is the suite still moving, and where did it stop?”.
user_visible_outcome: A maintainer running `bash tests/smoke.sh all` can see which top-level section is in progress and which one failed, instead of waiting through a silent long run.
files:
  - tests/smoke.sh
  - workspace/contracts/dd-hermes-smoke-all-progress-v1.md
  - openspec/proposals/dd-hermes-smoke-all-progress-v1.md
  - openspec/designs/dd-hermes-smoke-all-progress-v1.md
  - openspec/tasks/dd-hermes-smoke-all-progress-v1.md
  - workspace/state/dd-hermes-smoke-all-progress-v1/state.json
decisions:
  - Keep `bash tests/smoke.sh all` as the authoritative surface; do not introduce a replacement runner just to get progress output.
  - Preserve the final stdout JSON success contract; any progress truth should go to stderr or another non-breaking side channel.
  - Stay bounded to top-level section progress; do not redesign section contents or coverage scope.
risks:
  - Do not break existing callers that may only parse the final stdout JSON line.
  - Do not expand into generic logging for unrelated scripts.
  - If a progress helper mistakes expected inner failures for top-level failure, the suite output will become misleading.
next_checks:
  - Verify the updated smoke behavior from the shared root, not only inside the expert worktree.
  - Write back exact changed files, progress evidence, and any failure-path reasoning before handoff return.
---

# Lead Handoff

## Context

Expert `expert-a` owns the bounded implementation slice for smoke progress truth inside an isolated worktree.

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

- Keep the slice bounded to smoke orchestration observability and preserve the existing stdout success contract.

## Product Check

- Confirm the slice still serves the stated product goal and does not expand into the declared non-goals.

## Verification

- State exact shared-root and worktree-local commands used before handoff return.
- Include the changed file list, the progress-output evidence shape, and whether stdout success JSON remained unchanged.

## Open Questions

- Is one narrow progress-contract test enough, or does the shared-root full run itself provide the only trustworthy evidence for this slice?
