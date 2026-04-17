---
decision_id: successor-triage-routing
task_id: dd-hermes-successor-triage-v1
role: architecture
status: proposed
---

# Explorer Finding

## Goal

Decide whether the committed DD Hermes control plane actually exposes a single missing architectural slice after archive normalization.

## Findings

- The latest committed proof already closed archive-truth normalization; reopening it would blur an archive boundary that 04/06 now explicitly keep closed.
- The committed repo does not currently expose one unfinished runtime/provider/control-plane feature with the same clarity that earlier mainlines had.
- A local `workspace/state/review-policy-demo/` residue exists in the working tree, but it is not in `HEAD`, has no committed task package, and therefore does not qualify as repo-level successor evidence.

## Recommended Path

- Promote successor triage itself as the temporary governance mainline, then choose a feature successor only if a committed-repo candidate clearly dominates.

## Rejected Paths

- Reopen `dd-hermes-legacy-archive-normalization-v1`: rejected because it is already archived with a complete execution anchor.
- Promote `review-policy-demo`: rejected because it is untracked local residue, not committed repo truth.

## Risks

- Triage could drift into feature invention if it stops discriminating between committed evidence and working-tree noise.
- Leaving successor triage implicit would keep “what is the current mainline?” half inside chat again.

## Evidence

- `openspec/archive/dd-hermes-legacy-archive-normalization-v1.md`
- `workspace/handoffs/dd-hermes-legacy-archive-normalization-v1-lead-to-lead-archive.md`
- `指挥文档/04-任务重校准与线程策略.md`
- `指挥文档/06-一期PhaseDone审计.md`
- `git log --stat -- workspace/state/review-policy-demo/state.json`
