# Active Memories

- `user/plotly-preference` | belief | scope=data-viz analysis-reporting | confidence=0.80
  User prefers Plotly in analysis-facing data visualization tasks.
- `user/user-pref-no-manual-generator-commands` | preference | scope=dd-hermes workflow command delegation | confidence=1.0
  User does not want to manually run generator/bootstrap helper commands; assistant should run them directly and provide ready-to-use outputs.
- `task/dd-hermes-demo-entry-v1` | commitment | scope=dd-hermes-demo-entry-v1 | confidence=0.95
  The DD Hermes phase-1 closeout added a single-command experience entry and moved the default workflow to single-thread role switching.
- `task/dd-hermes-endpoint-router-v1` | commitment | scope=dd-hermes-endpoint-router-v1 | confidence=0.9
  Router task uses task-bound backfill artifacts to trace an execution slice that was already integrated on main.
- `task/dd-hermes-experience-demo-v1` | commitment | scope=dd-hermes-experience-demo-v1 | confidence=0.95
  The first DD Hermes experience demo proved end-to-end task flow by auto-routing architecture work into discussion mode and tightening execution gating.
- `task/dd-hermes-multi-agent-dispatch` | commitment | scope=dd-hermes-multi-agent-dispatch | confidence=0.9
  Dispatch task uses task-bound backfill artifacts to trace the integrated multi-agent dispatch slice and its degraded skeptic truth on main.
- `task/worktree-first` | commitment | scope=multi-agent sprint execution | confidence=1.00
  Multi-agent implementation starts with sprint bootstrap and isolated worktrees.
- `world/no-destruction-without-confirmation` | constraint | scope=destructive-ops repo-safety | confidence=1.00
  Destructive operations require explicit confirmation or a higher-level approved rule.
- `self/tool-selection-drift` | belief | scope=planning tool-choice verification | confidence=0.65
  Tool selection may drift when runtime constraints are not checked against local facts.
