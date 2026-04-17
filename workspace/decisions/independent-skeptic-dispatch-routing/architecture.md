---
decision_id: independent-skeptic-dispatch-routing
task_id: dd-hermes-independent-skeptic-dispatch-v1
role: architecture
status: proposed
---

# Explorer Finding

## Goal

Decide what architectural gap remains after archived quality-seat semantics, escalation rules, and verdict persistence are already in place.

## Findings

- The control plane already records `independent_skeptic`, `degraded`, `role_conflicts`, `quality_seat_*`, and explicit verdicts; the remaining gap is no longer semantic truth.
- `scripts/dispatch-create.sh` materializes executor worktrees but leaves skeptics on a repo-root packet with no equivalent dispatched review lane.
- Archived closeouts repeatedly say the next proof point is a real independent skeptic assignee rather than more metadata tweaks.

## Recommended Path

- Open a new bounded mainline that turns independent skepticism into a dispatched internal review lane across dispatch/context/handoff/worktree surfaces.

## Rejected Paths

- Reopen `dd-hermes-independent-quality-seat-v1`: rejected because semantics are already archived as a closed proof.
- Reopen `dd-hermes-quality-seat-escalation-rules-v1`: rejected because policy classification is already archived.
- Reopen `dd-hermes-explicit-gate-verdicts-v1`: rejected because verdict persistence is already archived.

## Risks

- The slice could drift into generic staffing theory if it does not stay tied to shared control-plane surfaces.
- Overclaiming independence before a dispatched review lane exists would recreate the same honesty gap the harness is trying to eliminate.

## Evidence

- `workspace/handoffs/dd-hermes-execution-bootstrap-expert-a-to-lead.md`
- `workspace/closeouts/dd-hermes-anchor-governance-v1-expert-a.md`
- `workspace/closeouts/dd-hermes-independent-quality-seat-v1-expert-a.md`
- `openspec/archive/dd-hermes-independent-quality-seat-v1.md`
- `scripts/dispatch-create.sh`
