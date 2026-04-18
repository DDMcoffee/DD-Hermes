# xc-baoxiao-web-docs-roadmap-v1 (placeholder for codex/GPT handoff)

**Status**: pre-selected as next mainline at DD Hermes recalibration M6 closeout (2026-04-18). Not yet instantiated. Next AI session (codex + GPT5.4) should pick up here.

## Why this slice exists

After M1-M6 recalibration, user chose Option 2 from the next-mainline retro candidates: a low-risk cross-repo documentation slice to validate the cross-repo protocol a second time without npm / test / build risk.

## One-line intent

Write `docs/web/roadmap.md` (or similar) inside XC-BaoXiaoAuto covering: current web product line status, integration placeholder rules (DingTalk / WeCom not wired yet per `memory/user/user-pref-xc-baoxiao-integrations-placeholder.md`), next 3-5 milestones.

## Cross-repo parameters (pre-set)

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `target_repo_branch`: `web-main`
- `target_repo_ref`: check current HEAD at pickup time; if unchanged, still `a6619de50df5474233cbe8a33b718817950fb196`
- `execution_host`: `target-repo`
- `size`: S1 (single-file doc, clear boundary)
- `task_class`: T2 (can degrade to T1 if boundary is truly narrow)
- `quality_requirement`: degraded-allowed (single-thread continues)

## Pre-existing WIP warning

At M5b probe time, `docs/web/README.md` was one of 6 uncommitted modifications on target repo. **Before starting this slice**, next session must:

1. `git -C /Volumes/Coding/XC-BaoXiaoAuto status --short` to see current WIP state
2. Decide: stash / commit / preserve-as-is per slice scope
3. If `docs/web/README.md` is still WIP and related to this slice's scope, user may want it committed first (as new baseline) rather than stashed

## Pickup checklist

1. Read:
   - `workspace/exploration/recalibration-retro-m1-m5.md` (full M1-M6 context)
   - `docs/cross-repo-execution.md` (protocol)
   - `workspace/contracts/_template.md` (contract skeleton)
   - `workspace/contracts/_archive/xc-baoxiao-web-gate-green-v1.md` (prior slice as example)
   - `memory/task/xc-baoxiao-web-gate-green-v1.md` (slice-level memory pattern)
   - `memory/self/recalibration-2026-04-18-learnings.md` (protocol quirks to avoid)
2. Copy `_template.md` → `workspace/contracts/xc-baoxiao-web-docs-roadmap-v1.md` and fill per above parameters
3. Create `workspace/state/xc-baoxiao-web-docs-roadmap-v1/state.json` (this README will be deleted at that point; follow same pattern as M5a)
4. Write handoff, execute doc work in target_repo, evidence summary back, closeout, archive
5. Commit target-side content at target_repo; record target commit SHA in DD Hermes state
6. DD Hermes side: commit the slice lifecycle artifacts per usual protocol

## What NOT to do

- Do not expand scope into non-docs changes (no code edits inside the target repo).
- Do not bring raw XC-BaoXiaoAuto business data (employee names, customer names, sample invoice content) into the roadmap document. Keep integration examples abstract.
- Do not add this slice as a reason to modify DD Hermes harness (Self-Reference Ops applies; there's no provable_need from this slice).

## Budget note

User flagged token/budget pressure at M6 closeout. Target execution time: 45-75 min. If slice exceeds 90 min, re-evaluate scope or stop and re-plan.

## Related anchors

- Previous slice: `xc-baoxiao-web-gate-green-v1` archived at `workspace/contracts/_archive/` + `workspace/closeouts/`
- DD Hermes HEAD at M6 closeout: `86dad95`
- Target repo HEAD at M5 probe: `a6619de50df5474233cbe8a33b718817950fb196`
