#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

endpoint=""
task_id=""
agent_role=""
worktree=""
memory_limit=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --endpoint) endpoint="$2"; shift 2 ;;
    --task-id) task_id="$2"; shift 2 ;;
    --agent-role) agent_role="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --memory-limit) memory_limit="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *)
      if [[ -z "$endpoint" ]]; then
        endpoint="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$endpoint" ]]; then
  json_out '{"error":"endpoint is required","supported":["state.read","state.update","context.build","dispatch.create","closeout.check","lease.check","thread.gate","git.integrate","session.analytics","memory.decay","journal.compact","successor.audit"]}'
  exit 3
fi

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

case "$endpoint" in
  state.read)
    "$SCRIPT_DIR/state-read.sh" --task-id "$task_id"
    ;;
  state.update)
    input_json=$(read_stdin_json)
    printf '%s' "$input_json" | "$SCRIPT_DIR/state-update.sh" --task-id "$task_id"
    ;;
  context.build)
    cmd=("$SCRIPT_DIR/context-build.sh" --task-id "$task_id")
    if [[ -n "$agent_role" ]]; then
      cmd+=(--agent-role "$agent_role")
    fi
    if [[ -n "$worktree" ]]; then
      cmd+=(--worktree "$worktree")
    fi
    if [[ -n "$memory_limit" ]]; then
      cmd+=(--memory-limit "$memory_limit")
    fi
    "${cmd[@]}"
    ;;
  dispatch.create)
    "$SCRIPT_DIR/dispatch-create.sh" --task-id "$task_id"
    ;;
  closeout.check)
    "$SCRIPT_DIR/check-artifact-schemas.sh" --task-id "$task_id"
    ;;
  lease.check)
    cmd=("$SCRIPT_DIR/lease-check.sh" --task-id "$task_id")
    if [[ -n "${AUTO_PAUSE:-}" ]]; then
      cmd+=(--auto-pause)
    fi
    "${cmd[@]}"
    ;;
  thread.gate)
    "$SCRIPT_DIR/../hooks/thread-switch-gate.sh" --task-id "$task_id" --target "${TARGET_THREAD:-execution}"
    ;;
  git.integrate)
    cmd=("$SCRIPT_DIR/git-integrate-task.sh" --task-id "$task_id")
    if [[ -n "${EXPERT:-}" ]]; then
      cmd+=(--expert "$EXPERT")
    fi
    "${cmd[@]}"
    ;;
  session.analytics)
    "$SCRIPT_DIR/session-analytics.sh" --days "${ANALYTICS_DAYS:-7}"
    ;;
  memory.decay)
    cmd=("$SCRIPT_DIR/memory-decay-schedule.sh")
    if [[ -n "${MAX_AGE_DAYS:-}" ]]; then
      cmd+=(--max-age-days "$MAX_AGE_DAYS")
    fi
    cmd+=(--dry-run)
    "${cmd[@]}"
    ;;
  journal.compact)
    "$SCRIPT_DIR/journal-compact.sh" --dry-run
    ;;
  successor.audit)
    "$SCRIPT_DIR/successor-evidence-audit.sh"
    ;;
  *)
    json_out '{"error":"unknown endpoint","supported":["state.read","state.update","context.build","dispatch.create","closeout.check","lease.check","thread.gate","git.integrate","session.analytics","memory.decay","journal.compact","successor.audit"]}'
    exit 3
    ;;
esac
