# Exploration Log: xc-baoxiao-web-m5-stale-task-alert-v1

## Observed State

- Local target `web-main` is already at `43446505f03a382fe57f8ea837cf744019f0ca27`, which includes the health-route and auth-secret readiness rule.
- Current readiness logic still treats any running task count as a generic signal and cannot distinguish stale execution.
- The async task schema already has `startedAt` and `updatedAt`, and parser-worker keeps `updated_at` fresh while tasks progress.

## Slice Decision

Treat this as the next M5 groundwork slice:

1. count running tasks older than a fixed stale threshold;
2. feed that count into the existing readiness model;
3. keep the wording operational and blocker-oriented.

This stays aligned with M5's "monitoring and runtime alert eve" scope without prematurely building a monitoring platform.
