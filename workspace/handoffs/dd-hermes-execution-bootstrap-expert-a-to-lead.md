---
from: expert-a
to: lead
scope: dd-hermes-execution-bootstrap bootstrap artifact generation
files:
  - scripts/common.sh
  - scripts/state-init.sh
  - scripts/state-read.sh
  - scripts/state-update.sh
  - scripts/context-build.sh
  - scripts/runtime-report.sh
  - scripts/worktree-status.sh
  - scripts/git-commit-task.sh
  - scripts/verify-loop.sh
  - scripts/sprint-init.sh
  - tests/smoke.sh
decisions:
  - Reworked `scripts/sprint-init.sh` to derive document structure from `.codex/templates/` instead of hardcoding markdown bodies.
  - Added `shared_repo_root()` so execution-thread scripts can resolve commander-side `workspace/` paths correctly from a linked worktree while preserving current-worktree defaults.
  - Added smoke assertions that fail on template placeholder leakage and missing required sections.
risks:
  - `sprint-init.sh` maps template sections through a small renderer; if template headings change, this script must be kept in sync.
  - Existing commander-generated bootstrap artifacts are not auto-regenerated; lead should rerun `scripts/sprint-init.sh` if it wants updated docs for an already initialized task.
  - Scripts that intentionally operate on branch-local tracked files still use the current worktree root; future shared-control-plane scripts must opt into `shared_repo_root()` explicitly.
next_checks:
  - Integrate the worktree diff and rerun `./tests/smoke.sh all` from the target branch.
  - Regenerate sprint artifacts on the lead side if template-aligned bootstrap docs are required for this task record.
---

# Expert Handoff

## Context

Implemented the bootstrap slice so sprint initialization now follows repository templates and emits fuller task-bound artifacts. Verification was extended to lock the new structure in place.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- `scripts/sprint-init.sh` now reads `.codex/templates/SPRINT-CONTRACT.md`, `HANDOFF-LEAD.md`, `EXPLORATION-LOG.md`, and `OPENSPEC-PROPOSAL.md` to determine the generated document structure.
- Generated bootstrap docs include the previously missing sections such as `Required Fields`, `Acceptance`, `Verification`, and `Open Questions`.
- Smoke tests now fail if placeholder text like `sprint-000`, `subsystem-or-slice`, or `TBD` leaks into initialized artifacts.
- Linked worktree executions can now call `state-read.sh`, `state-update.sh`, `git-commit-task.sh`, `worktree-status.sh`, `runtime-report.sh`, and `verify-loop.sh` without manually overriding `REPO_ROOT`.

## Verification

- `bash -n scripts/sprint-init.sh` -> pass
- `./scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap` -> pass
- `./tests/smoke.sh workflow` -> pass
- `./tests/smoke.sh context` -> pass
- `./tests/smoke.sh git` -> pass
- `./tests/smoke.sh all` -> pass

## Open Questions

- No functional blocker remains in this slice. If lead wants already-created task artifacts refreshed, that should be an explicit rerun step during integration.
