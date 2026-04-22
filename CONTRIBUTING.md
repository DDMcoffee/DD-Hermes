# Contributing to DD Hermes

Thanks for helping improve DD Hermes.

This repository is not trying to become another agent runtime. Its core purpose is to maintain a runnable, inspectable, and reusable control plane for complex agent work. Contributions should protect that goal first.

## Principles

- Reuse existing templates, scripts, and artifact patterns before introducing new abstractions.
- Keep `README.md` as a stable landing page, not a live runtime truth surface.
- Put runtime truth in `workspace/`, `openspec/`, `memory/`, and `指挥文档/`.
- Do not bring private target-repo data, PII, or local-only business artifacts into this repository.
- Self-referential harness proposals must prove a real mainline need rather than improving control-plane neatness for its own sake.

## Recommended Workflow

1. Read `AGENTS.md` and [`README.md`](README.md) first.
2. Decide whether the change is `S0`, `S1`, `S2`, or `S3`.
3. If the change spans more than three files, create or update a task contract under `workspace/contracts/` first.
4. Run the smallest relevant validation before claiming completion.

## Minimum Validation

Common validation commands:

```bash
bash tests/smoke.sh schema
./scripts/demo-entry.sh
./hooks/quality-gate.sh --event Stop --state workspace/state/<task_id>/state.json
```

If you changed workflow, memory, hooks, or script entrypoints, also consider:

```bash
bash tests/smoke.sh workflow
bash tests/smoke.sh hooks
bash tests/smoke.sh memory
```

## Scope Discipline

- Keep one PR focused on one clear problem.
- Do not rewrite unrelated historical documents opportunistically.
- Do not silently overwrite worktree changes that belong to someone else.
- Use relative repository links so GitHub can render them directly.

## Sensitive Boundaries

- Do not commit `.env`, secrets, tokens, or real production configuration.
- For cross-repo slices, only bring back redacted summary evidence, never raw business data.
- Pause before delete, force-push, privilege escalation, or sensitive-file writes.

## Suggested Commit Styles

- `docs: clarify github release entry`
- `chore: add contributing guide for public repo`
- `fix: use relative links in README for GitHub`
