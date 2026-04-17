---
decision_id: successor-evidence-audit-routing
task_id: dd-hermes-successor-evidence-audit-v1
role: delivery
status: proposed
---

# Explorer Finding

## Goal

Decide the narrowest deliverable that turns successor evidence into a reusable DD Hermes capability.

## Findings

- DD Hermes already has a coordination endpoint router and several task-independent reporting endpoints such as `session.analytics`, `memory.decay`, and `journal.compact`.
- `demo-entry` already centralizes maintainer-facing truth, but today it can only print static frontmatter and decision-doc pointers.
- A small audit script plus router wiring plus one entry-surface summary is enough to make successor evidence executable without changing runtime/provider behavior.

## Recommended Path

- Add `successor.audit` to the coordination endpoint, back it with one audit script, and let `demo-entry` consume a compact summary when no active mainline exists.

## Rejected Paths

- Put all audit logic directly into `demo-entry.sh`: rejected because other tools and monitor lanes should be able to consume the same structured audit payload.
- Build a new daemon/service: rejected because the repo already standardizes on local scripts and endpoint router surfaces.

## Risks

- The audit output may become unstable if it relies on brittle exact counts instead of structural fields and reasons.
- If the entry surface prints too much residue detail, it will become noisy rather than actionable.

## Evidence

- `scripts/coordination-endpoint.sh`
- `docs/coordination-endpoints.md`
- `tests/smoke.sh`
- `scripts/demo-entry.sh`
