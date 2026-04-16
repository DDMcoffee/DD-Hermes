---
decision_id: independent-quality-seat-routing
task_id: dd-hermes-independent-quality-seat-v1
role: curriculum
status: reviewed
---

# Explorer Finding

## Goal

Decide how DD Hermes should explain independent versus degraded quality-seat truth so a maintainer can understand it at a glance.

## Findings

- `dd-hermes-anchor-governance-v1` already proved the repo can expose anchor truth, but the next remaining gap is still clearly documented as degraded supervision.
- The state model already records `independent_skeptic`, `degraded`, `role_conflicts`, and scale-out hints, but maintainers still need a single, readable explanation across state, dispatch, context, and gates.
- The product value of this task is readability plus enforcement, not more abstract role vocabulary.

## Recommended Path

- Make DD Hermes speak in one clear semantic pair: `independent` or `degraded`.
- Require every control-plane entry point to explain that pair consistently, including the reason when the seat is degraded.
- Treat `unknown` as a blocked state, not a completion-friendly default.

## Rejected Paths

- Reject hiding the truth deep inside `state.json` without surfacing it in dispatch/context/gates.
- Reject using only prose or handoff text to explain quality-seat truth.

## Risks

- The task could add terminology without improving scanability.
- Over-enforcement could treat every degraded path as invalid, even when degraded fallback is the truthful current state.
- Inconsistent wording across state, dispatch, and gates would recreate the original ambiguity.

## Evidence

- `README.md`
- `指挥文档/06-一期PhaseDone审计.md`
- `指挥文档/08-恒定锚点策略.md`
- `workspace/state/dd-hermes-independent-quality-seat-v1/state.json`
