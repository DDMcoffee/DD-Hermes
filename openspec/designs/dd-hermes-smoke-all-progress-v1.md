---
status: design
owner: lead
scope: dd-hermes-smoke-all-progress-v1
decision_log:
  - Keep the authoritative command surface as `bash tests/smoke.sh all`; do not create a new runner just to get progress.
  - Preserve the existing stdout JSON success line and put progress truth on stderr so parsers do not regress.
  - Add one narrow verification surface for progress behavior instead of recursively making `all` test itself.
checks:
  - scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1
  - bash tests/smoke.sh entry
links:
  - workspace/contracts/dd-hermes-smoke-all-progress-v1.md
  - workspace/handoffs/dd-hermes-smoke-all-progress-v1-lead-to-expert-a.md
---

# Design

## Summary

`tests/smoke.sh all` should stay the authoritative shared-root regression gate, but it currently behaves like a silent long-running batch. This slice adds progress markers around each top-level smoke section, emitted on stderr so humans and captured logs can see forward motion without changing the final stdout JSON success contract.

## Interfaces

- `tests/smoke.sh`
- one narrow verification surface used only to assert the progress contract
- task-bound docs in `openspec/` and `workspace/`

## Data Flow

1. `all` mode routes top-level section execution through one helper instead of calling `run_hooks`, `run_memory`, and the rest directly.
2. The helper emits `start` and `done` progress markers for each section on stderr with the current section name and elapsed timing.
3. If a section returns non-zero, the helper emits a `fail` marker for that section and exits with the same status.
4. The existing final stdout JSON success line remains unchanged so callers that only care about pass/fail JSON do not need to change.
5. A narrow verification surface exercises progress emission without requiring recursive full-suite execution inside `all`.

## Edge Cases

- Expected non-zero commands inside smoke subtests must not be mistaken for top-level suite failure; only the wrapping top-level section result should drive `fail`.
- Section-specific invocations such as `bash tests/smoke.sh entry` should remain quiet by default unless the task explicitly opts them into the same progress helper for targeted verification.
- Shared-root stderr capture should remain useful even when stdout is redirected or parsed separately.

## Acceptance

- A maintainer can see which top-level smoke section is currently running.
- If `all` aborts, the last emitted marker identifies the stopping section.
- Progress truth does not break the existing stdout success JSON contract.

## Verification

- `scripts/test-workflow.sh --task-id dd-hermes-smoke-all-progress-v1`
- `bash tests/smoke.sh entry`
- `bash tests/smoke.sh schema`
- shared-root smoke run with stderr capture shows `start/done/fail` section markers while stdout still ends in the existing JSON success payload
