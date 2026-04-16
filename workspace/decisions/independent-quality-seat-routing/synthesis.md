---
decision_id: independent-quality-seat-routing
task_id: dd-hermes-independent-quality-seat-v1
owner: lead
status: synthesized
---

# Decision Synthesis

## Goal

Decide how phase-2 should advance from archived anchor governance to a real independent-quality-seat mainline without reopening runtime or thread-model work.

## Accepted Path

- Keep `dd-hermes-independent-quality-seat-v1` as a planning-first mainline that defines the first implementation boundary before code changes begin.
- Put quality-seat truth in the existing control plane: state, context summary, dispatch output, thread/quality gates, artifact schema checks, and task evidence.
- Standardize the maintainer-facing semantic pair as `independent` versus `degraded`, with explicit reasons whenever the seat is degraded.
- Limit the first implementation slice to shared governance scripts, schema checks, and smoke coverage.

## Rejected Paths

- Reject a new runtime, provider, gateway, scheduler, or manager-agent layer; the repo already has enough control-plane surface for this slice.
- Reject a docs-only expansion that adds explanation without changing dispatch or gate truth.
- Reject entering implementation before synthesis exists and the execution boundary is explicit.

## Execution Boundary

- May modify `scripts/team_governance.py`, `scripts/state-read.sh`, `scripts/context-build.sh`, `scripts/dispatch-create.sh`, `hooks/thread-switch-gate.sh`, `hooks/quality-gate.sh`, `scripts/check-artifact-schemas.sh`, and related smoke assertions.
- May update the task’s contract, handoff, closeout placeholder, and archive expectations as part of the same bounded slice.
- Must not add new runtime services, schedulers, providers, gateways, or a new chat-thread orchestration model.

## Executor Handoff

- First implementation slice should make the quality seat readable and enforceable as `independent` or `degraded` across state/context/dispatch/gates.
- The slice must prove one blocked path for missing independent-quality truth and one passing path for explicit degraded or independent truth, with tests.
- Do not open the execution slice until the planning package passes workflow, context, and schema checks.
