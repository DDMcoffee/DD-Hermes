---
decision_id: explicit-gate-verdicts-routing
task_id: dd-hermes-explicit-gate-verdicts-v1
role: curriculum
status: proposed
---

# Explorer Finding

## Goal

Decide which successor task most clearly improves the maintainer/operator experience of DD Hermes.

## Findings

- The user-visible pain is not “we lack another role model”; it is “what exactly is blocked and why” still requires reading multiple scripts or long docs.
- Persisted verdicts turn gate truth into something a maintainer can inspect directly in `state.json`, carry across handoffs, and cite in archive/entry docs.
- Routing metadata and multi-expert experiments are important, but today they are still secondary compared with making existing control-plane truth legible and durable.

## Recommended Path

- Choose explicit gate verdict persistence as the next mainline.
- Surface status strings, reasons, and verdict freshness in the summaries maintainers actually read.
- Update commander truth sources so the new mainline is visible from the entry layer.

## Rejected Paths

- Do not create a successor that is only internally meaningful but invisible to maintainers.
- Do not use more thread or agent complexity to hide the fact that state truth is still implicit.

## Risks

- If verdicts are too coarse, maintainers will still need to chase raw fields to understand the block.
- If status strings are not standardized, entry/docs/tests may drift semantically.

## Evidence

- `workspace/contracts/dd-hermes-anchor-governance-v1.md`
- `docs/coordination-endpoints.md`
- `docs/artifact-schemas.md`
- `scripts/demo-entry.sh`
- `指挥文档/04-任务重校准与线程策略.md`
