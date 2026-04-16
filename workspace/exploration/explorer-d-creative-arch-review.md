---
decision_id: arch-review-2026-04-16
task_id: dd-hermes-arch-review
role: creative-provocateur
status: completed
reviewed_at: 2026-04-16T16:50:00Z
---

# Explorer D: Creative Provocateur

## Mandate

Challenge fundamental assumptions. Not "is the code correct?" but "is the shape right?" Draw from systems theory, game design, biology, and distributed systems.

---

## Provocation 1: Cathedral Without a Congregation

31 scripts, 5 hooks, 4 doc specs, a memory governance model with constraint immutability, a three-layer finish line, a lease/pause/resume model, a three-role governance system, and a textbook agent.

Used exactly once. 5 memory cards. Zero journal entries. Zero textbook entries. Zero session logs. One exploration log. One completed execution slice never integrated.

Governance-to-work ratio: approximately 50:1.

In game design this is "tutorial island syndrome" -- building an elaborate tutorial before the game exists. The fix is not to delete infrastructure, but to invert the build order:

1. Do real work first (ship features, make mistakes)
2. Let pain points emerge naturally
3. Build governance only around actual failure modes

**Suggestion: Freeze all new governance scripts.** For the next 5 real tasks, use only existing scripts and track which ones you actually invoke. After 5 tasks, delete any script never called. Darwinian architecture -- let usage select survival.

---

## Provocation 2: The Script Graph is a Hidden State Machine

The actual control flow is:

```
git-bootstrap -> sprint-init -> state-init -> context-build
  -> decision-init -> [explorer writes] -> synthesis
  -> worktree-create -> execution-thread-prompt
  -> [expert works] -> git-commit-task -> verify-loop
  -> worktree-remove -> [integration?]
```

This IS a state machine. But it is implemented as 31 independent bash scripts with no central graph definition. Transitions are implicit in docs and human memory.

What happens when someone calls worktree-remove before git-commit-task? Or context-build before sprint-init? Each script has local guards, but nobody validates the global sequence.

In distributed systems, this is the Saga pattern problem -- a long-running transaction broken into compensatable steps, but without a saga coordinator.

**Suggestion: Add a single workflow.json state machine definition** that declares all valid states, valid transitions per state, required preconditions, and the implementing script. Then add a thin workflow-gate function that every script calls at the top:

```bash
workflow_gate "verify-loop" "$task_id"
```

This is 1 file + 1 function. It does not replace any existing script. It adds a global sequence guard. Invalid transitions get caught before they corrupt state.

---

## Provocation 3: Bash-Python Sandwich is the Wrong Abstraction

Every script follows the same pattern:

1. Bash: parse args, source common.sh
2. Bash: call python3 with a heredoc
3. Python: do the real work (JSON, file I/O, logic)
4. Bash: capture output, call json_out

This means: no Python type checking across scripts (each heredoc is isolated), no shared Python classes, error handling crosses language boundaries, testing requires bash subprocesses (slow, hard to mock), Python code inside heredocs gets no IDE support.

Why is Python hiding inside bash? The logic is 90% Python. In biology, this is a cell with a strong membrane (bash) but organelles (Python heredocs) that cannot communicate. Each Python block reinvents its own frontmatter parser, its own JSON serialization, its own path resolution.

**Suggestion: Extract a single hermes_core.py module** with:
- StateMachine class (the workflow.json executor from Provocation 2)
- MemoryStore class (read/write/manage/search)
- StateStore class (init/read/update)
- ContextBuilder class
- FrontmatterParser (shared, not reimplemented per script)
- ArtifactValidator (schema checks)

Keep bash scripts as thin CLI wrappers:

```bash
#!/usr/bin/env bash
exec python3 -m hermes_core.cli.state_init "$@"
```

This unlocks: unit tests without subprocess, shared types, IDE support, and eventually a Python API that Codex or other agents can call directly.

---

## Provocation 4: Memory is a Database Pretending to Be Files

Memory stores cards as individual .md files with YAML frontmatter. Retrieval is a full scan of all files, parsing frontmatter each time, doing word-bag matching.

At 5 cards this is fine. At 500 cards, memory-read.sh will open 500 files, parse 500 YAML blocks, tokenize 500 strings, return top N.

Why files? "Human-readable, git-trackable." But the journal is already JSONL (not human-friendly), the views are generated (not hand-edited), and frontmatter parsing is reimplemented in 4 different scripts.

In database theory, this is the "file system as database" anti-pattern. It works until you need queries, transactions, indexes, or joins.

**Suggestion: Keep .md files as source of truth.** Add a derived SQLite index (memory/.index.sqlite) that:
- Is rebuilt by memory-refresh-views.sh (already runs after every write)
- Contains a cards table with all frontmatter fields as columns
- Is used by memory-read.sh for fast queries instead of file scanning
- Is in .gitignore (derived, not source)

Best of both worlds: files for humans and git, SQLite for machines. Approximately 50 lines added to memory-refresh-views.sh.

---

## Provocation 5: The Multi-Agent Model Has Never Been Multi

Every piece of evidence shows a single execution thread: 1 contract, 1 expert (expert-a), 1 worktree, 1 handoff chain. The Supervisor/Executor/Skeptic model is documented but the skeptic seat is always degraded (lead plays both supervisor and skeptic).

The multi-agent architecture has a sample size of one. And that sample degraded to single-agent.

This is not a criticism -- it is a design risk. Multi-agent coordination has emergent failure modes that cannot be predicted from single-agent runs:
- Merge conflicts between concurrent expert worktrees
- State race conditions when two experts write state-update simultaneously
- Context packet staleness when one expert's work invalidates another's context
- Handoff ordering when Expert-B depends on Expert-A's output

**Suggestion: Before building more governance for multi-agent, run a real 2-expert parallel task.** Assign Expert-A and Expert-B to work on the same sprint simultaneously in separate worktrees. Document every friction point. THEN build governance around the actual friction, not the imagined friction.

If you cannot run 2 experts in parallel yet (because templates are missing, integration script does not exist), then that tells you what to build first -- not more governance, but the minimal infrastructure to enable the experiment.

---

## Provocation 6: Invert the Codex Relationship

The project frames itself as "a shell around Codex." But what if the relationship is inverted?

Currently: User -> DD Hermes harness -> Codex IDE -> AI agent
Proposed: User -> Codex IDE -> DD Hermes as a library/MCP server -> any AI agent

Instead of wrapping Codex, expose DD Hermes governance as **services that any agent can call**:
- state.read / state.update (already partially done via coordination-endpoint.sh concept)
- memory.query / memory.write
- workflow.gate (the state machine guard)
- context.build
- verify.run

This makes DD Hermes a governance microservice, not a monolithic shell. It works with Codex, Claude Code, Cursor, Windsurf, or any future AI IDE. The protocol is the product, not the shell.

**Suggestion: Reframe the project as "DD Hermes Protocol" rather than "DD Hermes Harness."** The scripts become a reference implementation of the protocol. The protocol itself (state machine, memory model, thread model, verification loop) is the reusable artifact.

---

## Provocation 7: The Four Layers Are Actually Three Plus a Cache

Context is defined as "derived, disposable, rebuildable." That is the definition of a cache, not a layer. Treating context as a first-class layer creates conceptual overhead:

- docs/context-runtime-state-memory.md gives context its own section and invariants
- context-build.sh is a complex script that assembles from multiple sources
- context.json is persisted to disk with a full schema

But context has no write path. Nothing updates context -- it is only ever rebuilt from scratch. It has no lifecycle (no expiry, no versioning, no conflict resolution). It is a projection of state + runtime + memory at a point in time.

**Suggestion: Rename the four-layer model to "runtime / state / memory + context projection."** Context becomes an explicit derived view, like memory/views/ already is. This simplifies the mental model from "four things to govern" to "three things to govern plus a build step."

---

## Summary: The Meta-Pattern

All seven provocations point to the same meta-pattern:

**DD Hermes has excellent governance design but insufficient operational pressure to validate it.**

The fix is not more design. It is more usage. Specifically:

1. Integrate the expert branch (unblock real work)
2. Run 5 real tasks through the harness (generate operational data)
3. After 5 tasks, audit which governance was used vs. bypassed
4. Kill unused governance, strengthen used governance
5. Only then consider new abstractions (state machine, Python core, SQLite index)

The architecture is a hypothesis. Usage is the experiment. Without the experiment, the hypothesis cannot be validated or invalidated.

---

## Creative Findings

| ID | Finding | Type |
|----|---------|------|
| D1 | Governance-to-work ratio is 50:1; architecture is untested by real usage | systemic risk |
| D2 | Script graph is an implicit state machine; add explicit workflow.json + gate | structural improvement |
| D3 | Bash-Python sandwich prevents testing/typing/reuse; extract hermes_core.py | technical debt |
| D4 | File-based memory will not scale; add derived SQLite index | scaling preparation |
| D5 | Multi-agent model has sample size of one; run a real parallel experiment | validation gap |
| D6 | "Shell around Codex" should be inverted to "protocol any agent can call" | strategic reframe |
| D7 | Context is a cache/projection, not a governance layer | conceptual simplification |
