---
schema_version: 2
task_id: dd-hermes-demo-entry-v1
owner: lead
experts:
  - expert-a
product_goal: Give DD Hermes one truthful user-visible entry for the phase-1 experience surface.
user_value: Let a newcomer or maintainer run one command and immediately see what DD Hermes has already proved, instead of stitching together multiple commander docs by hand.
task_class: T2
quality_requirement: degraded-allowed
task_class_rationale: 用户可见但边界清晰的入口收口任务，涉及少量脚本和文档对齐，允许显式 degraded 监督。
non_goals:
  - Do not expand into new runtime services, scheduler recovery, provider integrations, or plugin loading.
  - Do not turn the entry slice into a new control-plane feature track.
product_acceptance:
  - One canonical command reports the current DD Hermes experience status from repo facts.
  - One canonical Chinese landing page explains the experience surface without forcing the reader into scattered commander docs.
  - The entry shows the latest proof and current mainline truth honestly.
drift_risk: This task could drift into generic doc cleanup if it stops serving the single truthful experience-entry outcome.
acceptance:
  - A single user-visible experience entry exists for DD Hermes phase-1.
  - The entry tells a human what DD Hermes can already do, what the latest end-to-end proof is, and what the next mainline task is.
  - The entry is backed by one canonical script command plus one Chinese Markdown landing page.
blocked_if:
  - Scope expands into new runtime, scheduler, provider, or plugin-loader work.
  - The task stops being a user-visible entry task and turns into a new control-plane feature.
  - Verification cannot prove that the entry reflects current repo truth.
memory_reads:
  - memory/world/no-destruction-without-confirmation.md
memory_writes:
  - memory/task/dd-hermes-demo-entry-v1.md
---

# Sprint Contract

## Context

Turn the already-proven DD Hermes experience demo into a user-visible entry point. The repo has already completed one real end-to-end experience task; this sprint should make that truth easy to inspect without reading multiple scattered docs.

## Scope

- In scope: one canonical entry script, one Chinese landing page, and the minimal README / commander-doc updates required to make the experience version discoverable.
- Out of scope: new runtime services, automatic scheduler recovery, provider integrations, or unrelated control-plane expansion.

## Required Fields

- `task_id`
- `owner`
- `experts`
- `acceptance`
- `blocked_if`
- `memory_reads`
- `memory_writes`

## Acceptance

- A newcomer can run one command and immediately see whether DD Hermes phase-1 experience mode is ready.
- The entry surfaces the latest completed end-to-end proof, including task id and commit anchors.
- The entry points at the canonical Chinese doc instead of forcing the reader to manually stitch together multiple commander files.
- The resulting experience remains truthful: it must report readiness from repo facts, not from hand-written claims.

## Product Gate

- The product outcome is one truthful experience entry, not a new control-plane feature.
- The slice must stay bounded to the canonical command, the landing page, and the minimum doc alignment needed to make them discoverable.
- If the task stops being a user-visible entry slice, it should be split instead of silently expanded.

## Verification

- `./scripts/spec-first.sh --changed-files scripts/demo-entry.sh,README.md,指挥文档/README.md,指挥文档/07-体验入口任务说明.md --spec-path openspec/proposals/dd-hermes-demo-entry-v1.md --task-id dd-hermes-demo-entry-v1`
- `bash -n scripts/demo-entry.sh`
- `./scripts/demo-entry.sh`
- `./scripts/check-artifact-schemas.sh --task-id dd-hermes-demo-entry-v1`
- User-visible proof: one command plus one Chinese landing page is enough to understand the current experience version status.

## Open Questions

- The entry should stay read-only and truthful. If users later need a richer interactive demo, should that become a separate task rather than expanding this one?
