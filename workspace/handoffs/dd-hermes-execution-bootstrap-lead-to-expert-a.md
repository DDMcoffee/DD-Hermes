---
from: lead
to: expert-a
scope: dd-hermes-execution-bootstrap bootstrap integration slice
files:
  - scripts/common.sh
  - scripts/sprint-init.sh
  - scripts/state-init.sh
  - scripts/state-read.sh
  - scripts/state-update.sh
  - scripts/context-build.sh
  - scripts/runtime-report.sh
  - scripts/worktree-status.sh
  - scripts/git-commit-task.sh
  - scripts/verify-loop.sh
  - tests/smoke.sh
decisions:
  - Follow the sprint contract and spec-first rule.
  - Use repository templates as the source of truth for generated sprint docs.
  - Commander-owned project goals stay outside execution-thread policy mutation.
risks:
  - Do not change policy through memory writes.
  - Do not treat worktree verification as task completion until the slice is integrated.
next_checks:
  - Run verification before completion.
  - Return an expert handoff with changed files, verification evidence, and integration risks.
---

# Lead Handoff

## Context

Expert `expert-a` owns the bootstrap execution slice for task `dd-hermes-execution-bootstrap` inside an isolated worktree.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Make sprint bootstrap generation follow repository templates.
- Make shared control-plane scripts resolve the commander-side repo root correctly from a linked worktree.
- Extend smoke coverage so template placeholder leakage and worktree control-plane regressions fail fast.

## Verification

- `bash -n scripts/sprint-init.sh`
- `./scripts/test-workflow.sh --task-id dd-hermes-execution-bootstrap`
- `./tests/smoke.sh workflow`
- `./tests/smoke.sh context`
- `./tests/smoke.sh git`
- `./tests/smoke.sh all`

## Open Questions

- Existing task artifacts may need regeneration on the lead side after integration.
