---
decision_id: arch-review-2026-04-16
task_id: dd-hermes-arch-review
role: delivery
status: completed
reviewed_at: 2026-04-16T16:35:00Z
---

# Explorer B: Delivery

## Goal

Evaluate git worktree lifecycle, verification closure, integration boundary, template availability, and smoke test coverage for the DD Hermes harness.

---

## 1. Git Worktree Full Lifecycle

### 1.1 Chain: bootstrap -> create -> commit -> remove

| Step | Script | Key Guard | Verdict |
|------|--------|-----------|---------|
| Baseline | git-bootstrap.sh | Skips if HEAD exists; creates managed commit with Codex identity | PASS |
| Pre-check | worktree-create.sh | Refuses if no HEAD | PASS |
| Create | worktree-create.sh | Creates .worktrees/task_id-expert/ with new branch | PASS |
| Commit | git-commit-task.sh | Refuses primary worktree (--allow-primary override); refuses clean tree; writes state.git.latest_commit | PASS |
| Remove | worktree-remove.sh | Refuses to remove primary worktree; optional branch delete | PASS |

### 1.2 Smoke Evidence

tests/smoke.sh run_workflow + run_git_management covers the entire chain including:
- worktree-create, worktree-status from inside worktree
- git-commit-task with state writeback verification
- worktree-remove with branch deletion
- git-bootstrap on fresh repo (has_head=False -> bootstrapped=True)

### 1.3 Issues

- **No pre-remove validation** - worktree-remove.sh does not check if handoff is written or verification is recorded before removal. The invariant in docs/git-management.md ("worktree recovery requires handoff written, verification written, dirty state reviewed") is not enforced by the script.
- **worktree-create.sh uses repo_root() not shared_repo_root()** - Line 28 uses `repo=$(repo_root)` while the handoff documents it was changed to shared_repo_root(). This means the fix is on the expert branch but not integrated.

---

## 2. Integration Commit

### 2.1 Status

docs/git-management.md defines three commit types:
- baseline commit (git-bootstrap.sh) - EXISTS
- execution commit (git-commit-task.sh) - EXISTS
- integration commit - NO SCRIPT

There is no `git-integrate-task.sh` or equivalent. The Lead is expected to manually merge execution branches, but there is no scripted guardrail for:
- Merge conflict resolution protocol
- Post-integration verification trigger
- State update after integration

### 2.2 Impact

Without an integration script, the "task done" layer in the three-layer finish line (execution slice done -> task done -> phase done) has no automated tooling. Lead must manually:
1. Merge the expert branch
2. Re-run verification
3. Update state to reflect integration
4. Update OpenSpec stage

---

## 3. Verification Closure

### 3.1 verify-loop.sh

- Accepts comma-separated check commands and a user-gate
- Runs checks in a loop up to max_rounds (default 5)
- Writes verification results back to state via state-update.sh
- Returns exit 2 on failure

### 3.2 quality-gate.sh

- Triggered on Stop event
- Checks: if code files changed AND (no verified_steps OR test exit != 0 OR changed files not in verified_files) -> block
- Supports coverage:all bypass

### 3.3 Issues

- **verify-loop.sh has no auto-fix** - The doc mentions "up to 5 rounds of auto-repair" but verify-loop.sh only re-runs the same checks. There is no repair/fix step between rounds. The loop is retry-only, not repair-then-retry.
- **quality-gate.sh requires external data** - It expects changed_code_files, verified_steps, verified_files, last_test_exit_code as input JSON. No script automatically collects this data from the current session. The hook relies on the calling agent to supply accurate information.
- **No cross-thread verification** - verify-loop.sh runs checks in the current shell context. When an execution thread finishes, verification evidence is written to state, but the command thread has no script to re-verify from its own perspective.

---

## 4. Template Availability

### 4.1 Critical Finding

`.codex/templates/` directory is EMPTY (0 items).
`.codex/skills/` directory is EMPTY (0 items).

Scripts that depend on templates:

| Script | Template Dependency | Impact |
|--------|-------------------|--------|
| sprint-init.sh | SPRINT-CONTRACT.md, HANDOFF-LEAD.md, EXPLORATION-LOG.md, OPENSPEC-PROPOSAL.md | CANNOT RUN |
| decision-init.sh | DECISION-EXPLORER.md, DECISION-SYNTHESIS.md | CANNOT RUN |
| runtime-report.sh | .codex/skills/*/SKILL.md (glob) | Returns empty skills list (non-fatal) |

### 4.2 Root Cause

The expert handoff lists these templates as created files, but they exist only on the expert branch (dd-hermes-execution-bootstrap-expert-a). The main workspace was never updated.

### 4.3 Additional Missing Files from Expert Branch

Confirmed missing from main workspace (referenced in handoff files list):
- .codex/templates/EXECUTION-CLOSEOUT.md
- docs/artifact-schemas.md
- docs/coordination-endpoints.md
- docs/long-term-agent-division.md
- scripts/check-artifact-schemas.sh
- scripts/coordination-endpoint.sh
- scripts/dispatch-create.sh
- scripts/team_governance.py
- scripts/test-coordination-endpoint.sh
- scripts/test-artifact-schemas.sh

---

## 5. Smoke Test Coverage

### 5.1 Current Sections (tests/smoke.sh)

| Section | What It Covers | Verdict |
|---------|---------------|---------|
| hooks | guard-dangerous-ops, post-edit-typecheck, quality-gate, session-end-log | GOOD |
| memory | write, conflict, constraint protection, read, views, manage | GOOD |
| workflow | spec-first, sprint-init, worktree-create, worktree-status | GOOD |
| git | (depends on workflow) git-status-report, git-snapshot, git-commit-task, worktree-remove, git-bootstrap | GOOD |
| discussion | decision-init, execution-thread-prompt, textbook-record, textbook-summary | GOOD |
| context | runtime-report, context-build, state-read, state-update, pause/resume | GOOD |
| verify | verify-loop pass/fail, state writeback | GOOD |
| schema | memory card fields, contract fields, proposal sections, journal event fields, state fields, context fields | GOOD |

### 5.2 Missing Coverage

| Missing | Reason |
|---------|--------|
| dispatch | dispatch-create.sh not in main workspace |
| endpoint | coordination-endpoint.sh not in main workspace |
| artifact-schemas | check-artifact-schemas.sh not in main workspace |
| integration commit | No script exists |
| worktree pre-remove validation | Not implemented |
| multi-expert concurrent scenario | Only single expert tested |

### 5.3 Fixture Design

Smoke tests run in an isolated tmpdir with a fresh git init, copying the source tree minus .git, .worktrees, workspace/, and memory/journal/. This is well-designed for isolation but means smoke never tests against real accumulated state.

---

## Summary Findings

| ID | Finding | Severity | Category |
|----|---------|----------|----------|
| B1 | .codex/templates/ empty; sprint-init.sh and decision-init.sh broken | CRITICAL | runtime blocker |
| B2 | 10+ files from expert branch not integrated into main | CRITICAL | delivery gap |
| B3 | No integration commit script; task-done layer has no tooling | HIGH | git lifecycle |
| B4 | worktree-remove.sh does not enforce handoff/verification pre-check | HIGH | git safety |
| B5 | verify-loop.sh is retry-only, not repair-then-retry | MEDIUM | verification |
| B6 | quality-gate.sh relies on caller-supplied session data | MEDIUM | verification |
| B7 | No multi-expert concurrent smoke test | MEDIUM | test coverage |
| B8 | worktree-create.sh uses repo_root() instead of shared_repo_root() | LOW | integration miss |
