---
status: archived
owner: lead
scope: dd-hermes-legacy-archive-normalization-v1
decision_log:
  - Freeze legacy archive normalization as the latest phase-2 proof after the no-execution closeout semantics and representative schema-v2 backfills were committed under one expert execution anchor.
  - Return the repo to an honest `no active mainline` state instead of fabricating a successor before repo evidence clearly favors one.
  - Keep the archived proof bounded to archive-truth normalization; do not reopen runtime, provider, or generic cleanup scope through this task id.
checks:
  - ./scripts/state-read.sh --task-id dd-hermes-legacy-archive-normalization-v1
  - ./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-legacy-archive-normalization-v1
  - ./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-legacy-archive-normalization-v1/state.json
  - ./scripts/demo-entry.sh
  - bash tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/handoffs/dd-hermes-legacy-archive-normalization-v1-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-legacy-archive-normalization-v1-expert-a-to-lead.md
  - workspace/handoffs/dd-hermes-legacy-archive-normalization-v1-lead-to-lead-archive.md
  - workspace/closeouts/dd-hermes-legacy-archive-normalization-v1-expert-a.md
  - workspace/state/dd-hermes-legacy-archive-normalization-v1/state.json
  - openspec/proposals/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/designs/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/tasks/dd-hermes-legacy-archive-normalization-v1.md
  - docs/artifact-schemas.md
  - docs/coordination-endpoints.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
---

# Archive

## Result

`dd-hermes-legacy-archive-normalization-v1` now closes the archive-truth normalization proof: archived DD Hermes tasks once again report truthful task-class, product, quality-review, and execution-closeout semantics under the current control-plane model.

## Deviations

- This proof normalizes historical archive truth; it does not introduce a new runtime/provider capability or choose the next phase-2 successor.
- The execution anchor stays the isolated expert commit `c0237e5163a9cb8d5477765b586f8571bb7370d6`; the archive does not require inventing a separate successor or integration story to look “more complete”.

## Risks

- The expert worktree still contains unstaged smoke-test artifacts that were intentionally excluded from the execution commit; they must not be mistaken for proof scope.
- The repo now needs a fresh successor-triage pass from this cleaner baseline; reopening this task id for new work would blur the proof boundary.

## Acceptance

- Archived `T0/T1` proof tasks expose `execution_closeout = not-required` instead of fake blocked closeout truth.
- Representative legacy archived execution proofs regain coherent schema-v2 contract, closeout, and state truth.
- Commander truth surfaces can honestly say the latest proof is archived and phase-2 currently has no active mainline.

## Verification

- `./scripts/state-read.sh --task-id dd-hermes-legacy-archive-normalization-v1`
- `./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-legacy-archive-normalization-v1`
- `./hooks/quality-gate.sh --event Stop --state workspace/state/dd-hermes-legacy-archive-normalization-v1/state.json`
- `./scripts/demo-entry.sh`
- `bash tests/smoke.sh all`
