# xc-baoxiao-web-gate-green-v1 (placeholder)

**Status**: M5 pending — this directory is a reserved placeholder from DD Hermes M4 cross-repo protocol bootstrap.

This mainline slice has not been started. M5 will populate real artifacts here.

## Slice Summary (from M2 selection on 2026-04-18)

- **Intent**: First green pass of `npm typecheck / test / build` on XC-BaoXiaoAuto `web-main` branch, establishing a baseline CI gate that future slices can rely on.
- **Target repo**: `/Volumes/Coding/XC-BaoXiaoAuto` (see `docs/cross-repo-execution.md`)
- **Target branch**: `web-main`
- **Execution host**: `target-repo` (all npm commands run inside XC-BaoXiaoAuto)
- **Size**: S2 (standard cross-file task with real regression risk)
- **Product goal**: Deliver a reliable green-gate signal so later XC-BaoXiaoAuto web slices can distinguish "regression" from "pre-existing red".
- **User value**: Maintainer can trust `npm run test && npm run build` exit code as the gate signal without manual interpretation.
- **Non-goals**: UI changes, integration wiring, sample data processing, DingTalk/WeCom integration (per `memory/user/user-pref-xc-baoxiao-integrations-placeholder.md`).

## Why a README placeholder instead of state.json

M4 only builds the cross-repo protocol skeleton. M5 is the milestone that actually creates `state.json` per the full protocol (`contract + state + context + handoff + worktree`). Creating an empty `state.json` now would either:

- be invalid (missing required fields), or
- look like an active slice to gate scripts and pollute `workspace/state/` index views.

## What M5 will create

- `workspace/state/xc-baoxiao-web-gate-green-v1/state.json` with full `team / product / quality / discussion` fields (per `docs/context-runtime-state-memory.md`).
- `workspace/state/xc-baoxiao-web-gate-green-v1/context.json` per-execution context packets.
- `workspace/state/xc-baoxiao-web-gate-green-v1/events.jsonl` event stream.
- `workspace/contracts/xc-baoxiao-web-gate-green-v1.md` from `workspace/contracts/_template.md` with cross-repo fields filled.
- `workspace/handoffs/xc-baoxiao-web-gate-green-v1-*.md` per handoff protocol.
- Final `workspace/closeouts/xc-baoxiao-web-gate-green-v1-*.md` post-verification.
- `openspec/proposals/xc-baoxiao-web-gate-green-v1.md` then `openspec/archive/...`.

## Cross-Repo Boundary (pre-declared)

Allowed back to DD Hermes:

- `npm typecheck` exit code
- `npm test` exit code + pass/fail counts (no test name containing PII)
- `npm run build` exit code + artifact presence
- Target repo commit SHA (the `web-main` HEAD at which the green gate passed)

Forbidden back to DD Hermes:

- Raw test output containing employee / customer names
- Any file content from `input/` or `output/` dirs (gitignored at target side)
- Real invoice numbers, amounts, or full dates

## When M5 starts

1. Delete this README.
2. Copy `workspace/contracts/_template.md` to `workspace/contracts/xc-baoxiao-web-gate-green-v1.md` and fill.
3. Create `state.json` with `schema_version: 2` and all required fields.
4. Proceed with M5 plan (see planning artifact).
