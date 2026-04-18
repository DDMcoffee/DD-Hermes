# Exploration Log: xc-baoxiao-web-m5-health-http-status-v1

## Observed State

- Local target `web-main` is already at `f9c891f3bf9504146f0e831f302f550b72920e8c`, which includes readiness JSON and stale-task blockers.
- `/api/health/operational-readiness` still returns `200` even when readiness status is `blocked`.
- For M5 monitoring groundwork, this is an avoidable ambiguity.

## Slice Decision

Treat this as a narrow route-contract slice:

1. keep the JSON body unchanged;
2. map `blocked` readiness to `503`;
3. keep `ready` on `200`.

This stays aligned with M5's monitoring-preparation scope without inventing a new healthcheck protocol.
