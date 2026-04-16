---
status: proposed
owner: lead
scope: dd-hermes-multi-agent-dispatch
decision_log:
  - Materialize task-bound dispatch assignments from `state.team` instead of relying on implicit chat roles.
  - Expose degraded role-integrity truth when `Skeptic` is not independent.
checks:
  - bash -n scripts/dispatch-create.sh tests/smoke.sh
  - ./tests/smoke.sh workflow
  - ./tests/smoke.sh all
links:
  - scripts/dispatch-create.sh
  - scripts/team_governance.py
  - docs/long-term-agent-division.md
  - README.md
  - workspace/contracts/dd-hermes-multi-agent-dispatch.md
  - workspace/exploration/exploration-lead-dd-hermes-multi-agent-dispatch.md
---

# Proposal

## What

Add a concrete multi-agent dispatch layer that turns `state.team` into auditable `Supervisor` / `Executor` / `Skeptic` assignments, then expose degraded role-integrity truth when `Skeptic` is not independent.

## Why

DD Hermes already had role concepts in docs, but it still lacked a task-bound dispatch surface that could materialize assignments, create executor worktrees, and tell the truth about role overlap. Without that, “多 agent” remained a naming convention instead of an executable control-plane capability.

## Non-goals

- Do not add a new runtime service or scheduler.
- Do not pretend degraded skeptic fallback is equivalent to independent supervision.
- Do not redesign unrelated endpoint or git-management behavior.

## Acceptance

- `scripts/dispatch-create.sh` materializes `Supervisor` / `Executor` / `Skeptic` assignments from `state.team`.
- Dispatch output includes `independent_skeptic`, `degraded`, `role_conflicts`, and `scale_out_triggers`.
- Dispatch either creates or reuses executor worktrees and emits next-command packets per role.
- Smoke coverage verifies both independent-skeptic and degraded-skeptic dispatch behavior.
- Docs and README make the dispatch surface and degraded truth visible.

## Verification

- Run `bash -n scripts/dispatch-create.sh tests/smoke.sh`.
- Run `./tests/smoke.sh workflow`.
- Run `./tests/smoke.sh all`.
