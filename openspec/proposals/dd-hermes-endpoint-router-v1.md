---
status: deferred
harness_self_reference: true
provable_need: none
deferral_reason: "Deferred under AGENTS.md Self-Reference Ops on 2026-04-18 (DD Hermes M3b sweep). No current real-slice observation requires a single endpoint router surface; all active mainline candidates sit in XC-BaoXiaoAuto web product line, not DD Hermes harness."
deferral_date: "2026-04-18"
owner: expert-a
scope: dd-hermes-endpoint-router-v1
decision_log:
  - Materialize a single endpoint router so endpoint contracts are executable through one surface.
checks:
  - bash -n scripts/coordination-endpoint.sh tests/smoke.sh scripts/test-coordination-endpoint.sh
  - ./scripts/spec-first.sh --changed-files scripts/coordination-endpoint.sh,tests/smoke.sh,scripts/test-coordination-endpoint.sh,docs/coordination-endpoints.md,README.md --spec-path openspec/proposals/dd-hermes-endpoint-router-v1.md --task-id dd-hermes-endpoint-router-v1
  - ./tests/smoke.sh endpoint
  - ./tests/smoke.sh all
links:
  - docs/coordination-endpoints.md
  - scripts/state-read.sh
  - scripts/state-update.sh
  - scripts/context-build.sh
  - scripts/dispatch-create.sh
  - scripts/check-artifact-schemas.sh
---

# Proposal

## What

Add a unified endpoint router script (`scripts/coordination-endpoint.sh`) that dispatches to `state.read`, `state.update`, `context.build`, `dispatch.create`, and `closeout.check`, then add smoke coverage for this router.

## Why

The endpoint contracts exist in docs and each endpoint already has an implementation script, but there is no single callable control-plane entrypoint. That gap makes orchestration and verification inconsistent.

## Non-goals

- Do not add a network service or daemon.
- Do not redesign existing endpoint business logic.
- Do not change policy or commander-side governance.

## Acceptance

- `scripts/coordination-endpoint.sh` accepts endpoint name + task id and routes to the correct implementation.
- `state.update` routing preserves stdin JSON payload behavior.
- Smoke tests assert router output includes required endpoint fields.
- Docs and README clearly mark the new unified endpoint surface and test entry.

## Verification

- Run `bash -n scripts/coordination-endpoint.sh tests/smoke.sh scripts/test-coordination-endpoint.sh`.
- Run `./scripts/spec-first.sh --changed-files scripts/coordination-endpoint.sh,tests/smoke.sh,scripts/test-coordination-endpoint.sh,docs/coordination-endpoints.md,README.md --spec-path openspec/proposals/dd-hermes-endpoint-router-v1.md --task-id dd-hermes-endpoint-router-v1`.
- Run `./tests/smoke.sh endpoint`.
- Run `./tests/smoke.sh all`.
