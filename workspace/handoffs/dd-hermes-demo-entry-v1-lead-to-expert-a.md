---
from: lead
to: expert-a
scope: dd-hermes-demo-entry-v1 bootstrap artifact slice
files:
  - scripts/demo-entry.sh
  - README.md
  - 指挥文档/README.md
  - 指挥文档/07-体验入口任务说明.md
  - workspace/state/dd-hermes-demo-entry-v1/state.json
decisions:
  - Follow the sprint contract and spec-first rule.
  - Keep this slice user-visible and read-only; do not smuggle in unrelated control-plane work.
  - The entry must be grounded in repo facts: latest proof, current status, next mainline task.
risks:
  - Do not turn the entry script into a mutable controller.
  - Do not report stale or hard-coded status that can drift from repo truth.
  - Only write execution evidence back to commander-side state.
next_checks:
  - Run verification before completion.
  - Write back expert handoff and verification evidence.
  - Confirm the entry can be understood by a reader who has not read multiple commander docs first.
---

# Lead Handoff

## Context

Expert `expert-a` owns the first user-visible DD Hermes experience entry slice inside an isolated worktree. The repo already proved one end-to-end demo; this slice should make that proof easy to inspect from one command and one Chinese landing page.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Deliver a truthful, easy-to-scan entry that makes the current DD Hermes experience version visible without spreading the story across multiple files.

## Verification

- At minimum, include `bash -n scripts/demo-entry.sh`, the output of `./scripts/demo-entry.sh`, and the changed file list.
- Show where the entry reports the latest completed proof and the next mainline task.

## Open Questions

- If the script needs more than repo-local facts to stay truthful, the slice is over-scoped and should return to the commander thread.
