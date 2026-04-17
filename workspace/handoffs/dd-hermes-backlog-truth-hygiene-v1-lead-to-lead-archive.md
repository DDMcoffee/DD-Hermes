---
schema_version: 2
from: lead
to: lead
scope: archive checkpoint for dd-hermes-backlog-truth-hygiene-v1 candidate-pool cleanup
product_rationale: Keep the repo backlog honest so maintainers do not mistake absorbed proposals or paused experiments for real successor mainlines.
goal_drift_risk: The repo would drift if backlog cleanup silently turned into a fake feature mainline or left stale candidates looking live.
user_visible_outcome: The candidate pool is cleaner, but DD Hermes still truthfully reports that there is no active mainline.
files:
  - workspace/contracts/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/proposals/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/designs/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/tasks/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/archive/dd-hermes-backlog-truth-hygiene-v1.md
  - openspec/archive/dd-hermes-commander-doc-consolidation-v1.md
  - openspec/archive/dd-hermes-s5-2expert-20260416.md
  - workspace/handoffs/dd-hermes-s5-2expert-20260416-lead-to-lead-archive.md
  - workspace/state/dd-hermes-backlog-truth-hygiene-v1/state.json
  - 指挥文档/04-任务重校准与线程策略.md
decisions:
  - Clean stale candidate truth before promoting any new successor mainline.
  - Keep `current_mainline_task_id` empty after cleanup because no new feature slice is clearly favored yet.
risks:
  - This checkpoint does not reduce the remaining successor-selection ambiguity to one winning task.
  - Future maintainers may still need a fresh triage task if multiple new candidates emerge.
next_checks:
  - Use the cleaned candidate pool as the baseline for the next real successor decision.
  - Do not relabel this governance cleanup as the latest feature proof.
---

# Lead Handoff

## Context

This handoff records the archive checkpoint for candidate-pool cleanup. The task is done once stale candidate truth is removed and the repo remains honest about having no active mainline.

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

- Candidate-pool truth is cleaner.
- The repo still says `no active mainline`.

## Product Check

- Confirm the cleanup improved maintainer trust without inventing a successor.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-backlog-truth-hygiene-v1` -> pass
- `./scripts/demo-entry.sh` -> still reports no active mainline

## Open Questions

- Which next bounded DD Hermes task now has enough repo evidence to become the true successor mainline?
