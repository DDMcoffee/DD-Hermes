---
schema_version: 2
from: lead
to: expert-a
scope: dd-hermes-backlog-truth-hygiene-v1 backlog truth cleanup slice
product_rationale: This slice removes stale candidate ambiguity so maintainers stop treating absorbed docs work and paused experiments as live successor tasks.
goal_drift_risk: The slice could drift into generic cleanup if it stops tightening candidate-pool truth around specific stale artifacts.
user_visible_outcome: A maintainer can see which backlog items are absorbed, which are archived experiments, and that there is still no active mainline.
files:
  - workspace/contracts/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/proposals/dd-hermes-backlog-truth-hygiene-v1.md
  - workspace/state/dd-hermes-backlog-truth-hygiene-v1/state.json
  - openspec/proposals/dd-hermes-commander-doc-consolidation-v1.md
  - openspec/proposals/dd-hermes-s5-2expert-20260416.md
decisions:
  - Archive absorbed docs work instead of pretending proposal-only means still pending.
  - Archive the paused two-expert experiment as an experiment, not as a failed or unfinished mainline.
risks:
  - Do not fabricate a new successor mainline just because the candidate pool is being cleaned.
  - Do not resume or integrate the paused experiment while doing archive cleanup.
next_checks:
  - Verify that commander docs still say `no active mainline` after the stale candidates are archived.
  - Re-run the experiment workflow/state checks so the archive claim points to real evidence.
---

# Lead Handoff

## Context

This handoff scopes a bounded governance slice: clean stale candidate truth around absorbed docs work and a paused two-expert experiment, without promoting any new feature mainline.

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

- Keep the cleanup task-bound and evidence-backed; do not let it drift into a hidden feature sprint.

## Product Check

- Confirm the slice improves maintainer-visible backlog truth and still leaves `current_mainline_task_id` empty.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1`
- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416`
- `./scripts/demo-entry.sh`

## Open Questions

- Once stale candidates are cleaned, does any real successor mainline remain clearly favored by repo evidence?
