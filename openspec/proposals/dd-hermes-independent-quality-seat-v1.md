---
status: superseded-by-archive
owner: lead
scope: dd-hermes-independent-quality-seat-v1
decision_log:
  - Anchor governance is archived; the next honest phase-2 step is to decide how an independent quality seat should exist in the control plane.
  - The smallest useful slice is not a new agent runtime but a planning package plus a narrow execution boundary.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1
  - ./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander
  - ./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1
links:
  - workspace/contracts/dd-hermes-independent-quality-seat-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-independent-quality-seat-v1.md
  - workspace/decisions/independent-quality-seat-routing/synthesis.md
  - 指挥文档/08-恒定锚点策略.md
---

# Proposal

## What

Define the next phase-2 mainline for DD Hermes: make the quality seat legible and enforceable as either `independent` or `degraded`, then prepare one narrow implementation boundary for shared governance scripts.

## Why

`dd-hermes-anchor-governance-v1` proved that anchors can be made visible and gated, but it also froze a truthful gap: phase-2 still runs in degraded supervision unless an independent quality seat is explicitly assigned. DD Hermes now needs a task that turns that remaining gap into a clear, testable planning target.

## Non-goals

- Do not add a new runtime, provider, gateway, or scheduler layer.
- Do not reintroduce multi-thread chat orchestration as the default control model.
- Do not count generic documentation cleanup as independent quality-seat delivery.

## Acceptance

- The planning package states one clear product goal, user value, non-goals, and drift risk for the independent quality seat.
- Decision synthesis names the exact control-plane surfaces the first implementation slice may touch.
- The task remains bounded to shared governance scripts, schemas, and tests.
- Workflow, context generation, and artifact schema checks all pass for the planning package.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-independent-quality-seat-v1`.
- Run `./scripts/context-build.sh --task-id dd-hermes-independent-quality-seat-v1 --agent-role commander`.
- Run `./scripts/check-artifact-schemas.sh --task-id dd-hermes-independent-quality-seat-v1`.
