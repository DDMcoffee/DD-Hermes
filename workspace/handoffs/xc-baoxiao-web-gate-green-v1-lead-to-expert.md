---
handoff_id: xc-baoxiao-web-gate-green-v1-lead-to-expert
task_id: xc-baoxiao-web-gate-green-v1
from_role: lead
to_role: executor
created_at: 2026-04-18T00:00:00Z
scope: M5b baseline probe + M5c conditional fix
---

# Handoff: M5 Cross-Repo Execution Instruction

## Purpose

Lead has completed M5a (contract + state + handoff on DD Hermes side). This handoff carries the exact instruction for the executor lane (same thread, role-switched) to run the **M5b baseline probe** against XC-BaoXiaoAuto `web-main`, collect redacted evidence, return to Lead for M5c decision.

## Pre-conditions

- DD Hermes side:
  - `workspace/contracts/xc-baoxiao-web-gate-green-v1.md` exists and is signed off (this commit).
  - `workspace/state/xc-baoxiao-web-gate-green-v1/state.json` exists with `status=active`, `mode=planning`.
  - `team.role_integrity.degraded=true`, `degraded_ack_by=lead` (single-thread execution, acknowledged).
- Target repo side:
  - `/Volumes/Coding/XC-BaoXiaoAuto` is a working git repo.
  - `web-main` branch exists at commit `a6619de50df5474233cbe8a33b718817950fb196`.
  - `products/web/package.json` exists.
  - `products/web/` is the workdir for all npm commands.

## M5b Instruction Set

Run these commands **inside target repo**, not from DD Hermes. User will approve each run_command invocation individually (no SafeToAutoRun).

### Step 1: Checkout verification

```bash
git -C /Volumes/Coding/XC-BaoXiaoAuto status --short
git -C /Volumes/Coding/XC-BaoXiaoAuto rev-parse web-main
```

Expected: clean or dirty-but-unrelated status; SHA matches `target_repo_ref`. If mismatch, STOP and re-probe HEAD.

### Step 2: npm install (cwd = products/web/)

```bash
cd /Volumes/Coding/XC-BaoXiaoAuto/products/web && npm install 2>&1 | tail -c 2000
```

Capture: exit code, last 2KB of stdout+stderr (for diagnostic redacted dump to /tmp/m5b-install.txt).

Redaction check before any evidence flows back: no full paths containing real employee names (paths under `input/` or `output/` should not appear; if they do, strip before quoting).

### Step 3: typecheck

```bash
cd /Volumes/Coding/XC-BaoXiaoAuto/products/web && npm run typecheck 2>&1 | tee /tmp/m5b-typecheck.txt | tail -c 2000
```

Capture: exit code, TypeScript error summary count (e.g. "Found 12 errors in 4 files"), first few file paths (paths only, NOT line contents).

### Step 4: test

```bash
cd /Volumes/Coding/XC-BaoXiaoAuto/products/web && npm test 2>&1 | tee /tmp/m5b-test.txt | tail -c 2000
```

Capture: exit code, pass/fail count, failing test NAMES only.

### Step 5: build

```bash
cd /Volumes/Coding/XC-BaoXiaoAuto/products/web && npm run build 2>&1 | tee /tmp/m5b-build.txt | tail -c 2000
```

Capture: exit code, artifact presence (check `dist/` or whatever `build` outputs, path only).

## Evidence Return Protocol

Redact per `contract.cross_repo_boundary.forbidden_back`. Return to Lead (single thread) a summary block like:

```
M5b Evidence Summary
- target_repo HEAD: <SHA>
- npm install exit: <N>
- npm run typecheck exit: <N>, error count: <N>, files with errors: <count> (paths available on request, PII-free)
- npm test exit: <N>, passed: <N>, failed: <N>, failing test names: [<name1>, <name2>, ...]
- npm run build exit: <N>, artifact present: <yes/no>
- Any redaction events: <count>
```

## Stop Conditions (per contract blocked_if)

- `web-main` cannot check out cleanly → return BLOCKED to Lead, do not proceed.
- `npm install` fails with network errors → return BLOCKED, not this slice's problem.
- Any evidence would require forbidden_back content to be understood → return BLOCKED with "evidence quarantined at target side" note.

## Handback

After M5b evidence captured, Executor role hands back to Lead role (same thread, role-switch marker). Lead decides:

- All green → skip M5c, proceed to M5d closeout.
- Some red + fixes feasible within 2h → authorize M5c (user confirms).
- Red too deep → stop, archive slice as BLOCKED with evidence, recalibrate.

## Anti-patterns

- Do not run any `git commit` or `git push` from DD Hermes side to target_repo.
- Do not copy raw stdout into DD Hermes state.json; only redacted summaries.
- Do not read files under `products/web/input/` or `products/web/output/`.
- Do not open target_repo worktrees from DD Hermes working directory.
