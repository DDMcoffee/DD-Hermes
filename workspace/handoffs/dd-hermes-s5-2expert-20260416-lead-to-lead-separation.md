---
from: lead
to: lead
scope: separate dd-hermes-s5-2expert-20260416 as an independent experiment task
files:
  - workspace/contracts/dd-hermes-s5-2expert-20260416.md
  - openspec/proposals/dd-hermes-s5-2expert-20260416.md
  - workspace/exploration/exploration-lead-dd-hermes-s5-2expert-20260416.md
  - workspace/handoffs/dd-hermes-s5-2expert-20260416-lead-to-expert-a.md
  - workspace/handoffs/dd-hermes-s5-2expert-20260416-lead-to-expert-b.md
  - workspace/closeouts/dd-hermes-s5-2expert-20260416-expert-a.md
  - workspace/closeouts/dd-hermes-s5-2expert-20260416-expert-b.md
decisions:
  - Treat S5 as a dedicated experiment task rather than continuing it inside the endpoint/schema main task.
  - Preserve generated worktrees and artifacts, but do not use them to claim current main-task progress.
risks:
  - Future readers may still misread the experiment as a mainline task unless the separation note is consulted.
  - Runtime state for the experiment is local and not versioned in git.
  - The preserved expert worktrees still contain local uncommitted artifacts and must not be mistaken for completed execution slices.
next_checks:
  - Resume only under explicit lead approval.
  - If resumed, produce expert-to-lead handoffs and true execution commits under the experiment task id.
---

# Lead Handoff

## Context

This handoff records a deliberate separation decision: `dd-hermes-s5-2expert-20260416` is preserved as an independent experiment task for validating two-expert parallel dispatch, not as part of the current endpoint/schema delivery thread.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- S5 is clearly documented as experiment-only.
- Main-task finish line remains unchanged.
- Existing worktrees are preserved for later resumption, but no integration is attempted now.

## Verification

- `./scripts/test-workflow.sh --task-id dd-hermes-s5-2expert-20260416` passed.
- `./scripts/dispatch-create.sh --task-id dd-hermes-s5-2expert-20260416` produced two executor worktrees.

## Open Questions

- Should the experiment eventually be archived after documentation, or resumed as a dedicated phase-validation track?
