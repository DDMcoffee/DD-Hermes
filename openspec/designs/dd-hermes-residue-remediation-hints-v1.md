---
status: design
owner: lead
scope: dd-hermes-residue-remediation-hints-v1
decision_log:
  - Enrich the existing successor-audit surface with structured remediation hints instead of inventing a separate endpoint first.
checks:
  - ./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit
links:
  - scripts/successor-evidence-audit.sh
  - scripts/demo-entry.sh
  - tests/smoke.sh
---

# Design

## Summary

Teach DD Hermes to emit residue remediation hints from the existing successor-evidence control plane instead of leaving maintainers to infer the right action from archive prose.

## Interfaces

- Extend each `local_residue` item returned by `successor.audit` with:
  - `classification`
  - `recommended_action`
  - `recommended_next_commands`
- Keep `demo-entry` as a formatter over the shared hint rather than embedding separate residue policy.

## Data Flow

1. `scripts/successor-evidence-audit.sh` detects working-tree-only residue as it already does today.
2. The audit classifies known residue shapes, starting with state-only / working-tree-only task packages.
3. The audit emits structured remediation hints alongside existing residue metadata.
4. `scripts/demo-entry.sh` compresses the first available hint into one operator-facing summary line while still listing residue task ids.

## Edge Cases

- If `current_mainline_task_id` points at a working-tree-only residue, the hint must explicitly say the maintainer should either commit a full task package or clear `current_mainline_task_id`.
- If a residue item cannot be classified, keep current behavior and emit a conservative fallback action instead of failing the entire audit.
- The audit remains non-destructive; no hint may trigger automatic deletion or promotion.

## Acceptance

- Residue guidance remains shared truth, not duplicated prose.
- Entry and endpoint surfaces tell the same remediation story.
- The first hint vocabulary is narrow and covers the currently observed residue class.

## Verification

- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- `./scripts/demo-entry.sh`
- `bash tests/smoke.sh endpoint`
- `bash tests/smoke.sh all`
