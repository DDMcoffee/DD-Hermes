---
from: expert-a
to: lead
scope: dd-hermes-endpoint-router-v1 unified router execution slice
files:
  - scripts/coordination-endpoint.sh
  - scripts/test-coordination-endpoint.sh
  - tests/smoke.sh
  - docs/coordination-endpoints.md
  - README.md
  - openspec/proposals/dd-hermes-endpoint-router-v1.md
decisions:
  - Add a single router entrypoint instead of requiring orchestration to call each endpoint script manually.
  - Preserve stdin JSON behavior for `state.update` routing.
  - Verify router behavior through both dedicated endpoint tests and smoke coverage.
risks:
  - Task-bound workspace artifacts were backfilled after the integrated router code already landed on `main`.
  - Later endpoint additions expanded the router surface beyond the original proposal, so task scope should be read from this handoff and the execution commit.
next_checks:
  - Sync router task state, closeout, and archive evidence.
  - Keep later endpoint-expansion work separate unless scope is explicitly reopened.
---

# Expert Handoff

## Context

This handoff records the integrated execution slice for `dd-hermes-endpoint-router-v1`. The router implementation is already present on `main`; this file restores task-bound traceability for that already integrated work rather than claiming a new execution run.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- `scripts/coordination-endpoint.sh` provides a single executable router surface.
- Router tests and smoke verification cover the endpoint surface.
- Docs and README reflect the unified endpoint entry.

## Verification

- `./scripts/spec-first.sh --changed-files scripts/coordination-endpoint.sh,tests/smoke.sh,scripts/test-coordination-endpoint.sh,docs/coordination-endpoints.md,README.md --spec-path openspec/proposals/dd-hermes-endpoint-router-v1.md --task-id dd-hermes-endpoint-router-v1` -> pass
- `bash -n scripts/coordination-endpoint.sh scripts/test-coordination-endpoint.sh tests/smoke.sh` -> pass
- `./tests/smoke.sh endpoint` -> pass
- `./scripts/test-coordination-endpoint.sh` -> pass
- execution commit: `4ea93ab` (`feat(dd-hermes-endpoint-router-v1): add unified coordination endpoint router`)

## Open Questions

- Should later endpoint additions be archived separately, or treated as a broader router-evolution cleanup item?
