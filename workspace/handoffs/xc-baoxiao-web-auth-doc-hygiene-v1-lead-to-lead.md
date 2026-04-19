---
schema_version: 2
from: lead
to: lead
scope: xc-baoxiao-web-auth-doc-hygiene-v1 cross-repo cleanup and landing
product_rationale: The value of this slice is repository trust. After multiple landed web slices, six leftover dirty paths still blurred the difference between active work and stale residue.
goal_drift_risk: The task would drift if it expanded into new feature work or broad auth redesign instead of deciding which of the six dirty paths still match the current web-main baseline.
user_visible_outcome: XC-BaoXiaoAuto web-main becomes clean again, while keeping the auth split and local setup docs that still improve current behavior.
files:
  - docs/web/README.md
  - products/web/apps/web/.env.example
  - products/web/apps/web/src/auth.config.ts
  - products/web/apps/web/src/auth.ts
  - products/web/apps/web/src/middleware.ts
decisions:
  - Keep the auth config split because middleware should not import the full auth provider stack.
  - Keep the local setup doc and app-level env example because the latest README now documents a real non-Docker startup path.
  - Drop the `packages/db/src/index.ts` enum re-export residue because the current landed baseline already builds and tests without it.
risks:
  - The auth split touches login and middleware entrypoints, so build verification is mandatory even though the diff is small.
  - The slice uses degraded review: no independent skeptic lane is claimed.
next_checks:
  - Confirm target-side `test`, `typecheck`, and `build` all exit 0 after dropping the db residue.
  - Fast-forward the reviewed branch back onto local `web-main`.
  - Record the landed target commit and clean status in DD Hermes state.
---

# Lead Handoff

## Context

The target repo already had a strong landed Web baseline, but the main worktree still looked active because six paths stayed dirty. This handoff narrows the task to "review each dirty path against the latest landed state and only keep what still closes a real gap."

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

- The stale db index residue is removed.
- The auth split and local-run docs changes survive review and land.
- The target repo returns to a clean `git status`.

## Product Check

- The slice remains a cleanup of existing residue against the latest landed baseline, not a new auth milestone.

## Verification

- target repo review of the six original dirty paths
- `npm run test` -> pass
- `npm run typecheck` -> pass
- `npm run build` -> pass
- target branch `codex/xc-baoxiao-web-auth-doc-hygiene-v1` fast-forwarded into local `web-main`

## Open Questions

- None.
