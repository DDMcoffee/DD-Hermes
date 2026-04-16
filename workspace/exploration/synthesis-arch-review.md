---
decision_id: arch-review-2026-04-16
task_id: dd-hermes-arch-review
status: synthesized
synthesized_at: 2026-04-16T16:45:00Z
explorer_sources:
  - workspace/exploration/explorer-a-architecture-arch-review.md
  - workspace/exploration/explorer-b-delivery-arch-review.md
  - workspace/exploration/explorer-c-curriculum-arch-review.md
  - workspace/exploration/explorer-d-creative-arch-review.md
---

# Synthesis: DD Hermes Architecture Review (v2)

## Goal

Assess DD Hermes harness maturity across context / runtime / state / memory governance, identify blockers, define execution boundary, and challenge structural assumptions via creative review.

---

## Overall Assessment

Design quality is HIGH: four-layer boundaries are crisp, invariants are strict, thread model is clear, memory governance has complete write/conflict/constraint protection.

Delivery has a CRITICAL gap: expert branch was never integrated. 10+ scripts and all templates are missing from the main workspace. Core workflows (sprint-init, decision-init) cannot run.

**Explorer D meta-finding: The architecture is a hypothesis that has never been tested by real operational load.** The governance-to-work ratio is ~50:1. The multi-agent model has a sample size of one (and that one degraded to single-agent). This is the deepest risk -- not any single missing script, but the absence of empirical validation for the entire design.

Maturity scores (1-5, Design / Implementation / Operation):

- **Context**: 5/4/3 - design excellent, scripts complete, runtime snapshot lacks TTL
- **Runtime**: 4/4/3 - runtime-report.sh complete, snapshot has no expiry
- **State**: 5/5/4 - most mature layer, lease model complete, good smoke coverage
- **Memory**: 5/4/2 - governance logic strong, only 5 cards exist, retrieval will degrade
- **Git/Worktree**: 4/4/3 - lifecycle scripts complete, missing integration + pre-remove check
- **Verification**: 4/3/2 - verify-loop is retry-only not repair; quality-gate needs external data
- **Discussion**: 4/2/1 - templates missing, synthesis not automated, thread switch not enforced
- **Role Governance**: 4/0/0 - code exists only on unmerged expert branch
- **Observability**: 3/3/1 - session-end-log exists but logs dir empty, no downstream consumer

---

## Accepted Path

Priority-ordered improvement items. Items marked BLOCKER must be resolved before any other execution.

### P0: BLOCKERS (must fix to unblock all other work)

**P0-1: Integrate expert branch into main workspace**

The expert branch dd-hermes-execution-bootstrap-expert-a contains 8 execution commits with critical files:
- All .codex/templates/ (SPRINT-CONTRACT.md, HANDOFF-LEAD.md, EXPLORATION-LOG.md, OPENSPEC-PROPOSAL.md, DECISION-EXPLORER.md, DECISION-SYNTHESIS.md, EXECUTION-CLOSEOUT.md)
- scripts/dispatch-create.sh, team_governance.py, coordination-endpoint.sh
- scripts/check-artifact-schemas.sh, test-artifact-schemas.sh, test-coordination-endpoint.sh
- docs/coordination-endpoints.md, artifact-schemas.md, long-term-agent-division.md

Action: Lead merges expert branch, resolves conflicts, runs full smoke suite.

**P0-2: Verify sprint-init.sh and decision-init.sh work after integration**

Both scripts will fail without templates. After P0-1, run:
- scripts/sprint-init.sh --task-id integration-test --owner lead --experts expert-a
- scripts/decision-init.sh --task-id integration-test --decision-id test-decision
- tests/smoke.sh all

### P1: HIGH (next sprint)

**P1-1: Add git-integrate-task.sh**

Create a script that:
- Merges execution branch into command branch
- Runs post-integration verification
- Updates state with integration commit SHA
- Updates OpenSpec stage

This closes the "task done" layer gap.

**P1-2: Add pre-remove validation to worktree-remove.sh**

Before removing a worktree, check:
- Handoff file exists for this task+expert
- state.verification.last_pass is true
- Warn on dirty state

**P1-3: Upgrade memory-read.sh retrieval**

Add confidence weighting and recency bonus to scoring:
- score = token_matches + (confidence * 10) + recency_bonus
- This is a minimal change that delays the need for vector search

**P1-4: Bootstrap textbook directory structure**

Create docs/textbook/{entries,daily,chapters,sources}/ directories. Without these, textbook-record.sh will fail in the real workspace.

### P2: MEDIUM (second sprint)

**P2-1: Add thread-switch gate hook**

A PreToolUse or custom hook that checks: if discussion.policy == 3-explorer-then-execute AND discussion.synthesis_path is empty, block execution thread dispatch.

**P2-2: Add lease deadline enforcement**

A script or hook that checks state.lease.deadline_at against current time and auto-pauses if exceeded.

**P2-3: Add session log analytics**

A script that reads workspace/logs/session-*.jsonl and produces:
- Tool usage trends
- Error frequency
- Fragmentation score
- Auto-suggest knowledge base entry when error_count >= 3

**P2-4: Add memory decay scheduling**

A script (or hook on SessionEnd) that runs memory-manage.sh --mode decay on cards past their decay_policy interval.

### P3: LOW (backlog)

- P3-1: Add runtime snapshot TTL check to context-build.sh
- P3-2: Add explicit type field to state events.jsonl to distinguish from memory journal
- P3-3: Add journal compaction script
- P3-4: Add multi-expert concurrent smoke test scenario
- P3-5: Add lease exclusion lock for concurrent execution threads

### P-STRATEGIC: Architectural Evolution (from Explorer D)

These are not bugs or missing features. They are structural shifts to consider after P0-P1 stabilization and after 5+ real tasks have validated the current design.

**S1: Explicit state machine (workflow.json + workflow-gate)**

The 31 scripts form an implicit state machine with no central graph. Adding a declarative workflow.json and a thin gate function (called at the top of each script) would prevent invalid transitions without replacing any script. Priority: after P1, when operational data shows which transitions actually get misused.

**S2: Extract hermes_core.py from bash-Python sandwich**

Every script embeds isolated Python heredocs that reinvent frontmatter parsing, JSON handling, and path resolution. A shared Python module with thin bash wrappers would unlock unit testing, type safety, and IDE support. Priority: after P1, as a refactoring sprint.

**S3: SQLite index for memory retrieval**

Keep .md files as source of truth for humans/git. Add a derived .index.sqlite (gitignored) rebuilt by memory-refresh-views.sh. Used by memory-read.sh for fast queries. ~50 lines. Priority: when memory count exceeds ~30 cards.

**S4: Reframe as "DD Hermes Protocol" not "DD Hermes Harness"**

Expose governance as services (state.read, memory.query, workflow.gate, context.build, verify.run) that any agent IDE can call, not just Codex. The scripts become a reference implementation. The protocol is the product. Priority: after the harness is proven by 5+ real tasks.

**S5: Run a real 2-expert parallel experiment**

The multi-agent model has never been multi. Before building more governance, run 2 experts on the same sprint in parallel worktrees. Document every friction point. Build governance around actual friction, not imagined friction. Priority: immediately after P0 integration.

**S6: Context is a projection, not a layer**

Context has no write path, no lifecycle, no conflict resolution. It is a cache/projection of state + runtime + memory. Consider renaming the four-layer model to "runtime / state / memory + context projection" to reduce conceptual overhead. Priority: documentation update, low risk.

---

## Rejected Paths

- **Vector database for memory retrieval** - Out of scope per project goals. Word-bag + confidence/recency weighting is sufficient for the foreseeable scale. SQLite index (S3) is the intermediate step if needed.
- **New agent runtime** - DD Hermes is explicitly a harness, not a runtime. Do not build message gateway, provider layer, or plugin loader.
- **Automated synthesis merging** - The 3-explorer synthesis step should remain human/lead-driven. Automating it risks losing the deliberation quality that justifies the protocol.
- **Enforced read-only execution thread** - File-system permissions would be fragile across platforms. Convention + worktree isolation is the right level of enforcement for now.
- **Immediate full rewrite to Python** - Explorer D's hermes_core.py suggestion (S2) is valid long-term but should NOT be attempted before P0-P1 stabilization. Premature refactoring on an unvalidated architecture wastes effort.
- **Deleting unused governance scripts now** - Explorer D's "Darwinian architecture" suggestion is philosophically correct but premature. The scripts need to be runnable first (P0) before usage-based pruning can be measured.

---

## Execution Boundary

The next execution sprint should be scoped to P0 + P1 + S5:

1. Integrate expert branch (P0-1)
2. Verify core workflows (P0-2)
3. Add git-integrate-task.sh (P1-1)
4. Add worktree pre-remove validation (P1-2)
5. Upgrade memory-read.sh scoring (P1-3)
6. Bootstrap textbook directories (P1-4)
7. **Run a real 2-expert parallel task (S5)** -- this is the empirical validation that Explorer D demands

Estimated scope: 6 files changed/created, 1 branch merge, 1 full smoke run, 1 parallel experiment.

Do NOT include P2/P3/S1-S4 items in this sprint. They require both the P0/P1 foundation and operational data from real usage.

---

## Executor Handoff

### Task: dd-hermes-integration-sprint

**Owner**: lead

**Experts**: expert-a (integration), expert-b (new scripts)

**Expert-A scope**:
- Merge dd-hermes-execution-bootstrap-expert-a into main
- Resolve any conflicts
- Run tests/smoke.sh all
- Fix any breakage from integration

**Expert-B scope**:
- Create scripts/git-integrate-task.sh
- Add pre-remove validation to worktree-remove.sh
- Upgrade memory-read.sh with confidence + recency weighting
- Create docs/textbook/{entries,daily,chapters,sources}/ directories
- Add smoke test coverage for integration commit and pre-remove

**Acceptance criteria**:
- tests/smoke.sh all passes
- sprint-init.sh and decision-init.sh produce valid output
- dispatch-create.sh and coordination-endpoint.sh are available and smoke-tested
- git-integrate-task.sh can merge an execution branch and update state
- worktree-remove.sh warns on missing handoff/verification

**Verification**:
- tests/smoke.sh all
- scripts/sprint-init.sh --task-id verify-sprint --owner lead --experts expert-a
- scripts/decision-init.sh --task-id verify-sprint --decision-id verify-decision

---

## Cross-Explorer Finding Consolidation

Total findings: 32 (Explorer A: 8, Explorer B: 8, Explorer C: 9, Explorer D: 7)

### CRITICAL (3)

| ID | Finding | Source |
|----|---------|--------|
| A1/B2 | Expert branch not integrated; 10+ scripts missing | A + B |
| A2/B1 | .codex/templates/ empty; core workflows broken | A + B |
| C4 | Textbook agent dormant; templates and directories missing | C |

### HIGH (4)

| ID | Finding | Source |
|----|---------|--------|
| B3 | No integration commit script | B |
| B4 | worktree-remove.sh lacks pre-check | B |
| C2 | memory-read.sh word-bag retrieval will degrade at scale | C |
| C3 | Journal directory empty; zero provenance history | C |

### MEDIUM (8)

| ID | Finding | Source |
|----|---------|--------|
| A3 | Thread separation is convention-only | A |
| A4 | Lease has no auto-trigger or deadline enforcement | A |
| A5 | Discussion synthesis writeback not automated | A |
| B5 | verify-loop.sh is retry-only | B |
| B6 | quality-gate.sh relies on caller-supplied data | B |
| B7 | No multi-expert concurrent smoke test | B |
| C5 | Session logs not consumed downstream | C |
| C6 | No scheduled decay or auto-archive | C |

### LOW (7)

| ID | Finding | Source |
|----|---------|--------|
| A6 | Thread switch rule not enforced by hook | A |
| A7 | Runtime snapshot no TTL | A |
| A8 | state events vs memory journal schema overlap | A |
| B8 | worktree-create.sh uses repo_root() | B |
| C7 | "3+ errors auto-suggest KB" not implemented | C |
| C8 | memory-read.sh lacks recency/confidence weighting | C |
| C9 | No journal compaction | C |

### STRATEGIC (7, from Explorer D)

| ID | Finding | Source |
|----|---------|--------|
| D1 | Governance-to-work ratio ~50:1; architecture untested by real usage | D |
| D2 | Script graph is implicit state machine; add workflow.json + gate | D |
| D3 | Bash-Python sandwich prevents testing/typing/reuse; extract hermes_core.py | D |
| D4 | File-based memory will not scale; add derived SQLite index | D |
| D5 | Multi-agent model has sample size of one; run parallel experiment | D |
| D6 | Reframe as protocol (services any agent can call) not monolithic shell | D |
| D7 | Context is a projection/cache, not a governance layer | D |

### STRENGTH (1)

| ID | Finding | Source |
|----|---------|--------|
| C1 | memory-write.sh constraint protection is well-implemented | C |
