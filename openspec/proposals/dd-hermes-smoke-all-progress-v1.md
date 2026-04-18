---
status: superseded-by-archive
owner: lead
scope: dd-hermes-smoke-all-progress-v1
decision_log:
  - Promote shared-root smoke progress truth as the next bounded mainline because the repo has no other live candidate and the authoritative full regression gate remains opaque during long runs.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1
links:
  - workspace/contracts/dd-hermes-smoke-all-progress-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-smoke-all-progress-v1.md
---

# Proposal

## What

Add maintainer-visible progress truth to `bash tests/smoke.sh all` so shared-root full regression runs show which section is currently executing and where the suite stopped, while preserving the current stdout success JSON contract.

## Why

DD Hermes currently has no active mainline and no remaining residue. The clearest next gap is the authoritative full smoke gate itself: repeated shared-root runs can stay silent for a long time, which makes maintainers guess whether the suite is still moving or hung, and forces `bash -x` when they only need stage truth.

## Non-goals

- Redesign the smoke coverage matrix.
- Replace `tests/smoke.sh all` with a separate product surface.
- Change the final stdout JSON success payload that existing callers may rely on.

## Acceptance

- Shared-root `all` runs emit section progress truth while running.
- A maintainer can identify the stopping section when the suite fails or stalls.
- Passing runs still end with the existing stdout JSON success line.

## Verification

- Run `scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1`.
- Run `bash tests/smoke.sh entry`.
- Run `bash tests/smoke.sh schema`.
- Run one shared-root `bash tests/smoke.sh all` with stderr capture and verify progress markers appear before completion.
