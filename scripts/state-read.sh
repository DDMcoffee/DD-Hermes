#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
payload=$(python3 - <<'PY' "$repo" "$task_id"
import json
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
state_path = repo / "workspace" / "state" / task_id / "state.json"
events_path = repo / "workspace" / "state" / task_id / "events.jsonl"

if not state_path.exists():
    print(json.dumps({"error": "state not found", "task_id": task_id}, ensure_ascii=False))
    raise SystemExit(3)

state = json.loads(state_path.read_text(encoding="utf-8"))
event_count = 0
if events_path.exists():
    event_count = sum(1 for line in events_path.read_text(encoding="utf-8").splitlines() if line.strip())

runtime = state.get("runtime", {})
verification = state.get("verification", {})
team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
supervisors = [item for item in team.get("supervisors", []) if isinstance(item, str) and item.strip()]
executors = [item for item in team.get("executors", []) if isinstance(item, str) and item.strip()]
skeptics = [item for item in team.get("skeptics", []) if isinstance(item, str) and item.strip()]
scale_out_triggers = [item for item in team.get("scale_out_triggers", []) if isinstance(item, str) and item.strip()]
summary = {
    "blocked": bool(state.get("blocked_reason")) or state.get("status") == "blocked",
    "paused": state.get("lease", {}).get("status") == "paused",
    "goal": state.get("lease", {}).get("goal", ""),
    "lease_status": state.get("lease", {}).get("status", ""),
    "deadline_at": state.get("lease", {}).get("deadline_at", ""),
    "resume_after": state.get("lease", {}).get("resume_after", ""),
    "resume_checkpoint": state.get("lease", {}).get("resume_checkpoint", ""),
    "dispatch_cursor": state.get("lease", {}).get("dispatch_cursor", ""),
    "current_focus": state.get("current_focus", ""),
    "active_expert": state.get("active_expert", ""),
    "verification_complete": bool(verification.get("last_pass")) and bool(verification.get("verified_steps")),
    "has_context": bool(runtime.get("last_context_path")) and Path(runtime.get("last_context_path", "")).exists(),
    "has_runtime_report": bool(runtime.get("last_runtime_report_path")) and Path(runtime.get("last_runtime_report_path", "")).exists(),
    "has_supervisor": len(supervisors) >= 1,
    "supervisor_count": len(supervisors),
    "executor_count": len(executors),
    "skeptic_count": len(skeptics),
    "scale_out_recommended": bool(team.get("scale_out_recommended")),
    "scale_out_triggers": scale_out_triggers,
    "event_count": event_count,
}

print(json.dumps({
    "state": state,
    "summary": summary,
}, ensure_ascii=False))
PY
) || status_code=$?

status_code=${status_code:-0}
json_out "$payload"
if [[ "$status_code" -ne 0 ]]; then
  exit "$status_code"
fi
