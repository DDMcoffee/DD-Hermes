# Exploration Log: xc-baoxiao-web-m5-operational-readiness-v1

## Observed Gap

- `admin.overview` currently reports only aggregate counts.
- The page does not answer readiness questions that matter for M5: HTTP vs HTTPS posture, local vs placeholder storage posture, async-task pressure, and DingTalk placeholder status.

## Existing Signals Available

- `env.appBaseUrl` already exposes current URL posture.
- `env.storageDriver` already exposes current storage-driver posture.
- `async_tasks` already provides pending/running/failed counts for current operational pressure.
- DingTalk is already an explicit placeholder in the route layer.

## Slice Decision

Keep the next M5 step narrow:

1. extend admin overview service with readiness-oriented facts;
2. add a pure helper that turns those facts into readable readiness signals;
3. render a readiness section on the admin overview page;
4. prove the service shape and summary logic with focused tests.
