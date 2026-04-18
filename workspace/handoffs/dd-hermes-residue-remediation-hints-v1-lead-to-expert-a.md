---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-residue-remediation-hints-v1 residue remediation hint slice
product_rationale: This slice should turn residue from a passive audit warning into one explainable next-action hint a DD Hermes maintainer can actually use.
goal_drift_risk: The slice could drift into generic control-plane churn or cleanup automation if it stops serving the declared residue-remediation outcome.
user_visible_outcome: A maintainer can see what to do with `review-policy-demo`-style residue directly from DD Hermes entry/audit surfaces.
files:
  - workspace/contracts/dd-hermes-residue-remediation-hints-v1.md
  - openspec/proposals/dd-hermes-residue-remediation-hints-v1.md
  - openspec/designs/dd-hermes-residue-remediation-hints-v1.md
  - openspec/tasks/dd-hermes-residue-remediation-hints-v1.md
  - workspace/state/dd-hermes-residue-remediation-hints-v1/state.json
  - workspace/decisions/residue-remediation-hints-routing/synthesis.md
decisions:
  - Keep residue as non-evidence; the slice only adds remediation guidance, not promotion logic.
  - Prefer updating existing successor-audit and entry surfaces over inventing a separate residue product surface.
  - Keep deletion/manual cleanup out of scope; emit hints, not side effects.
risks:
  - Do not silently mutate or delete local residue.
  - Do not let docs or entry imply a new active mainline exists.
next_checks:
  - Run spec-first, endpoint, entry, and smoke verification before completion.
  - Write back execution evidence and updated residue truth to commander-side state.
---

# Lead Handoff

## Context

Expert `expert-a` owns the bounded execution slice for `dd-hermes-residue-remediation-hints-v1` inside an isolated worktree.

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

- Keep residue remediation hints task-bound, reviewable, and consistent across endpoint, entry, docs, and tests.

## Product Check

- Confirm the slice still serves the stated product goal and does not expand into cleanup automation or feature successor selection.

## Verification

- State commands and evidence expected from expert before handoff return.
- At minimum, include endpoint, entry, and smoke results plus the changed file list.

## Open Questions

- Should residue guidance be emitted as one shared string, or as structured fields that `demo-entry` formats separately?
