---
# ═══ Required for ALL contracts ═══
schema_version: 2
task_id: "<task-id-kebab-case>"
size: "<S0 | S1 | S2 | S3>"  # see AGENTS.md Task Size Gradation; mandatory
owner: "<role: lead | expert-a | ...>"
experts:
  - "<expert-role>"

# ═══ Product anchor (mandatory for S2/S3; optional for S1 mainline subslice) ═══
product_goal: "<one-sentence product outcome this slice delivers>"
user_value: "<concrete user-visible value after this slice lands>"
task_class: "<T0 | T1 | T2 | T3 | T4>"  # see AGENTS.md Multi-Agent Strategy
quality_requirement: "<strict | degraded-allowed>"
task_class_rationale: "<why this class, not higher or lower>"
non_goals:
  - "<what this slice explicitly does not do>"
product_acceptance:
  - "<verifiable product-level pass condition>"
drift_risk: "<how this slice could drift; stop condition>"

# ═══ Harness self-reference check (mandatory if touching DD Hermes harness) ═══
# Uncomment these two lines ONLY when the contract topic is DD Hermes self-harness
# (runtime / router / dispatch / memory runtime / new scripts / new protocols).
# provable_need: "<file path + concrete observation showing a current real slice demands this>"
# harness_self_reference: true

# ═══ Cross-repo execution (mandatory if target_repo != self) ═══
target_repo: "self"  # change to absolute path (e.g. /Volumes/Coding/XC-BaoXiaoAuto) for cross-repo slice
execution_host: "dd-hermes"  # or "target-repo" / "both"; see AGENTS.md Cross-Repo Execution
target_repo_ref: "not-applicable"  # set to commit SHA or tag when target_repo != self and is a git repo
cross_repo_boundary:
  allowed_back:
    - "<e.g. test exit code>"
    - "<e.g. coverage percent>"
    - "<e.g. sample count>"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "complete directory names containing real-person tokens"

# ═══ Execution boundaries ═══
acceptance:
  - "<verifiable slice-level pass condition>"
blocked_if:
  - "<observable condition that blocks this slice>"
memory_reads:
  - "<memory/world/... or memory/user/... path>"
memory_writes:
  - "memory/task/<task-id>.md"
---

# Sprint Contract

## Context

<One to three paragraphs stating the narrow observable gap this slice closes. Reference concrete files / behaviors, not abstract goals.>

## Scope

- In scope: <concrete file paths or behaviors>
- Out of scope: <things this slice explicitly does NOT touch>

## Cross-Repo Handles

<Only required when target_repo != self. Delete this section for harness-local slices.>

- `target_repo`: <absolute path>
- `execution_host`: <target-repo | dd-hermes | both>
- `target_repo_ref`: <commit SHA>
- Instruction surface: <handoff file path, relative paths inside target_repo only>
- Evidence surface: <which files in state.json will carry redacted summaries>

## Acceptance

- <Explicit pass condition 1>
- <Explicit pass condition 2>

## Product Gate

- <Why this slice stays tied to the mainline product outcome>
- <What triggers a stop-and-recalibrate>

## Verification

- <Commands or scripts that prove acceptance>
- <For cross-repo slice, where the command runs: target_repo or dd-hermes>

## Open Questions

- <Unresolved question with a decision deadline>
