---
handoff_id: xc-baoxiao-web-m2-core-gates-v1-lead-to-executor
task_id: xc-baoxiao-web-m2-core-gates-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: target-side isolated worktree execution for M2 core regression tests
---

# Handoff: XC BaoXiaoAuto Web M2 Core Gates

## Purpose

Lead has instantiated the M2 slice artifacts. Executor lane now creates an isolated target-side worktree, verifies the current baseline, and uses TDD to add bounded regression tests for the most important existing web flows.

## Test Targets

1. `document-service` / upload path
   - prove representative upload kinds classify into the expected doc/task types
   - prove successful uploads enqueue async work and return document/task payload
2. `jobs/[id]/route.ts`
   - unauthenticated request returns `401`
   - employee can only read own task
   - admin can read any task
3. `report-service`
   - happy-path bundle generation persists artifacts, completes task, and marks trip exported

## Constraints

- Default to tests-first. Only add minimal production seams when a failing test cannot be expressed against current boundaries.
- Do not touch the dirty target main worktree.
- Do not widen scope into E2E infra or deployment work.
- Keep DingTalk / WeCom untouched.

## Evidence Return Protocol

Return a redacted summary containing:

- worktree path and branch
- baseline `npm run test` result
- new/modified test files
- any production files touched
- final `npm run test`, `npm run typecheck`, `npm run build` exit codes
- target commit SHA

## Stop Conditions

- Baseline in the isolated worktree is unexpectedly red.
- The current Vitest setup cannot exercise these behaviors without disproportionate harness surgery.
- A required fix spills into unrelated application redesign.
