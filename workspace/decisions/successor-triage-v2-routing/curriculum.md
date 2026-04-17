---
decision_id: successor-triage-v2-routing
task_id: dd-hermes-successor-triage-v2
owner: lead
status: proposed
---

# Curriculum View

## Goal

Decide how DD Hermes should teach the post-audit state to the next maintainer.

## Findings

- The repo now teaches that “no active mainline” can be the correct honest state.
- After the successor-audit proof, the next educational step is not another feature story but a rerun of successor triage from committed evidence.
- Leaving this rerun implicit would recreate the old ambiguity where “what is happening now?” lives partly in chat again.

## Recommendation

- Name the rerun triage explicitly in task artifacts, but archive it as soon as the no-successor result is confirmed.
- Keep the teaching outcome simple: the system can now say both “why there is no mainline” and “why we are not fabricating one”.
