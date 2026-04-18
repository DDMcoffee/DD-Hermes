# Exploration Log: xc-baoxiao-web-m4-report-task-visibility-land-v1

## Observed State

- Local target `web-main` is still at `f70c59170aa8889df73868bb26fc0ca254424341`.
- The verified M4 report-task-visibility branch is at `2a6293508e9efd521073b5604f02f3660315e2b1`.
- The main worktree already contains six unrelated dirty paths that must survive landing.

## Slice Decision

Treat this as the same style of local landing step used for prior web slices:

1. record the dirty-path baseline;
2. stash the WIP;
3. fast-forward `web-main` to the verified branch;
4. rerun the standard web gate;
5. restore the stash and verify the same six paths return.

This keeps landing risk bounded and avoids mixing in cleanup or new product changes.
