#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
auto_pause="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --auto-pause) auto_pause="true"; shift ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
state_path="$repo/workspace/state/$task_id/state.json"

if [[ ! -f "$state_path" ]]; then
  json_out '{"error":"state not found"}'
  exit 3
fi

caller=${CALLER_EXPERT:-""}
result=$(CALLER_EXPERT="$caller" python3 - <<'PY' "$state_path"
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

state = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
lease = state.get("lease", {})
now = datetime.now(timezone.utc)
caller_expert = os.environ.get("CALLER_EXPERT", "")

deadline_str = lease.get("deadline_at", "")
started_str = lease.get("started_at", "")
duration_hours = lease.get("run_duration_hours", 0)
status = lease.get("status", "")

exceeded = False
remaining_minutes = -1
elapsed_minutes = -1

if deadline_str:
    try:
        deadline = datetime.fromisoformat(deadline_str.replace("Z", "+00:00"))
        remaining = (deadline - now).total_seconds() / 60
        remaining_minutes = round(remaining, 1)
        exceeded = remaining < 0
    except (ValueError, TypeError):
        pass

if started_str:
    try:
        started = datetime.fromisoformat(started_str.replace("Z", "+00:00"))
        elapsed_minutes = round((now - started).total_seconds() / 60, 1)
    except (ValueError, TypeError):
        pass

if not exceeded and duration_hours and started_str and elapsed_minutes >= 0:
    if elapsed_minutes > duration_hours * 60:
        exceeded = True
        remaining_minutes = round(duration_hours * 60 - elapsed_minutes, 1)

active_expert = state.get("active_expert", "")
lease_conflict = False
lease_conflict_reason = ""
if caller_expert and active_expert and caller_expert != active_expert and status == "running":
    lease_conflict = True
    lease_conflict_reason = f"lease held by {active_expert}, caller is {caller_expert}"

print(json.dumps({
    "task_id": state.get("task_id", ""),
    "lease_status": status,
    "deadline_at": deadline_str,
    "started_at": started_str,
    "duration_hours": duration_hours,
    "elapsed_minutes": elapsed_minutes,
    "remaining_minutes": remaining_minutes,
    "exceeded": exceeded,
    "should_pause": exceeded and status == "running",
    "active_expert": active_expert,
    "lease_conflict": lease_conflict,
    "lease_conflict_reason": lease_conflict_reason,
}, ensure_ascii=False))
PY
)

should_pause=$(RESULT="$result" python3 -c 'import json,os; print("1" if json.loads(os.environ["RESULT"])["should_pause"] else "0")')

if [[ "$should_pause" == "1" && "$auto_pause" == "true" ]]; then
  printf '{"lease_status":"paused","pause_reason":"deadline exceeded (auto-pause by lease-check.sh)"}' \
    | "$SCRIPT_DIR/state-update.sh" --task-id "$task_id" >/dev/null
  result=$(RESULT="$result" python3 - <<'PY'
import json, os
r = json.loads(os.environ["RESULT"])
r["auto_paused"] = True
print(json.dumps(r, ensure_ascii=False))
PY
)
fi

json_out "$result"
