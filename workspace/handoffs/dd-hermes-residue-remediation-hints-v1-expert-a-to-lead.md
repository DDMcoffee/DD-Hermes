---
schema_version: 2
from: expert-a
to: lead
scope: dd-hermes-residue-remediation-hints-v1 residue remediation execution slice
product_rationale: This slice closes the maintainer-visible gap left after successor-audit and triage-v2: residue is still visible, but now DD Hermes can say what to do with it.
goal_drift_risk: The task would drift if it expanded into cleanup automation, deletion, or another successor loop instead of staying centered on residue remediation truth.
user_visible_outcome: A maintainer can read `successor.audit` or `demo-entry` and immediately see the recommended action for working-tree residue.
files:
  - scripts/successor-evidence-audit.sh
  - scripts/demo-entry.sh
  - tests/smoke.sh
  - docs/coordination-endpoints.md
  - workspace/closeouts/dd-hermes-residue-remediation-hints-v1-expert-a.md
  - workspace/contracts/dd-hermes-residue-remediation-hints-v1.md
  - workspace/decisions/residue-remediation-hints-routing/synthesis.md
decisions:
  - Keep residue as non-evidence and only add remediation hints.
  - Reuse the existing audit/entry surfaces instead of inventing a new endpoint.
  - Keep all suggested actions non-destructive; the slice reports choices but does not execute them.
risks:
  - Shared-root truth still treats `dd-hermes-residue-remediation-hints-v1` as local residue until lead commits the task package and integrates this execution branch.
  - Worktree-local `smoke all` is not authoritative because the fixture copy does not include shared-root archived state artifacts; final full regression must run from the main worktree.
next_checks:
  - Lead should integrate execution commit `2317c71f793723bf81756b7d4c5e58fd0262e690`.
  - Lead should rerun successor-audit, demo-entry, and `bash tests/smoke.sh all` from the shared root after integration.
  - If shared-root truth aligns, cut the archive checkpoint instead of stretching this task into broader cleanup.
---

# Expert Handoff

## Context

This handoff returns the first execution slice for `dd-hermes-residue-remediation-hints-v1`. The slice lives on branch `dd-hermes-residue-remediation-hints-v1-expert-a` as commit `2317c71f793723bf81756b7d4c5e58fd0262e690`.

## Required Fields

- `from`
- `to`
- `scope`
- `product_rationale`
- `goal_drift_risk`
- `user_visible_outcome`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- `successor.audit` emits structured residue remediation hints.
- `demo-entry` summarizes the recommended residue action.
- Smoke coverage proves the plain residue path and the `working-tree-mainline-only` path.

## Product Check

- The slice stays on the maintainer-visible question of residue action and does not reopen successor selection or add side effects.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-residue-remediation-hints-v1` -> pass
- `./scripts/context-build.sh --task-id dd-hermes-residue-remediation-hints-v1 --agent-role commander` -> pass
- `bash tests/smoke.sh entry` -> pass
- `bash tests/smoke.sh endpoint` -> pass
- `./scripts/coordination-endpoint.sh --task-id dd-hermes-successor-evidence-audit-v1 --endpoint successor.audit` -> pass
- `./scripts/demo-entry.sh` -> pass
- execution commit: `2317c71f793723bf81756b7d4c5e58fd0262e690` (`feat(dd-hermes): add residue remediation hints`)

## Open Questions

- After integration, should the slice archive immediately, or wait until `review-policy-demo` itself is normalized?
