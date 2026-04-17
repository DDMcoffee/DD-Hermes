---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-successor-triage-v2 committed-repo successor triage
product_rationale: Expose one explicit rerun of successor triage so DD Hermes can justify whether a new mainline exists after the successor-audit proof was archived.
goal_drift_risk: This slice would drift if it started feature-planning or treated residue as backlog evidence instead of sticking to committed-truth reread and decision synthesis.
user_visible_outcome: A maintainer can see one explicit decision artifact explaining whether there is a next mainline right now.
files:
  - workspace/contracts/dd-hermes-successor-triage-v2.md
  - workspace/decisions/successor-triage-v2-routing/synthesis.md
  - workspace/exploration/exploration-lead-dd-hermes-successor-triage-v2.md
  - openspec/proposals/dd-hermes-successor-triage-v2.md
  - workspace/state/dd-hermes-successor-triage-v2/state.json
decisions:
  - Treat `dd-hermes-successor-triage-v2` as a bounded governance mainline, not a hidden precondition outside the repo.
  - Only committed repo evidence may justify a successor; local residue such as `workspace/state/review-policy-demo/` is explicitly non-evidence.
  - If no bounded successor clearly dominates, archive the triage as `no-successor-yet` instead of fabricating progress.
risks:
  - Do not let commander docs claim a feature successor exists before the decision pack proves it.
  - Do not reopen archived proof tasks just because they are recent.
next_checks:
  - Run `./scripts/test-workflow.sh --task-id dd-hermes-successor-triage-v2`.
  - Run `./scripts/context-build.sh --task-id dd-hermes-successor-triage-v2 --agent-role commander`.
  - Run `./scripts/demo-entry.sh`.
---

# Lead Handoff

## Context

This sprint has no feature execution slice yet. The current ownership is a governance slice: reread committed repo truth after `dd-hermes-successor-evidence-audit-v1`, reject residue as non-evidence, and either promote a real successor or archive the triage as `no-successor-yet`.

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

- Keep the triage task bounded to committed-repo reread and successor/no-successor decision making.

## Product Check

- Confirm the slice still serves the stated product goal and does not expand into feature planning or runtime work.

## Verification

- State commands and evidence expected from the triage result.
- At minimum, include workflow/context/entry verification and one explicit decision synthesis.

## Open Questions

- After the triage evidence is fully synthesized, is there one bounded successor strong enough to become the next mainline?
