---
status: archived
owner: lead
scope: dd-hermes-commander-doc-consolidation-v1
decision_log:
  - Archive the proposal as absorbed work instead of leaving it as a live candidate.
  - Keep the historical proposal, but freeze the result in an archive note because the docs surface already satisfies the proposal acceptance.
checks:
  - find '指挥文档' -maxdepth 1 -type f -name '*.md' | wc -l
  - ./scripts/demo-entry.sh
links:
  - openspec/proposals/dd-hermes-commander-doc-consolidation-v1.md
  - 指挥文档/README.md
  - 指挥文档/06-一期PhaseDone审计.md
  - 指挥文档/08-恒定锚点策略.md
  - README.md
---

# Archive

## Result

`dd-hermes-commander-doc-consolidation-v1` is archived as absorbed docs work. Its acceptance is already reflected by the current command-doc surface: `指挥文档/` is held at `7` Markdown files, `README.md` provides one reading order, and the phase/anchor explanations now live in stable repo docs instead of chat-only explanation.

## Deviations

- This proposal was absorbed by later doc work instead of becoming a standalone contract/state/task package.
- The archive freezes the outcome, not a full task lifecycle.

## Risks

- Future doc drift could reopen the underlying problem, but it should happen under a new task id rather than by pretending this proposal is still pending.

## Acceptance

- The command-doc surface is already consolidated.
- The proposal no longer masquerades as an unresolved live candidate.

## Verification

- `find '指挥文档' -maxdepth 1 -type f -name '*.md' | wc -l`
- `./scripts/demo-entry.sh`
