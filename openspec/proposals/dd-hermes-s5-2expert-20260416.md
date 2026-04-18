---
status: superseded-by-archive
owner: lead
scope: dd-hermes-s5-2expert-20260416
decision_log:
  - Bootstrap a dedicated experiment task instead of extending the current endpoint/schema main task.
  - Keep the experiment auditable, but separate from the current main-task finish line.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416
links:
  - workspace/contracts/dd-hermes-s5-2expert-20260416.md
  - workspace/exploration/exploration-lead-dd-hermes-s5-2expert-20260416.md
---

# Proposal

## What

Create an independent experiment task to validate whether DD Hermes can safely bootstrap and dispatch a two-expert parallel sprint with isolated worktrees.

## Why

Preserve the experiment as a separate truth-tracked task instead of letting it drift into the current endpoint/schema delivery thread.

## Non-goals

- Claiming completion for the endpoint/schema main task.
- Merging experiment artifacts as if they were part of the current mainline deliverable.
- Project-level policy changes.
- Runtime implementation details outside the sprint bootstrap.

## Acceptance

- Contract, handoffs, exploration log, proposal, and state all exist and point to the same experiment task id.
- Dispatch can materialize two executor worktrees and report role integrity truthfully.
- Experiment documents explicitly state that they are not part of the current main task finish line.

## Verification

- Run `scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416`.
- Run `scripts/dispatch-create.sh --task-id dd-hermes-s5-2expert-20260416`.
