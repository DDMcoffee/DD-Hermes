---
status: active
owner: lead
scope: dd-hermes-residue-remediation-hints-v1
decision_log:
  - Keep the slice bounded to residue remediation hints on existing control-plane surfaces.
checks:
  - ./scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1
  - ./scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander
links:
  - workspace/contracts/dd-hermes-residue-remediation-hints-v1.md
  - workspace/decisions/residue-remediation-hints-routing/synthesis.md
---

# Task

## Steps

- Materialize the decision package and task-bound state for residue remediation hints.
- Implement structured residue remediation hints in `scripts/successor-evidence-audit.sh`.
- Update `scripts/demo-entry.sh` to summarize the recommended residue action while preserving residue ids.
- Update `docs/coordination-endpoints.md` for the new response fields.
- Extend `tests/smoke.sh` for plain residue and `working-tree-mainline-only` remediation paths.
- Verify endpoint, entry, workflow, context, and smoke outputs.

## Dependencies

- `dd-hermes-successor-evidence-audit-v1` archive remains the proof baseline.
- `dd-hermes-successor-triage-v2` archive remains the governance baseline for why residue is the remaining gap.

## Done Definition

- The repo can explain residue action without reopening archived proof docs.
- The bounded slice is reviewable through task-bound artifacts and verification evidence.

## Acceptance

- Residue remains non-evidence.
- Remediation hints are shared, structured, and non-destructive.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1`
- `./scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander`
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit`
- `./scripts/demo-entry.sh`
- `bash tests/smoke.sh endpoint`
- `bash tests/smoke.sh all`
