---
schema_version: 2
task_id: xc-baoxiao-web-m4-artifact-download-hardening-v1
size: S2
owner: lead
experts:
  - lead

product_goal: Make the XC-BaoXiaoAuto web artifact download path more reliable by returning stable filenames with correct extensions and explicit error responses when stored artifacts cannot be read.
user_value: Downloaded export materials keep usable filenames, and broken artifact records fail with a clear message instead of a generic server error page.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: This is a bounded cross-repo API hardening slice with low file count but direct user-facing impact on a core export/download path, so it merits S2 traceability.
non_goals:
  - Do not change report-generation behavior.
  - Do not redesign the reports UI.
  - Do not land this branch onto target `web-main` in the same slice.
product_acceptance:
  - Successful artifact downloads include a stable filename with the expected file extension.
  - Storage-read failures return an explicit JSON error response instead of bubbling into a generic route crash.
  - Regression tests cover the hardened download route behavior.
drift_risk: This slice could drift into broader report-center UX, storage-driver abstraction work, or artifact lifecycle cleanup. Stop once the download route is explicit and reliable.

target_repo: /Volumes/Coding/XC-BaoXiaoAuto
execution_host: target-repo
target_repo_ref: d7d19cb875f2ff89f70885fe0b1d226578e9b9b3
cross_repo_boundary:
  allowed_back:
    - "target-side commit SHA"
    - "relative changed file paths"
    - "test/typecheck/build exit codes"
    - "download header behavior summaries"
    - "sanitized route error messages"
  forbidden_back:
    - "raw PII (employee names, invoice numbers, amounts, phone, ID, full date)"
    - "raw file contents from target_repo .gitignore-protected paths"
    - "real storage-root absolute paths from runtime env"

acceptance:
  - `/api/artifacts/[id]/download` sets a usable download filename with extension on success.
  - `/api/artifacts/[id]/download` returns an explicit error body when storage lookup fails.
  - `npm run test`, `npm run typecheck`, and `npm run build` pass on the target worktree.
blocked_if:
  - Hardening the route requires touching the user's six dirty paths on target `web-main`.
  - The fix depends on a broader storage-layer refactor instead of a local route change.
  - Existing web gate failures appear that are unrelated to this slice.
memory_reads:
  - memory/self/recalibration-2026-04-18-learnings.md
memory_writes:
  - memory/task/xc-baoxiao-web-m4-artifact-download-hardening-v1.md
---

# Sprint Contract

## Context

The M4 export path now fails honestly during bundle generation, but the download endpoint is still thin: it uses `artifact.title` directly for `Content-Disposition`, which drops the file extension for generated artifacts, and it lets storage-read failures bubble into an unstructured route crash. That leaves the final handoff path weaker than the generation path.

This slice keeps scope on the route itself. It hardens success headers and failure handling without changing how artifacts are generated.

## Scope

- In scope:
  - `/api/artifacts/[id]/download` filename hardening
  - `/api/artifacts/[id]/download` explicit storage failure response
  - route regression tests
  - standard web gate on the isolated target worktree
- Out of scope:
  - report generation changes
  - reports page redesign
  - branch landing / cleanup work

## Cross-Repo Handles

- `target_repo`: `/Volumes/Coding/XC-BaoXiaoAuto`
- `execution_host`: `target-repo`
- `target_repo_ref`: `d7d19cb875f2ff89f70885fe0b1d226578e9b9b3`
- Instruction surface: `workspace/handoffs/xc-baoxiao-web-m4-artifact-download-hardening-v1-lead-to-executor.md`
- Evidence surface: `workspace/state/xc-baoxiao-web-m4-artifact-download-hardening-v1/state.json`

## Acceptance

- Artifact downloads keep a stable filename with extension.
- Missing or unreadable storage objects fail with an explicit route response.
- Standard web gate passes after the change.

## Product Gate

- This slice stays on roadmap M4's "生成与下载路径清晰，异常时有可定位的反馈".
- Stop if the work expands into broader storage redesign or reports UI work.

## Verification

- Target repo side:
  - focused failing/passing Vitest runs for the download route
  - `npm run test`
  - `npm run typecheck`
  - `npm run build`
- DD Hermes side:
  - `./scripts/context-build.sh --task-id xc-baoxiao-web-m4-artifact-download-hardening-v1 --agent-role commander --worktree /Volumes/Coding/XC-BaoXiaoAuto/.worktrees/xc-baoxiao-web-m4-artifact-download-hardening-v1-lead`
  - `hooks/quality-gate.sh --event Stop --state workspace/state/xc-baoxiao-web-m4-artifact-download-hardening-v1/state.json`

## Open Questions

- None for scope. If filename extension recovery needs a tiny helper, keep it local to the route unless another caller truly needs it.
