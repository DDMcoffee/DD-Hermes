---
schema_version: 2
task_id: xc-baoxiao-web-m3-export-review-gate-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Add a safe export gate for the XC-BaoXiaoAuto web line so trips with unresolved review blockers cannot be exported silently, and the blocking reasons are visible before export.
user_value: A collaborator can tell whether a trip is export-ready and why it is blocked, instead of generating reimbursement artifacts from still-unreviewed parsing results.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo slice touching report generation and review UX across several files, but it does not require an architecture-scale multi-lane execution.
non_goals:
  - Do not change OCR or parser extraction algorithms in `services/parser-worker`.
  - Do not redesign the full review workflow across every page.
  - Do not push remote branches, create tags, or consume the user's existing six-path WIP.
product_acceptance:
  - Report bundle generation refuses trips that still have unresolved review blockers.
  - The report entry surface exposes whether a trip can export and shows blocking reasons in a human-readable way.
  - Regression tests prove the export gate and blocker classification behavior.
drift_risk: This slice could drift into parser-model tuning or a full review dashboard rewrite. Stop once export gating and blocker visibility are covered with verification.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "redacted blocker-count summaries and blocker category names"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - `generateBundleForTrip` rejects export when trip review blockers remain.
  - The reports surface shows export readiness and blocker reasons before the user clicks export.
  - The standard web gate passes on the target worktree after the change.
blocked_if:
  - The target repo baseline moves away from `c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9` before the worktree is created.
  - The new guard cannot be implemented without touching the user's six dirty paths on local `web-main`.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m3-export-review-gate-v1.md
---

# Sprint Contract

## Context

`xc-baoxiao-web-alpha2-land-v1` made `web-main` locally honest and green at `c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9`, but the M3 gap is still visible in code: `generateBundleForTrip` exports reimbursement artifacts unconditionally once a trip exists, even when `needsReview`, `warning`, `parseStatus`, or review-match signals still indicate unresolved parsing uncertainty.

The parser worker and expense schema already emit review semantics such as `needsReview`, `warning`, `parseStatus`, and `parseError`, yet the current report entry page only shows a generic trip status plus a "生成材料" button. That means the product can generate artifacts from a still-ambiguous parsing state without explaining why the trip is not actually ready.

## Scope

- In scope:
  - export-readiness classification based on trip / document / expense review blockers
  - backend guard in the report generation service
  - report entry UX that exposes readiness and blocker reasons
  - regression tests for blocker classification and export rejection
- Out of scope:
  - parser algorithm changes
  - broad document/expense page redesign
  - release publication or cleanup of older side worktrees

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `c73b987a7ae82b92f3a90a2e45e5cd9090f3e2e9`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m3-export-review-gate-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m3-export-review-gate-v1/state.json`

## Acceptance

- Trips with unresolved review blockers cannot export reimbursement artifacts.
- The reports page can explain the blocking reason set before export is attempted.
- Tests, typecheck, and build all pass on the target worktree.

## Product Gate

- This slice stays on the roadmap's M3 line: "识别不准也能安全落地", by turning unresolved review state into an explicit stop signal.
- Stop if the work starts expanding into parser-quality tuning or broad workflow redesign.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for the new guard logic
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m3-export-review-gate-v1 --agent-role commander`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m3-export-review-gate-v1/state.json`

## Open Questions

- Should `IGNORED` documents count as export blockers by default? Current slice will treat unresolved document parse outcomes as blockers when they still imply missing human confirmation.
