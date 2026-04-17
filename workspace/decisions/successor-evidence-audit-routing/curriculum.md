---
decision_id: successor-evidence-audit-routing
task_id: dd-hermes-successor-evidence-audit-v1
role: curriculum
status: proposed
---

# Explorer Finding

## Goal

Decide how DD Hermes should teach and expose the “why is there no successor yet?” question after the latest proof was archived.

## Findings

- The repo already teaches that “没有 active mainline” is a legal honest state, but it still takes repo archaeology to explain why that state is currently correct.
- Users keep asking “主线那？” when the answer depends on residue rejection or candidate-pool inspection that is not exposed as a callable truth surface.
- A control-plane audit is easier to teach than another round of prose-only triage because it can show both the verdict and the ignored residue behind it.

## Recommended Path

- Teach successor absence through one executable audit result, then let entry docs summarize that result instead of replacing it.

## Rejected Paths

- Keep the explanation only in docs and chat: rejected because that recreates a memory-only control plane.
- Expose internal multi-agent topology to explain the audit: rejected because the product surface still needs to stay single-thread and simple.

## Risks

- If the audit over-explains repo history, it will regress into a status scrapbook.
- If the audit hides residue counts entirely, maintainers will still have to inspect the working tree by hand.

## Evidence

- `docs/textbook/chapters/01-control-plane-honesty.md`
- `docs/textbook/entries/2026-04-17-no-active-mainline.md`
- `指挥文档/04-任务重校准与线程策略.md`
