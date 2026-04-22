# DD Hermes: Git Management

DD Hermes depends on git not as generic version-control advice, but as the mechanism that keeps the control thread and execution threads separated cleanly.

## Why

- Without an initial baseline commit, `git worktree` cannot start in a real repository.
- Without worktree lifecycle rules, multiple experts can easily contaminate each other's file surfaces.
- Without clear commit boundaries, handoffs stop being auditable.

## Roles

- Lead
  - maintains the baseline commit
  - creates and removes expert worktrees
  - performs final integration and acceptance
- Expert
  - works only inside the assigned worktree
  - returns code, handoff, and verification artifacts
  - does not write directly into the main workspace

## Scripts

- `scripts/git-status-report.sh`
  - report whether the repo has a HEAD, current branch, dirty files, worktree list, and whether bootstrap is needed
- `scripts/git-bootstrap.sh`
  - create a managed baseline commit in a repo that has `.git` but no first commit yet
- `scripts/git-snapshot.sh`
  - output `HEAD`, branch, upstream, ahead/behind status, remote URL, and dirty state for a worktree
- `scripts/git-commit-task.sh`
  - create an execution-slice commit inside an execution worktree and write the commit anchor back into task state
- `scripts/git-integrate-task.sh`
  - merge or integrate the execution branch back into the main workspace and write the integrated git anchor back into task state
- `scripts/worktree-create.sh`
  - create an isolated worktree for an expert
- `scripts/worktree-remove.sh`
  - remove an expert worktree and optionally delete its branch

## Invariants

- `git worktree` only works after the repository has a baseline commit.
- The control thread does not write implementation code inside an expert worktree.
- Before a worktree is removed, at minimum:
  - handoff is written
  - verification is written back into state
  - dirty state has been reviewed

## Commit Boundary

- baseline commit
  - created by Lead so the worktree system can function
- execution commit
  - created by an Expert inside the assigned worktree
  - represents one reviewable execution slice
  - must write a git anchor such as `state.git.latest_commit` back into task state
- integration commit
  - created by Lead in the main workspace after merge or consolidation
  - represents a reviewable integrated unit
  - the standard entrypoint is `scripts/git-integrate-task.sh`, not an informal manual merge convention
