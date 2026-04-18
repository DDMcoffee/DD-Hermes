---
schema_version: 2
task_id: xc-baoxiao-web-m3-review-visibility-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Make the XC-BaoXiaoAuto web M3 review path explain itself by turning raw parse and match state into human-readable review reasons on the main review surfaces.
user_value: A collaborator can open documents, expenses, or a trip detail page and immediately see why something is still pending review, instead of reading raw enum values and guessing.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo UI and helper slice across a few files with clear acceptance and low integration risk, but it still needs S2 traceability because it changes product-facing behavior.
non_goals:
  - Do not change parser extraction algorithms or OCR behavior.
  - Do not add new export guards beyond the already-landed M3 rule.
  - Do not touch the user's six dirty paths on target `web-main`.
product_acceptance:
  - Documents, expenses, and trip detail surfaces show readable review status and blocker reasons instead of raw-only enums.
  - Shared helper logic keeps the displayed review explanation consistent across surfaces.
  - Regression tests cover the review-display formatting rules.
drift_risk: This slice could drift into parser tuning, broad page redesign, or new workflow states. Stop once existing review signals are rendered clearly on the three target surfaces.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: 1f4a53998d6482d703f84e8d4a07c83423045f1d
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "review blocker category names and count summaries"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

acceptance:
  - Documents page exposes parse/task failure reasons in readable language.
  - Expenses page and trip detail expose review and match explanations in readable language.
  - Standard web gate passes on the target worktree after the change.
blocked_if:
  - Implementing readable review state requires touching the user's six dirty paths on target `web-main`.
  - The slice cannot be expressed with shared helper logic and starts forking inconsistent status rules across pages.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m3-review-visibility-v1.md
---

# Sprint Contract

## Context

The current web line already emits review signals such as `parseStatus`, `parseError`, task status, `warning`, `needsReview`, and `matchStatus`, but most primary review pages still surface them as raw enum values or leave the explanation implicit. After landing the export guard, the next honest M3 step is to make the remaining review path readable without requiring users to infer meaning from backend state names.

This slice deliberately avoids parser tuning. It only converts existing signals into consistent, user-facing review explanations on the three most relevant M3 surfaces: documents, expenses, and trip detail.

## Scope

- In scope:
  - shared review-display helper logic
  - documents page review explanation improvements
  - expenses page review explanation improvements
  - trip detail review explanation improvements
  - regression tests for formatting rules
- Out of scope:
  - parser algorithm changes
  - report generation behavior changes
  - branch landing / cleanup work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `1f4a53998d6482d703f84e8d4a07c83423045f1d`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m3-review-visibility-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m3-review-visibility-v1/state.json`

## Acceptance

- Review surfaces explain unresolved state in readable Chinese.
- Shared helper logic prevents divergent wording across pages.
- Tests, typecheck, and build all pass on the target worktree.

## Product Gate

- This slice stays on roadmap M3's "待复核链路可解释，不靠人工猜系统状态".
- Stop if the work expands into parser improvements or a larger UX redesign.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for the new review-display helper
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m3-review-visibility-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m3-review-visibility-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m3-review-visibility-v1/state.json`

## Open Questions

- None for scope. If a page lacks the required fields to explain review state cleanly, that field gap becomes the only allowed small data-shape extension.
