---
status: active
owner: lead
scope: dd-hermes-explicit-gate-verdicts-v1
decision_log:
  - Choose explicit verdict persistence as the next mainline because it is the narrowest unresolved maintainer-visible gap left by phase-2 governance work.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1
  - ./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander
  - bash tests/smoke.sh all
links:
  - openspec/designs/dd-hermes-explicit-gate-verdicts-v1.md
  - workspace/decisions/explicit-gate-verdicts-routing/synthesis.md
---

# Task

## Steps

1. Replace successor indecision with one active mainline and bind it to real phase-2 artifacts.
2. Add a shared persisted verdict snapshot to state version 2 tasks.
3. Extend that verdict snapshot to `execution_closeout` so closeout semantic truth is not quality-gate-only ephemeral state.
4. Surface verdict status and reasons through `state.read`, `context.build`, and gate endpoints.
5. Update commander truth sources so the repo points to the new active mainline.
6. Prove one ready path and one blocked path in smoke coverage.

## Dependencies

- `workspace/contracts/dd-hermes-explicit-gate-verdicts-v1.md`
- `workspace/decisions/explicit-gate-verdicts-routing/synthesis.md`
- archived proof from `dd-hermes-quality-seat-escalation-rules-v1`

## Done Definition

- DD Hermes has a named successor mainline after the archived escalation-rules proof.
- State version 2 tasks can carry explicit gate verdicts, including `execution_closeout`, without hiding the raw source fields.
- The repo can show a maintainer exactly which product/quality gate is blocked and why.

## Acceptance

- The slice stays bounded to shared governance/state/docs/tests.
- The verdict layer is explicit, persisted, and exposed across the shared control plane.
- The new mainline does not silently expand into routing metadata or two-expert orchestration.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-explicit-gate-verdicts-v1`
- `./scripts/context-build.sh --task-id dd-hermes-explicit-gate-verdicts-v1 --agent-role commander`
- `bash tests/smoke.sh all`
