---
status: superseded-by-archive
owner: lead
scope: dd-hermes-endpoint-schema-v1
decision_log:
  - Translate the three-layer finish-line doc into executable endpoint and artifact schemas.
checks:
  - bash -n scripts/sprint-init.sh scripts/check-artifact-schemas.sh tests/smoke.sh
  - ./scripts/test-artifact-schemas.sh
  - ./tests/smoke.sh all
links:
  - 指挥文档/02-三层终点定义.md
  - docs/coordination-endpoints.md
  - docs/artifact-schemas.md
---

# Proposal

## What

Add explicit endpoint and artifact schemas for DD Hermes coordination, add an execution closeout template, and wire schema checks into the test surface.

## Why

The project already has bootstrap scripts and state/context flows, but "execution closeout" and endpoint contracts are not formalized as schemas that can be checked automatically.

## Non-goals

- Do not introduce a new runtime service or external API server.
- Do not redesign existing state/context workflows.
- Do not mutate project-level policy files.

## Acceptance

- `docs/coordination-endpoints.md` defines endpoint contracts and field-level expectations for `execution slice done`, `task done`, and `project phase done`.
- `docs/artifact-schemas.md` defines required keys for contract, handoff, state, and execution closeout artifacts.
- `.codex/templates/EXECUTION-CLOSEOUT.md` exists and is used by bootstrap flow to materialize closeout files.
- A dedicated check script validates contract/handoff/state/closeout required fields, and smoke schema path executes it.

## Verification

- Run `bash -n scripts/sprint-init.sh scripts/check-artifact-schemas.sh tests/smoke.sh`.
- Run `./scripts/test-artifact-schemas.sh`.
- Run `./tests/smoke.sh all`.
