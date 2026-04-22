# DD Hermes: Cross-Repo Execution

DD Hermes keeps coordination artifacts such as `contract`, `state`, `verdicts`, `closeout`, and `memory` in this repository, while real business code executes in a separate target repository.
Every cross-repo slice must declare the target handle, execution location, and evidence boundary explicitly.

## Why

- The DD Hermes repo should remain a control-plane repository, not a business-implementation repository.
- Target repositories such as `XC-BaoXiaoAuto` have their own branching model, CI, dependencies, and sensitive sample data, and should not be pulled into DD Hermes history.
- The two repositories need independent truth sources; DD Hermes only records references and verdicts, not a mirror of target code.
- Raw business data containing PII such as names, invoice ids, or amounts must never enter tracked DD Hermes files.

## Roles

- DD Hermes repo
  - produces contracts, state, handoffs, exploration, closeouts, verdicts, and memory
  - runs gate scripts such as `hooks/quality-gate.sh`
  - records references to the target repo such as commit SHA and placeholder paths
  - does not directly commit or push the target repo
- target repo
  - contains the actual business implementation
  - manages its own baseline commits, worktrees, branches, and pushes
  - runs real build, lint, and test commands
  - returns only redacted evidence summaries back to DD Hermes

## Required Contract Fields

Every `S1`, `S2`, or `S3` contract with `target_repo != self` must declare:

- `target_repo`
  - absolute path or normalized name of the target repository
  - example: `/Volumes/Coding/XC-BaoXiaoAuto`
  - `self` means a DD Hermes harness task and triggers the `Self-Reference Ops` rules in `AGENTS.md`
- `execution_host`
  - `target-repo`
    - all commands run in the target repo
  - `dd-hermes`
    - only read the target repo or construct instructions; never write target-repo files
  - `both`
    - both repositories have actions, which must be listed separately in the contract `action_plan`
- `target_repo_ref`
  - commit SHA or tag if the target repo is a git repo
  - `not-applicable` if it is not
- `cross_repo_boundary`
  - an explicit list of what evidence may flow back and what may not

## Data Flow

```text
DD Hermes repo                          Target repo
--------------                          -----------
contract ─┐                             ┌─ code changes
state     ├─ instruction ──────────────▶│  tests run
handoff  ─┘                             │  build / lint
          ┌──── evidence summary ──────┬┘ (test exit, sample count,
          │     (redacted)             │  coverage %, commit SHA)
verdicts ◀┘                            │
closeout                               └─ commit / push (target-side)
memory ◀── cross-session knowledge ────
```

- DD Hermes instructions should use placeholder paths such as `$XC_INPUT_ROOT/<employee_dir>/`, not real local business paths.
- Raw target-repo evidence stays local to the target repo.
- Only redacted summaries may cross back into tracked DD Hermes files.

## Redaction Rules

Returned evidence must not include:

- real names
- money amounts
- invoice ids, order ids, or transaction ids
- phone numbers, email addresses, or identity numbers
- full dates such as `2026-04-18`; reduce to something like `2026-04`
- real directory names when they encode private identity data

Allowed summary fields include:

- test exit codes and pass/fail counts
- coverage percentages and uncovered file paths
- sample counts and processed counts
- target-repo commit SHA
- lint error counts without the full error body

## Typical Flow

For a slice such as `xc-baoxiao-web-gate-green-v1`:

1. DD Hermes creates a contract with `target_repo=/Volumes/Coding/XC-BaoXiaoAuto`, `execution_host=target-repo`, `target_repo_ref=<current-HEAD>`, and a `cross_repo_boundary` that allows only summarized verification results.
2. DD Hermes writes instructions into a handoff, using target-repo-relative paths.
3. The target repo worktree is used for code changes, commands, and commits.
4. Only redacted evidence summaries are written back into DD Hermes state.
5. DD Hermes consumes those summaries through `quality-gate.sh` and records verdicts.
6. DD Hermes writes closeout, archive, and memory artifacts.

## Invariants

- For `target_repo != self`, DD Hermes `workspace/state/<task_id>/state.json` must contain only SHAs and redacted summaries, never raw target-repo samples.
- For cross-repo slices, `changed_code_files` used by `quality-gate.sh` must be target-repo-relative paths, not DD Hermes paths.
- DD Hermes git history must not contain real names, invoice ids, or amounts.
- DD Hermes must never read and persist data from target-repo paths protected by `.gitignore`.

## Anti-Patterns

- treating the target repo as a DD Hermes submodule or mirror
- writing real names or money amounts into DD Hermes contracts, state, or handoffs
- letting DD Hermes push the target repo directly
- letting target-repo code land without a target commit SHA written back into DD Hermes state
- using `execution_host=both` without separating both sides in the `action_plan`

## Related

- the `Cross-Repo Execution` and expanded `Git Rules` sections in `AGENTS.md`
- `memory/world/xc-baoxiao-sample-data-location.md`
- `memory/user/user-pref-xc-baoxiao-integrations-placeholder.md`
- `hooks/quality-gate.sh`
