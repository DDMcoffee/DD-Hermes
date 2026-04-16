# Active Memories

- `user/plotly-preference` | belief | scope=data-viz analysis-reporting | confidence=0.80
  User prefers Plotly in analysis-facing data visualization tasks.
- `user/user-pref-no-manual-generator-commands` | preference | scope=dd-hermes workflow command delegation | confidence=1.0
  User does not want to manually run generator/bootstrap helper commands; assistant should run them directly and provide ready-to-use outputs.
- `task/worktree-first` | commitment | scope=multi-agent sprint execution | confidence=1.00
  Multi-agent implementation starts with sprint bootstrap and isolated worktrees.
- `world/no-destruction-without-confirmation` | constraint | scope=destructive-ops repo-safety | confidence=1.00
  Destructive operations require explicit confirmation or a higher-level approved rule.
- `self/tool-selection-drift` | belief | scope=planning tool-choice verification | confidence=0.65
  Tool selection may drift when runtime constraints are not checked against local facts.
