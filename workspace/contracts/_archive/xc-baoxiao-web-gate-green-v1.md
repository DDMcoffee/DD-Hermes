---
schema_version: 2
task_id: xc-baoxiao-web-gate-green-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Establish a trustworthy green-gate signal on XC-BaoXiaoAuto `web-main` branch so future web slices can distinguish real regression from pre-existing red baseline.
user_value: A XC-BaoXiaoAuto maintainer can rely on `npm typecheck && npm test && npm run build` exit code as the authoritative gate signal without manual interpretation of which failures are "expected" versus "new".
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: Single-thread cross-repo slice with clear boundary (3 npm commands + optional fixes). Not architecture, not control plane, not high regression risk inside DD Hermes itself. Degraded independent skeptic explicitly acknowledged by lead for the recalibration track.
non_goals:
  - Do not change XC-BaoXiaoAuto product features, UI, or API behavior.
  - Do not process real sample data (input/ directory stays untouched).
  - Do not wire DingTalk / WeCom integrations (per user-pref-xc-baoxiao-integrations-placeholder).
  - Do not touch mac-main or other branches; web-main only.
  - Do not add new dependencies unless strictly required to unblock a gate failure.
  - Do not bring raw test stdout containing PII into DD Hermes tracked files.
product_acceptance:
  - `npm run typecheck` in `/Volumes/Coding/XC-BaoXiaoAuto/products/web/` exits 0.
  - `npm test` in the same directory exits 0 (pass count > 0, 0 failures).
  - `npm run build` in the same directory exits 0 and produces build artifacts.
  - Target repo commit SHA at which all three pass is recorded in DD Hermes state.
  - No PII leaks into DD Hermes tracked files (verified by redaction check).
drift_risk: This slice could drift into generic XC-BaoXiaoAuto refactoring, feature work, or integration wiring if lead stops asking "does this change move the three-command green-gate closer to stable green?". Also could drift into endless npm dependency churn if baseline is deeply red and team starts chasing every warning.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: a6619de50df5474233cbe8a33b718817950fb196
cross_repo_boundary:
  allowed_back:
    - "npm run typecheck exit code and error count (no stdout bodies containing file contents with PII)"
    - "npm test exit code, pass/fail counts, failing test NAMES only (not test bodies or assertion messages containing sample data)"
    - "npm run build exit code and artifact presence indicator"
    - "target_repo commit SHA at each checkpoint"
    - "uncovered file paths (paths OK, contents NOT OK)"
    - "dependency version diffs if any (package.json line changes)"
  forbidden_back:
    - "raw stdout from any npm command containing employee / customer names, amounts, invoice numbers"
    - "file contents from products/web/input/ or products/web/output/ or any gitignored dir"
    - "real email addresses, phone numbers, ID numbers appearing in test fixtures"
    - "full ISO dates containing day precision when day could identify a real transaction (month precision OK)"
    - "database connection strings, API keys, or any secrets from .env files"

acceptance:
  - All three product_acceptance conditions met and evidence captured in state.json.verification.
  - cross_repo_boundary verified: DD Hermes git history search for forbidden patterns returns zero hits.
  - closeout written and archived per S2 protocol.
blocked_if:
  - target_repo `web-main` cannot check out cleanly (e.g., unrelated branch dirty state).
  - npm install itself fails due to network or registry unavailability (external dependency, not this slice's problem).
  - Gate failures require changes outside products/web/ (out of scope).
  - Fix pressure exceeds 2 hours cumulative across all red gates (stop and recalibrate).

memory_reads:
  - memory/world/no-destruction-without-confirmation.md
  - memory/world/xc-baoxiao-sample-data-location.md
  - memory/user/user-pref-xc-baoxiao-integrations-placeholder.md
memory_writes:
  - memory/task/xc-baoxiao-web-gate-green-v1.md
---

# Sprint Contract

## Context

DD Hermes M1-M4 recalibrated the project from a self-referential harness into a cross-repo orchestration tool. M5 is the first real cross-repo slice proving the protocol delivers actual user value on a concrete external codebase — XC-BaoXiaoAuto web product line.

The slice targets the narrowest question a XC-BaoXiaoAuto maintainer can ask today: "if I run the three build gates on `web-main`, do they pass?" Current baseline is unknown (M5b will probe). If all three pass unchanged, this slice records the green baseline and exits. If any fail, M5c fixes them inside a target-side worktree.

## Scope

- In scope:
  - `/Volumes/Coding/XC-BaoXiaoAuto/products/web/` only (ignore mac-main, ignore shared `@codex/`).
  - npm scripts: `typecheck`, `test`, `build` (as declared in `products/web/package.json`).
  - Source files under `products/web/src/`, `products/web/tests/`, `products/web/types/` if edits required.
  - `products/web/package.json` and lockfile if a dependency bump is strictly required.
- Out of scope:
  - UI design, new features, new pages, new API endpoints.
  - mac-main branch or any cross-product work.
  - Docker / deployment / CI pipeline config.
  - Sample data under `input/` or `output/` directories.
  - Third-party integrations (DingTalk, WeCom, OCR vendor).

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo` (all npm commands run inside XC-BaoXiaoAuto)
- `target_repo_ref`: `a6619de50df5474233cbe8a33b718817950fb196` (web-main HEAD at M5a contract time)
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-gate-green-v1-lead-to-expert.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-gate-green-v1/state.json` `verification` block, redacted per `cross_repo_boundary.forbidden_back`.
- Worktree (if needed): `/Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-gate-green-v1-lead` (created target-side via target-repo's own `git worktree add`, NOT from DD Hermes).

## Acceptance

- All three product_acceptance conditions met and evidence captured in DD Hermes state.
- cross_repo_boundary respected: `git -C "/Volumes/Coding/Hermes agent for mine" log --all -S '<any-forbidden-token>'` returns no DD Hermes commits.
- Slice commits captured at target side with SHA recorded in DD Hermes state.
- closeout file written at `workspace/closeouts/xc-baoxiao-web-gate-green-v1-lead.md` per S2 protocol.

## Product Gate

- Slice stays tied to the "three-command green-gate" question. If any step starts requiring unrelated refactoring, stop and recalibrate.
- If baseline probe (M5b) shows all three already green: slice completes immediately, record SHA, done.
- If baseline has red: prioritize minimum-viable fix. A single-line config change beats a type-system overhaul.
- Stop condition: cumulative fix time exceeds 2 hours OR any fix requires cross-cutting changes beyond `products/web/`.

## Verification

- M5b (baseline probe), target-repo side:
  - `cd /Volumes/Coding/XC-BaoXiaoAuto/products/web && npm install` → capture exit code only.
  - `npm run typecheck` → capture exit code + TypeScript error count (not error bodies if they quote file lines with PII).
  - `npm test` → capture exit code + pass/fail counts + failing test names (names only).
  - `npm run build` → capture exit code + artifact path presence.
- M5c (fix, only if needed):
  - Target-side worktree commits per DD Hermes git protocol.
  - Each fix slice committed with message tying back to this contract.
- M5d (closeout):
  - DD Hermes side runs `hooks/quality-gate.sh --event Stop` with populated state.
  - closeout archived, memory task hint updated, contract archived.

## Open Questions

- If baseline typecheck fails with hundreds of errors (likely if code was never strictly typed), does this slice escalate to S3 or stop? Decision deferred until M5b evidence.
- Should `tsc --noEmit` be separated from `npm run build` tsc invocation to avoid redundant work? Decision deferred.
