# DD Hermes GitHub Release V1

This document defines the public release scope, promises, and boundaries for the GitHub-facing V1 of DD Hermes.

## Release Goal

A first-time visitor should be able to answer these questions without reading chat history:

- What is DD Hermes?
- What problem does it solve?
- How is it related to a target business repository?
- Where should someone start?
- How can they run a minimum validation pass?
- Under which license can they reuse it?

## Stable V1 Surface

The following are in scope for the public V1 release:

- `README.md`
  - repository positioning, structure, and quick-start entry
- `LICENSE`
  - public licensing under `MIT`
- `docs/quickstart.md`
  - English-first onboarding and usage path
- `docs/releases/github-v1.0.0.md`
  - full first-release copy in English, Japanese, Korean, and Chinese
- `docs/releases/github-v1.0.0-short.md`
  - short release summary ready for the GitHub Release page
- `scripts/`
  - task state, context, memory, workflow, git, and verification scripts
- `hooks/`
  - dangerous-op interception, quality gate, and session logging
- `docs/`
  - long-lived protocol docs such as context/runtime/state/memory and cross-repo execution
- `workspace/` and `openspec/`
  - task-level truth, design trail, and archive trail

## Not Part Of The V1 Stability Promise

- evolving drafts under `V2/`
- any point-in-time active mainline conclusion
- target-repo business implementation or sample data
- turning DD Hermes into a new runtime, provider, or plugin loader

## Recommended Reading Order

1. [`README.md`](../README.md)
2. [`docs/quickstart.md`](./quickstart.md)
3. [`docs/context-runtime-state-memory.md`](./context-runtime-state-memory.md)
4. [`docs/cross-repo-execution.md`](./cross-repo-execution.md)
5. run `./scripts/demo-entry.sh`

## Minimum Validation

Before publish, at minimum run:

```bash
bash tests/smoke.sh schema
./scripts/demo-entry.sh
```

If the change touches hooks, memory, or workflow, also consider:

```bash
bash tests/smoke.sh hooks
bash tests/smoke.sh memory
bash tests/smoke.sh workflow
```

## GitHub Publish Checklist

- README links render correctly on GitHub
- public docs use relative paths instead of local absolute paths
- minimum smoke verification passes
- no target-repo private data or PII is included
- live runtime truth is not hardcoded into the landing page

## Known Boundary

- The public landing surface is English-first, but some deeper operational materials remain Chinese-first.
- If the project later expands to a broader open-source audience, add issue templates, PR templates, and more complete English coverage in deeper docs.
