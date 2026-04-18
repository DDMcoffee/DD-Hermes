# Exploration Log: xc-baoxiao-web-m4-export-failure-state-land-v1

## Observed State

- Local target `web-main` is still at `95bb706de73aaccd0820f0facd7a235d98408423`.
- The verified M4 export-failure-state branch is at `d7d19cb875f2ff89f70885fe0b1d226578e9b9b3`.
- The main worktree already contains six unrelated dirty paths that must survive landing.

## Slice Decision

Treat this as the same style of local landing step used for prior web slices:

1. record the dirty-path baseline;
2. stash the WIP;
3. fast-forward `web-main` to the verified branch;
4. rerun the standard web gate;
5. restore the stash and verify the same six paths return.

This keeps landing risk bounded and avoids mixing in cleanup or new product changes.
