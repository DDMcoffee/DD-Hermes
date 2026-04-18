# Exploration Log: xc-baoxiao-web-m4-pdf-boundary-visibility-land-v1

## Observed State

- Local target `web-main` is still at `2a6293508e9efd521073b5604f02f3660315e2b1`.
- The verified M4 PDF-boundary-visibility branch is at `e68b140d5065d98cda6cf551ad404fa254541a48`.
- The main worktree already contains six unrelated dirty paths that must survive landing.

## Slice Decision

Treat this as the same style of local landing step used for prior web slices:

1. record the dirty-path baseline;
2. stash the WIP;
3. fast-forward `web-main` to the verified branch;
4. rerun the standard web gate;
5. restore the stash and verify the same six paths return.

This keeps landing risk bounded and avoids mixing in cleanup or new product changes.
