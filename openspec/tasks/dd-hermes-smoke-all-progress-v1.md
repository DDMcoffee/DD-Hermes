---
status: active
owner: lead
scope: dd-hermes-smoke-all-progress-v1
decision_log:
  - The next bounded gap is smoke progress truth, not another successor-triage or residue-cleanup loop.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1
links:
  - workspace/contracts/dd-hermes-smoke-all-progress-v1.md
  - openspec/designs/dd-hermes-smoke-all-progress-v1.md
  - workspace/handoffs/dd-hermes-smoke-all-progress-v1-lead-to-expert-a.md
---

# Task

## Steps

1. Update `tests/smoke.sh` so `all` mode emits top-level section progress truth without changing the final stdout JSON success line.
2. Add one narrow verification path for the new progress contract.
3. Verify the shared-root command still behaves correctly and capture the evidence in closeout/state.

## Dependencies

- `tests/smoke.sh`
- existing smoke sections must remain individually valid
- shared-root verification, not only worktree-local fixture behavior

## Done Definition

- The maintainer can tell which top-level section the full smoke gate is executing.
- A failing or stopped run can be localized to one top-level section without `bash -x`.
- The stdout success contract remains stable.

## Acceptance

- Progress truth is visible during `all`.
- The task stays bounded to smoke orchestration observability.
- Shared-root verification covers the new behavior.

## Verification

- `scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1`
- `bash tests/smoke.sh entry`
- `bash tests/smoke.sh schema`
- shared-root `bash tests/smoke.sh all` with stderr capture
