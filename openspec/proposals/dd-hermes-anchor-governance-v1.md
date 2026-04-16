---
status: proposed
owner: lead
scope: dd-hermes-anchor-governance-v1
decision_log:
  - Phase-2 cannot stay at route level; it needs task-bound artifacts before implementation.
  - Existing scripts already carry most anchor fields, so the smallest honest path is to harden gates and summaries rather than invent a new runtime layer.
checks:
  - bash -n scripts/state-init.sh scripts/state-update.sh scripts/state-read.sh scripts/context-build.sh scripts/dispatch-create.sh hooks/thread-switch-gate.sh hooks/quality-gate.sh scripts/check-artifact-schemas.sh tests/smoke.sh
  - python3 -m py_compile scripts/team_governance.py
  - bash tests/smoke.sh all
links:
  - workspace/contracts/dd-hermes-anchor-governance-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-anchor-governance-v1.md
  - workspace/decisions/anchor-governance-routing/synthesis.md
  - 指挥文档/08-恒定锚点策略.md
---

# Proposal

## What

Create the real phase-2 task package for `dd-hermes-anchor-governance-v1`, then make `Product Anchor / Quality Anchor` enforceable across state, dispatch, context summaries, thread gate, and completion gate.

## Why

DD Hermes already has anchor fields and role vocabulary, but they are still too easy to ignore. The next honest step is not another manager agent; it is to make the control plane refuse execution or completion when anchor requirements are missing.

## Non-goals

- Do not create a new Hermes runtime, provider, gateway, or scheduler.
- Do not reintroduce multiple long-lived chat threads as the mainline control model.
- Do not treat generic cleanup as anchor governance.

## Acceptance

- The phase-2 task package exists and points to one clear product outcome.
- Product anchor truth is reflected in `state-read` and `context-build` summaries.
- Dispatch and thread-switch gates refuse incomplete product-anchor tasks.
- Completion gate refuses changed-code completion without a quality review.
- Dispatch and thread-switch refuse degraded supervision until an explicit degraded acknowledgement is recorded.
- Closeout checking distinguishes structural completeness from execution-ready evidence.
- Smoke coverage proves both blocking and passing paths.

## Verification

- Run `bash -n scripts/state-init.sh scripts/state-update.sh scripts/state-read.sh scripts/context-build.sh scripts/dispatch-create.sh hooks/thread-switch-gate.sh hooks/quality-gate.sh scripts/check-artifact-schemas.sh tests/smoke.sh`.
- Run `python3 -m py_compile scripts/team_governance.py`.
- Run `bash tests/smoke.sh all`.
