---
decision_id: experience-demo-policy-routing
task_id: dd-hermes-experience-demo-v1
role: curriculum
status: proposed
---

# Explorer Finding

## Goal

Decide which task best teaches the DD Hermes workflow while staying honest about the current multi-agent maturity.

## Findings

- The clearest first lesson is not “we have many scripts”, but “the system knows when to discuss before coding”.
- Current docs already say architecture/strategy work should go through `3-explorer-then-execute`, but the initialization path still depends on human memory.
- A demo that fixes this gap teaches both users and future agents the right default behavior without overstating independent supervision.

## Recommended Path

- Use the experience demo to make discussion-first routing visible and executable.
- Record the remaining truth that independent `Skeptic` is still not the default user experience unless task state and dispatch truly say so.

## Rejected Paths

- Do not use the first demo on the textbook subsystem or other peripheral capabilities.
- Do not claim the demo proves full autonomous multi-agent supervision if the task still runs with a degraded skeptic fallback.

## Risks

- If the demo only edits docs, it will fail to teach the real workflow.
- If the demo claims too much about skeptic independence, it will teach the wrong mental model.

## Evidence

- `docs/decision-discussion.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/05-体验版本路线图.md`
- `workspace/handoffs/dd-hermes-execution-bootstrap-expert-a-to-lead.md`
