---
from: lead
to: expert-b
scope: dd-hermes-s5-2expert-20260416 separate experiment slice
files:
  - workspace/contracts/dd-hermes-s5-2expert-20260416.md
  - openspec/proposals/dd-hermes-s5-2expert-20260416.md
  - workspace/state/dd-hermes-s5-2expert-20260416/state.json
decisions:
  - Follow the sprint contract and spec-first rule.
  - Treat this task as an experiment separate from the endpoint/schema main task.
risks:
  - Do not change policy through memory writes.
  - Do not let experiment outputs be mistaken for the current main-task deliverable.
next_checks:
  - Run verification before completion.
  - If execution resumes later, write back expert handoff and verification evidence under this experiment task only.
---

# Lead Handoff

## Context

Expert expert-b owns a reserved execution slot for the separate experiment task dd-hermes-s5-2expert-20260416 inside an isolated worktree. This does not count toward the current endpoint/schema main-task finish line.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Keep the experiment artifacts task-bound, template-aligned, and clearly separated from the main task.

## Verification

- State commands and evidence expected from expert before handoff return if the experiment is resumed.
- At minimum, include the workflow test result and the changed file list.

## Open Questions

- The experiment is currently paused after bootstrap and dispatch; a later lead decision is required before any execution slice is claimed as done.
