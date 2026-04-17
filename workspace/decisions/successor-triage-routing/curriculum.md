---
decision_id: successor-triage-routing
task_id: dd-hermes-successor-triage-v1
role: curriculum
status: proposed
---

# Explorer Finding

## Goal

Decide how DD Hermes should explain the post-archive transition without confusing users into thinking a feature successor already exists.

## Findings

- The repo’s own teaching material already treats “no active mainline” as a valid honest state, but the next step after that state is still “successor triage.”
- If successor triage remains implicit, users keep asking “主线那？” because the control plane has no named current task to point at.
- A governance mainline is easier to teach than a fake feature successor: it says “we are deciding the next bounded task from committed evidence.”

## Recommended Path

- Name the current phase-2 mainline `dd-hermes-successor-triage-v1` and explain that its product outcome is a justified successor decision, not feature delivery.

## Rejected Paths

- Reusing archive pages as if they were live task trackers: rejected because archive should stay proof-oriented.
- Teaching users to inspect local residue or dirty working trees for successor clues: rejected because that undermines control-plane honesty.

## Risks

- If this governance mainline lingers without a clear synthesis, it becomes another vague state the repo cannot explain.
- If docs over-explain history again, the landing path will regress into a status scrapbook.

## Evidence

- `docs/textbook/entries/2026-04-17-no-active-mainline.md`
- `docs/textbook/chapters/01-control-plane-honesty.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
