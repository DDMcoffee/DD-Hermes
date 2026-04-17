---
status: proposed
owner: lead
scope: dd-hermes-backlog-truth-hygiene-v1
decision_log:
  - Treat stale candidate truth as the next bounded governance task instead of forcing a feature successor.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1
links:
  - workspace/contracts/dd-hermes-backlog-truth-hygiene-v1.md
  - workspace/exploration/exploration-lead-dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/proposals/dd-hermes-commander-doc-consolidation-v1.md
  - openspec/proposals/dd-hermes-s5-2expert-20260416.md
---

# Proposal

## What

Archive absorbed or paused candidate artifacts so the DD Hermes backlog tells the truth about what is still live.

## Why

The repo now truthfully says there is no active mainline, but two stale artifacts still muddy that claim: one docs-consolidation proposal is effectively finished yet unarchived, and one two-expert experiment still looks like an unfinished execution task even though it was deliberately paused.

## Non-goals

- Runtime/provider/gateway work.
- Resuming the paused two-expert experiment.
- Promoting a new successor mainline before evidence clearly favors one.

## Acceptance

- `dd-hermes-commander-doc-consolidation-v1` is archived as absorbed docs work.
- `dd-hermes-s5-2expert-20260416` is archived as a paused experiment, not left in a misleading execution state.
- Commander triage docs remain honest that there is still no active mainline.

## Verification

- Run `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1`.
- Run `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`.
- Run `./scripts/state-read.sh --task-id dd-hermes-s5-2expert-20260416`.
- Run `./scripts/demo-entry.sh`.
