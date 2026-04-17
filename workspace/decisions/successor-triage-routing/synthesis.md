---
decision_id: successor-triage-routing
task_id: dd-hermes-successor-triage-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Decide what the next honest phase-2 mainline should be after `dd-hermes-legacy-archive-normalization-v1` was archived.

## Accepted Path

- Archive `dd-hermes-successor-triage-v1` as a completed governance slice once it has re-read committed repo evidence and moved successor selection out of chat.
- Promote `dd-hermes-independent-skeptic-dispatch-v1` as the next active mainline.
- Keep the successor bounded to one maintainer-visible gap: DD Hermes can already persist verdicts and quality-seat policy truth, but it still does not materialize a genuinely separate skeptic review lane when an independent skeptic is assigned.

## Rejected Paths

- Reopen `dd-hermes-explicit-gate-verdicts-v1`: rejected because it is already an archived closed proof, even if committed docs/tests still preserve older successor wording around it.
- Reopen `dd-hermes-legacy-archive-normalization-v1`: rejected because it is already a closed proof with execution-anchor-backed archive evidence.
- Promote `review-policy-demo`: rejected because it is untracked working-tree residue and not present in committed repo history.
- Archive triage as `no-successor-yet`: rejected because committed archive and closeout evidence now converges on one concrete follow-up gap, namely a real independent skeptic assignee / lane rather than more policy or verdict metadata.

## Execution Boundary

- `dd-hermes-independent-skeptic-dispatch-v1` may change dispatch/context/handoff/worktree/gate surfaces needed to turn independent skepticism into a real internal review lane.
- It must not reopen verdict persistence, escalation rules, runtime/provider work, or user-facing multi-thread product design.
- The new mainline may keep user-facing interaction on one thread; any independent skeptic execution surface stays internal to DD Hermes.

## Executor Handoff

- Freeze this triage task as archive evidence for why successor selection moved from “no active mainline” to a concrete next task.
- Start the new mainline with a task package that explains why the remaining gap is operational independent skepticism, not more policy or more verdict persistence.
