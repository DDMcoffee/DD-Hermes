---
decision_id: successor-evidence-audit-routing
task_id: dd-hermes-successor-evidence-audit-v1
role: architecture
status: proposed
---

# Explorer Finding

## Goal

Decide what architectural gap remains after the repo has already proved archive honesty and independent skeptic dispatch.

## Findings

- The repo already knows that only committed task packages may justify a successor mainline, but that rule still lives in manual triage sweeps and narrative docs.
- The latest successor sweep had to manually inspect `workspace/state/*`, `workspace/contracts/`, and `openspec/` to conclude that all formal `dd-hermes-*` tasks are archived.
- A working-tree residue state such as `review-policy-demo` still exists and must be explicitly rejected as non-evidence; there is no shared control-plane endpoint that does that classification today.

## Recommended Path

- Open one bounded mainline that turns successor evidence discrimination into a callable audit over tracked task-package surfaces and local residue.

## Rejected Paths

- Keep rerunning manual successor sweeps: rejected because the control plane still depends on ad hoc shell inspection.
- Promote `review-policy-demo`: rejected because it is working-tree residue with no committed task package.
- Reopen `dd-hermes-backlog-truth-hygiene-v1`: rejected because stale-candidate cleanup is already archived as a closed governance slice.

## Risks

- The slice could drift into a generic repository linter if it stops serving the successor-evidence question.
- If the audit silently ignores local residue instead of labeling it, DD Hermes will lose the honesty it just proved.

## Evidence

- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
- `openspec/archive/dd-hermes-backlog-truth-hygiene-v1.md`
- `workspace/decisions/successor-triage-routing/architecture.md`
