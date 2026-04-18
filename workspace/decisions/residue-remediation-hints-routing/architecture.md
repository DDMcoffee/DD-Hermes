---
decision_id: residue-remediation-hints-routing
task_id: dd-hermes-residue-remediation-hints-v1
owner: lead
status: proposed
---

# Architecture View

- `successor.audit` already computes residue presence correctly; the missing layer is remediation semantics.
- The smallest coherent change is to enrich each residue item with structured hint fields rather than invent a second endpoint.
- This keeps `demo-entry` as a thin formatter over shared control-plane truth and avoids duplicating residue policy in multiple docs.
