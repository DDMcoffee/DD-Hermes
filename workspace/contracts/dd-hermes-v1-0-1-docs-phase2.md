---
schema_version: 2
task_id: dd-hermes-v1-0-1-docs-phase2
size: S1
owner: lead
experts:
  - lead
product_goal: Continue the v1.0.1 documentation line by converting remaining deep DD Hermes protocol docs to English-first public-maintainer references.
user_value: A GitHub reader or future maintainer can read the deeper coordination and schema contracts without depending on Chinese-only internal context.
task_class: T1
quality_requirement: degraded-allowed
task_class_rationale: Narrow repository-doc refinement with no production-code execution surface and low regression risk.
non_goals:
  - Do not rewrite the underlying coordination scripts or protocol semantics.
  - Do not overwrite archived review history or versioned V2 materials.
  - Do not claim social preview Settings upload is complete when GitHub tooling still blocks it.
product_acceptance:
  - `docs/coordination-endpoints.md` is English-first and preserves endpoint truth.
  - `docs/artifact-schemas.md` is English-first and preserves schema truth.
  - The task leaves a minimal DD Hermes trace artifact package and passes repo smoke validation.
drift_risk: This slice would drift if it expands from doc translation and truth clarification into protocol redesign or unrelated doc cleanup.
acceptance:
  - The two targeted deep docs are English-first and remain faithful to current repository behavior.
  - A minimal S1 contract and state artifact exist for this continuation slice.
  - `bash tests/smoke.sh schema` passes after the doc updates.
blocked_if:
  - The translation would require changing protocol behavior rather than documenting existing behavior.
  - Repo validation fails for reasons unrelated to this slice and cannot be separated.
memory_reads:
  - /Users/davidm/.codex/memories/MEMORY.md
memory_writes: []
---

# Sprint Contract

## Context

`v1.0.0` is already public on GitHub, and `v1.0.1` started an English-first cleanup pass for deeper DD Hermes documentation. Three foundational docs are already converted. The next bounded step is to convert the remaining protocol-heavy references that still block English-first reading: endpoint contracts and artifact schemas.

## Scope

- In scope: `docs/coordination-endpoints.md`, `docs/artifact-schemas.md`, and minimal trace artifacts for this S1 slice.
- Out of scope: script behavior changes, new endpoint additions, schema redesign, release-version bumps, or GitHub Settings automation.

## Required Fields

- Preserve current endpoint names, script paths, and required response-field inventories.
- Preserve current schema semantics for `T0/T1` no-execution tasks and `execution_closeout` handling.
- Record this continuation slice under `workspace/contracts/` and `workspace/state/`.

## Acceptance

- Both docs read naturally in English and remain aligned with current repo truth.
- The slice remains documentation-only and does not mutate runtime behavior.
- The repo passes schema smoke after the changes.

## Verification

- `bash tests/smoke.sh schema`

## Open Questions

- Whether the next v1.0.1 pass should convert `docs/long-term-agent-division.md` or other remaining deeper references first.

## Product Gate

This slice stays tied to the public-maintainer documentation goal for `v1.0.1`. Stop if the work starts changing the protocol itself instead of clarifying it.
