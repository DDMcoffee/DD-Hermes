---
schema_version: 2
from: expert-a
to: lead
scope: dd-hermes-legacy-archive-normalization-v1 archive-truth normalization execution slice
product_rationale: This slice restores truthful archive semantics for legacy DD Hermes proofs so archived task history can be trusted again under the current control-plane model.
goal_drift_risk: The task would drift if it kept expanding into generic doc cleanup or successor-task invention instead of freezing the archive-normalization proof it actually completed.
user_visible_outcome: A DD Hermes maintainer can inspect archived proof tasks and get truthful task-class, product, quality-review, and execution-closeout signals instead of stale v1 placeholders.
files:
  - scripts/artifact_semantics.py
  - scripts/check-artifact-schemas.sh
  - docs/artifact-schemas.md
  - docs/coordination-endpoints.md
  - tests/smoke.sh
  - openspec/proposals/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/designs/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/tasks/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md
  - workspace/closeouts/dd-hermes-legacy-archive-normalization-v1-expert-a.md
  - workspace/contracts/dd-hermes-demo-entry-v1.md
  - workspace/contracts/dd-hermes-endpoint-router-v1.md
  - workspace/contracts/dd-hermes-endpoint-schema-v1.md
  - workspace/contracts/dd-hermes-execution-bootstrap.md
  - workspace/contracts/dd-hermes-experience-demo-v1.md
  - workspace/contracts/dd-hermes-multi-agent-dispatch.md
  - workspace/contracts/dd-hermes-s5-2expert-20260416.md
  - workspace/closeouts/dd-hermes-demo-entry-v1-expert-a.md
  - workspace/closeouts/dd-hermes-endpoint-router-v1-expert-a.md
  - workspace/closeouts/dd-hermes-endpoint-schema-v1-expert-a.md
  - workspace/closeouts/dd-hermes-execution-bootstrap-expert-a.md
  - workspace/closeouts/dd-hermes-experience-demo-v1-expert-a.md
  - workspace/closeouts/dd-hermes-multi-agent-dispatch-expert-a.md
  - 指挥文档/04-任务重校准与线程策略.md
  - 指挥文档/06-一期PhaseDone审计.md
decisions:
  - Treat archived `T0/T1` proofs as `execution_closeout = not-required` instead of forcing fake blocked closeout truth.
  - Backfill representative legacy contracts and closeouts to schema-v2 truth rather than inventing a separate compatibility layer.
  - Freeze this slice under execution commit `c0237e5163a9cb8d5477765b586f8571bb7370d6` and hand archive ownership back to lead.
risks:
  - The expert worktree still contains unstaged smoke-test artifacts that were intentionally excluded from the execution commit.
  - Lead must refresh commander-side state and archive surfaces so the repo no longer advertises this task as active after the proof is frozen.
next_checks:
  - Validate `state-read`, `check-artifact-schemas`, and `demo-entry` against the refreshed closeout/state after recording the execution commit.
  - If no stronger successor is justified by repo evidence, archive this mainline and return the entry surface to “no active mainline”.
---

# Expert Handoff

## Context

This handoff returns the execution slice for `dd-hermes-legacy-archive-normalization-v1`. The archive-normalization proof is now committed under one isolated expert worktree and is ready for lead-side state refresh, validation, and archive handling.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Archived `T0/T1` proof tasks now surface `execution_closeout = not-required` instead of fake blocked execution truth.
- Representative legacy archived execution proofs now expose schema-v2 contract and closeout truth under current validation.
- The slice stays bounded to archive-truth normalization and does not fabricate a successor feature mainline.

## Product Check

- The maintainer-facing outcome is truthful archive history, not more capability surface area.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1` -> pass in primary workspace
- `./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander` -> pass in primary workspace and expert worktree
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1` -> pass
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-execution-bootstrap` -> pass
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-s5-2expert-20260416` -> pass
- `bash tests/smoke.sh all` -> pass in primary workspace
- execution commit: `c0237e5163a9cb8d5477765b586f8571bb7370d6` (`task(dd-hermes-legacy-archive-normalization-v1): normalize legacy archive truth`)

## Open Questions

- Is there any repo-evidenced reason to keep this task active once commander-side state and entry truth are refreshed?
