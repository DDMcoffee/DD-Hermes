---
schema_version: 2
task_id: dd-hermes-v1-release-closure-plan
size: S1
owner: lead
experts:
  - lead
product_goal: Produce a finishable DD Hermes V1 release-closure plan that turns the already-published v1.0.0 release into an explicit done state instead of an open-ended ongoing release.
user_value: A maintainer can tell in one document what counts as V1 done, what does not block V1, and where follow-up work belongs.
task_class: T1
quality_requirement: degraded-allowed
task_class_rationale: Repository-document synthesis task with live release verification but no runtime or protocol implementation changes.
non_goals:
  - Do not reopen the V1 release scope itself.
  - Do not fold v1.0.1 polish work back into the V1 release gate.
  - Do not modify GitHub release/tag state in this slice.
product_acceptance:
  - A repo-local markdown plan states V1 definition of done, closure steps, acceptance checks, and non-goals.
  - The plan explicitly distinguishes published V1 from v1.0.1 polish.
  - The plan is grounded in current GitHub and repository facts.
drift_risk: This task would drift if it turned into more release polish or protocol changes instead of documenting the closure boundary.
acceptance:
  - `docs/releases/github-v1-closure-plan.md` exists and is grounded in live repo and GitHub facts.
  - `bash tests/smoke.sh schema` passes after adding the plan artifacts.
  - `./scripts/demo-entry.sh` still reports the expected phase-done surface.
blocked_if:
  - Live GitHub release facts contradict the current repo release documents.
  - The task expands into modifying release scope instead of documenting closure.
memory_reads:
  - /Users/davidm/.codex/memories/MEMORY.md
memory_writes: []
---

# Sprint Contract

## Context

DD Hermes V1 has already been published publicly on GitHub at `v1.0.0`, but follow-up documentation work on `v1.0.1` risks making the release feel permanently unfinished. The maintainer needs one explicit closure plan that freezes the V1 boundary, preserves the release truth, and routes further work into the proper follow-up line.

## Scope

- In scope: one release-closure plan document plus minimal S1 control-plane trace for the planning slice.
- Out of scope: release re-tagging, changing GitHub settings, or widening V1 content.

## Required Fields

- State clearly that V1 is already published and complete at `v1.0.0`.
- Distinguish Must / Should / Deferred work.
- Include live release anchors, ordered closure steps, acceptance checks, and non-goals.

## Acceptance

- The plan gives a maintainer a crisp finish line for V1.
- The plan keeps v1.0.1 polish outside the V1 release gate.
- Repo smoke still passes after the plan lands.

## Verification

- `bash tests/smoke.sh schema`
- `./scripts/demo-entry.sh`

## Open Questions

- Whether a separate closeout note should later be added on the docs branch once v1.0.1 polish is merged.

## Product Gate

This slice exists to freeze the V1 release boundary, not to add more polish into V1 or to expand the public promise.
