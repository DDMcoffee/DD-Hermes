# Exploration Log: xc-baoxiao-web-m5-storage-probe-readiness-v1

## Observed State

- Local `web-main` is now at `d899931e66861530533383cfe7ea40df662b312d`.
- `summarizeOperationalReadiness` already knows how to block on `storageDriverReady === false`, but `admin-service` currently sets that flag with `env.storageDriver === "local"`.
- That means readiness can falsely report storage as ready even when the configured local root is missing or unwritable.

## Slice Decision

Treat this as a narrow M5 runtime-readiness honesty slice:

1. keep the existing readiness shape;
2. add a storage probe that checks the current local driver can actually be used;
3. feed the probe result into admin overview and readiness summary;
4. prove the new behavior with red-green tests.

This stays aligned with roadmap M5 because it tightens deployment-groundwork truth without opening COS work or broader storage refactors.
