---
status: active
owner: lead
scope: dd-hermes-legacy-archive-normalization-v1
decision_log:
  - Candidate-pool cleanup is complete, so the next real gap is legacy archive truth rather than a missing feature successor.
  - Archived `T0/T1` tasks should stop surfacing fake blocked execution-closeout truth.
  - Representative legacy execution proofs should be normalized to schema-v2 contract/state/closeout semantics instead of left permanently broken.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1
  - ./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander
  - bash tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/designs/dd-hermes-legacy-archive-normalization-v1.md
  - openspec/tasks/dd-hermes-legacy-archive-normalization-v1.md
---

# Proposal

## What

Normalize archived DD Hermes proof tasks so legacy contracts, states, and closeout verdicts remain truthful under the current control-plane model.

## Why

The repo no longer lacks a successor feature slice; it lacks truthful archive history. Several archived proofs still expose v1 empty state or placeholder closeout semantics, which makes `state.read` and `closeout.check` disagree with what those tasks actually proved.

## Non-goals

- Inventing a new active feature mainline.
- Reopening archived implementation scope or rewriting historical code.
- Expanding into generic repo cleanup beyond archived-proof truth.

## Acceptance

- Archived `T0/T1` tasks expose `execution_closeout = not-required`.
- Representative legacy archived execution tasks regain coherent v2 contract/state/closeout truth.
- Repo truth sources can honestly return to “no active mainline” after the normalization is archived.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-legacy-archive-normalization-v1`.
- Run `./scripts/context-build.sh --task-id dd-hermes-legacy-archive-normalization-v1 --agent-role commander`.
- Run `bash tests/smoke.sh all`.
