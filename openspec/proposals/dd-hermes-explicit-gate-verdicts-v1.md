---
status: superseded-by-archive
owner: lead
scope: dd-hermes-explicit-gate-verdicts-v1
decision_log:
  - Promote the next phase-2 mainline only after a concrete maintainer-visible ambiguity is identified.
  - Keep the successor boundary inside explicit gate verdicts instead of jumping to routing or multi-expert experiments.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1
  - ./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander
links:
  - workspace/contracts/dd-hermes-explicit-gate-verdicts-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-explicit-gate-verdicts-v1.md
  - workspace/decisions/explicit-gate-verdicts-routing/synthesis.md
---

# Proposal

## What

Start `dd-hermes-explicit-gate-verdicts-v1` as the active phase-2 mainline and persist explicit gate verdict snapshots into task state.

## Why

The escalation-rules proof already landed task class and quality-seat policy, but DD Hermes still makes maintainers reconstruct gate truth from multiple scripts. This task makes the verdict layer durable and inspectable.

## Non-goals

- Rewriting discussion routing.
- Reopening the paused two-expert experiment as the mainline.
- Runtime/provider/gateway work outside shared governance/state/docs/tests.

## Acceptance

- The repo has one clearly named active successor task instead of an unresolved successor list.
- `state.verdicts` stores explicit product/quality gate snapshots with status and reasons.
- Shared summaries and gates consume that verdict layer consistently.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1`.
- Run `./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander`.
- Run `bash tests/smoke.sh all`.
