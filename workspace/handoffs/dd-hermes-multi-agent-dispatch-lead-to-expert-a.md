---
from: lead
to: expert-a
scope: dd-hermes-multi-agent-dispatch dispatch traceability closeout
files:
  - scripts/dispatch-create.sh
  - scripts/team_governance.py
  - tests/smoke.sh
  - docs/long-term-agent-division.md
  - README.md
  - workspace/contracts/dd-hermes-multi-agent-dispatch.md
  - openspec/proposals/dd-hermes-multi-agent-dispatch.md
  - workspace/state/dd-hermes-multi-agent-dispatch/state.json
decisions:
  - Materialize multi-agent assignments from `state.team` instead of relying on implicit chat roles.
  - Expose degraded role integrity truth when `Skeptic` is not independent.
  - Treat this task as task-bound closeout for code already integrated on `main`, not as a fresh execution run.
risks:
  - Do not rewrite policy through task traceability or memory writes.
  - The original dispatch capability landed across more than one integrated commit, so closeout must keep git anchors explicit.
  - The current default still allows degraded skeptic fallback; do not overstate this as full independent supervision.
next_checks:
  - Sync task state, closeout, and archive evidence for the integrated dispatch slice.
  - Keep future scheduler/runtime work outside this task unless lead explicitly reopens scope.
---

# Lead Handoff

## Context

This handoff records the integrated dispatch slice for `dd-hermes-multi-agent-dispatch`. The dispatch and role-integrity code is already present on `main`; this file restores honest task-bound traceability rather than claiming a new isolated execution run.

## Required Fields

- `from`
- `to`
- `scope`
- `files`
- `decisions`
- `risks`
- `next_checks`

## Acceptance

- Keep the dispatch closeout task-bound, git-anchored, and honest about degraded skeptic fallback.

## Verification

- `bash -n scripts/dispatch-create.sh tests/smoke.sh` -> pass
- `./tests/smoke.sh workflow` -> pass
- `./tests/smoke.sh all` -> pass
- execution anchors: `034d6ce` (`feat(dd-hermes-multi-agent-dispatch): materialize role assignments`) and `740acba` (`feat(dd-hermes-role-integrity): expose skeptic independence truth`)

## Open Questions

- Whether phase-1 must promote independent `Skeptic` from degraded fallback to default experience version remains a lead-level finish-line decision.
