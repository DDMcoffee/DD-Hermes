---
decision_id: arch-review-2026-04-16
task_id: dd-hermes-arch-review
role: architecture
status: completed
reviewed_at: 2026-04-16T16:30:00Z
---

# Explorer A: Architecture

## Goal

Evaluate context / runtime / state / memory governance consistency between docs and scripts, and the completeness of the command-thread / execution-thread separation.

---

## 1. Four-Layer Boundary Consistency

### 1.1 Doc Definition (docs/context-runtime-state-memory.md)

| Layer | Trait | Persisted at | Cannot |
|-------|-------|-------------|--------|
| runtime | ephemeral, recomputable | no persistence (runtime-report.sh snapshot) | define policy |
| state | mutable, task-scoped | workspace/state/task_id/state.json | replace memory |
| context | derived, disposable | workspace/state/task_id/context.json | be truth source |
| memory | cross-session, governed | memory/{user,task,world,self}/ | be overwritten by state |

### 1.2 Script Evidence

| Invariant | Script | Verdict |
|-----------|--------|---------|
| runtime to state | context-build.sh calls runtime-report.sh, writes path back to state.runtime.last_runtime_report_path | PASS |
| state to context | context-build.sh reads state-read.sh output, injects into context packet | PASS |
| memory to context | context-build.sh calls memory-read.sh, injects matches; never auto-writes memory | PASS |
| policy != memory mutation | memory-write.sh double-guards constraints: (a) same scope different content rejected (b) existing constraint content immutable | PASS |
| context != truth | context.json is rebuilt every time by context-build.sh, no persistent state | PASS |

**Conclusion: four-layer invariants are correctly enforced in core scripts.**

### 1.3 Risks

- **Runtime snapshot has no TTL** - runtime-report.sh output is persisted to runtime.json but has no expiry. If context packet is consumed the next day, the runtime snapshot may be stale.
- **state vs memory journal ambiguity** - state events.jsonl and memory/journal/*.jsonl are both append-only event streams with similar schemas. No explicit type field prevents cross-contamination when reading.

---

## 2. Thread Model

### 2.1 Command vs Execution Thread

| Control-plane op | Script | Thread | Verdict |
|-----------------|--------|--------|---------|
| Sprint init | sprint-init.sh | command | PASS |
| State init | state-init.sh | command | PASS |
| Context build | context-build.sh | command | PASS |
| Decision init | decision-init.sh | command | PASS |
| Execution prompt | execution-thread-prompt.sh | command-to-execution | PASS |
| Worktree create | worktree-create.sh | command | PASS |
| Execution commit | git-commit-task.sh | execution (refuses primary worktree) | PASS |
| State writeback | state-update.sh | bidirectional via shared_repo_root() | PASS |

### 2.2 Issues

- **Separation is convention-only, not enforced** - execution thread can technically write contract or memory cards via shared_repo_root(). No read-only guard exists.
- **execution-thread-prompt.sh is informational** - it generates a text prompt, not an isolation boundary. Subsequent behavior is uncontrolled.

---

## 3. Lease / Pause / Resume

### 3.1 Field Completeness

state-init.sh defines: goal, status, duration_hours, started_at, deadline_at, paused_at, pause_reason, resume_after, resume_checkpoint, dispatch_cursor.

state-update.sh supports all lease field updates. Smoke test covers full pause-resume cycle including codex_quota scenario.

### 3.2 Issues

- **No auto-trigger** - pause/resume is purely manual via state-update.sh. No hook or timer detects quota exhaustion.
- **No deadline enforcement** - deadline_at exists as a field but no script checks timeout.
- **No lease exclusion** - two concurrent execution threads could both be running without lease conflict detection.

---

## 4. Discussion Control Plane

### 4.1 Flow

decision-init.sh creates workspace/decisions/decision_id/ with three explorer cards + synthesis.md, and writes discussion.* fields to state via state-update.sh.

### 4.2 Issues

- **CRITICAL: Templates missing** - decision-init.sh depends on .codex/templates/DECISION-EXPLORER.md and DECISION-SYNTHESIS.md which do not exist in the main workspace. Script will fail with cp error.
- **Synthesis writeback not automated** - No script merges explorer findings into synthesis and updates state. This step is fully manual.
- **Thread switch rule not enforced** - docs/decision-discussion.md says "if synthesis_path is empty, do not switch to execution thread", but no hook or gate checks this condition.

---

## 5. Role Governance (Supervisor / Executor / Skeptic)

### 5.1 Status

Expert handoff documents dispatch-create.sh and team_governance.py implementing full three-role governance with independent_skeptic and role_conflicts fields.

**These scripts do not exist in the main workspace.** The expert branch dd-hermes-execution-bootstrap-expert-a has 8 execution commits that were never integrated.

### 5.2 Impact

- state.team.* fields documented in handoff are not materialized
- dispatch-create.sh (role assignment + worktree creation) unavailable
- coordination-endpoint.sh (unified router) unavailable
- check-artifact-schemas.sh (field validation) unavailable
- The Skeptic independence truth (independent_skeptic / role_conflicts) is doc-only

---

## Summary Findings

| ID | Finding | Severity | Category |
|----|---------|----------|----------|
| A1 | Expert branch not integrated; dispatch/governance/endpoint scripts missing | CRITICAL | delivery gap |
| A2 | .codex/templates/ empty; sprint-init.sh and decision-init.sh cannot run | CRITICAL | runtime blocker |
| A3 | Thread separation is convention-only, no enforcement mechanism | MEDIUM | architecture |
| A4 | Lease has no auto-trigger, deadline enforcement, or exclusion lock | MEDIUM | resilience |
| A5 | Discussion synthesis writeback not automated | MEDIUM | control plane |
| A6 | Thread switch rule (synthesis_path check) not enforced by hook | LOW | governance |
| A7 | Runtime snapshot has no TTL | LOW | staleness |
| A8 | state events.jsonl vs memory journal schema overlap | LOW | observability |
