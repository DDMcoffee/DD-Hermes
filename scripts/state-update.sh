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

input_json=$(read_stdin_json)
repo=$(shared_repo_root)
payload=$(INPUT_JSON="$input_json" python3 - <<'PY' "$repo" "$task_id" "$SCRIPT_DIR"
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
script_dir = Path(sys.argv[3]).resolve()
sys.path.insert(0, str(script_dir))
state_path = repo / "workspace" / "state" / task_id / "state.json"
events_path = repo / "workspace" / "state" / task_id / "events.jsonl"

from team_governance import default_skeptics, normalize_people, scale_out_analysis

if not state_path.exists():
    print(json.dumps({"error": "state not found", "task_id": task_id}, ensure_ascii=False))
    raise SystemExit(3)

data = json.loads(os.environ["INPUT_JSON"])
allowed = {
    "status",
    "mode",
    "current_focus",
    "blocked_reason",
    "active_expert",
    "goal",
    "lease_status",
    "run_duration_hours",
    "lease_started_at",
    "lease_deadline_at",
    "paused_at",
    "pause_reason",
    "resume_after",
    "resume_checkpoint",
    "dispatch_cursor",
    "commit_sha",
    "commit_branch",
    "commit_upstream",
    "commit_remote_urls",
    "openspec_stage",
    "proposal_path",
    "design_path",
    "task_path",
    "archive_path",
    "worktree_path",
    "context_path",
    "runtime_report_path",
    "append_verified_steps",
    "append_verified_files",
    "last_pass",
    "memory_reads",
    "memory_writes",
    "last_selected_memory_ids",
    "supervisors",
    "executors",
    "skeptics",
    "high_risk_mode",
    "integration_pressure",
    "note",
}
unknown = sorted(set(data) - allowed)
if unknown:
    print(json.dumps({"error": "unknown state update keys", "unknown": unknown}, ensure_ascii=False))
    raise SystemExit(3)

timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state = json.loads(state_path.read_text(encoding="utf-8"))
before = json.loads(json.dumps(state, ensure_ascii=False))

def load_verification_history(path: Path):
    if not path.exists():
        return []
    history = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        if event.get("op") != "state_update":
            continue
        changes = event.get("changes", {})
        if isinstance(changes, dict) and "last_pass" in changes:
            history.append(bool(changes["last_pass"]))
    return history

for key in ("status", "mode", "current_focus", "blocked_reason", "active_expert"):
    if key in data:
        state[key] = data[key]

state.setdefault("openspec", {})
if "openspec_stage" in data:
    state["openspec"]["stage"] = data["openspec_stage"]
for key in ("proposal_path", "design_path", "task_path", "archive_path"):
    if key in data:
        state["openspec"][key] = data[key]

state.setdefault("runtime", {})
if "worktree_path" in data:
    state["runtime"]["last_worktree_path"] = data["worktree_path"]
if "context_path" in data:
    state["runtime"]["last_context_path"] = data["context_path"]
if "runtime_report_path" in data:
    state["runtime"]["last_runtime_report_path"] = data["runtime_report_path"]

state.setdefault("lease", {})
if "goal" in data:
    state["lease"]["goal"] = data["goal"]
if "lease_status" in data:
    state["lease"]["status"] = data["lease_status"]
if "run_duration_hours" in data:
    state["lease"]["duration_hours"] = data["run_duration_hours"]
if "lease_started_at" in data:
    state["lease"]["started_at"] = data["lease_started_at"]
if "lease_deadline_at" in data:
    state["lease"]["deadline_at"] = data["lease_deadline_at"]
if "paused_at" in data:
    state["lease"]["paused_at"] = data["paused_at"]
if "pause_reason" in data:
    state["lease"]["pause_reason"] = data["pause_reason"]
if "resume_after" in data:
    state["lease"]["resume_after"] = data["resume_after"]
if "resume_checkpoint" in data:
    state["lease"]["resume_checkpoint"] = data["resume_checkpoint"]
if "dispatch_cursor" in data:
    state["lease"]["dispatch_cursor"] = data["dispatch_cursor"]

state.setdefault("git", {})
if "commit_sha" in data:
    state["git"]["latest_commit"] = data["commit_sha"]
    state["git"].setdefault("baseline_commit", data["commit_sha"])
if "commit_branch" in data:
    state["git"]["latest_branch"] = data["commit_branch"]
if "commit_upstream" in data:
    state["git"]["latest_upstream"] = data["commit_upstream"]
if "commit_remote_urls" in data:
    state["git"]["latest_remote_urls"] = data["commit_remote_urls"]

state.setdefault("verification", {})
for key in ("verified_steps", "verified_files"):
    state["verification"].setdefault(key, [])
if "append_verified_steps" in data:
    for item in data["append_verified_steps"]:
        if item not in state["verification"]["verified_steps"]:
            state["verification"]["verified_steps"].append(item)
if "append_verified_files" in data:
    for item in data["append_verified_files"]:
        if item not in state["verification"]["verified_files"]:
            state["verification"]["verified_files"].append(item)
if "last_pass" in data:
    state["verification"]["last_pass"] = bool(data["last_pass"])
    state["verification"]["last_run_at"] = timestamp

state.setdefault("memory", {})
if "memory_reads" in data:
    state["memory"]["reads"] = data["memory_reads"]
if "memory_writes" in data:
    state["memory"]["writes"] = data["memory_writes"]
state["memory"].setdefault("last_selected_ids", [])
if "last_selected_memory_ids" in data:
    state["memory"]["last_selected_ids"] = data["last_selected_memory_ids"]

state.setdefault("team", {})
team = state["team"] if isinstance(state["team"], dict) else {}
state["team"] = team

try:
    owner = state.get("owner", "lead") or "lead"
    supervisors = normalize_people(team.get("supervisors", []), "team.supervisors", require_list=True) if "supervisors" in team else []
    if not supervisors:
        supervisors = [owner]
    executors = normalize_people(team.get("executors", []), "team.executors", require_list=True) if "executors" in team else []
    if not executors:
        executors = normalize_people(state.get("experts", []), "state.experts", require_list=True)
    skeptics = normalize_people(team.get("skeptics", []), "team.skeptics", require_list=True) if "skeptics" in team else []
    if not skeptics:
        skeptics = default_skeptics(owner, supervisors, executors)
    high_risk_mode = bool(team.get("high_risk_mode", False))
    integration_pressure = bool(team.get("integration_pressure", False))

    if "supervisors" in data:
        supervisors = normalize_people(data["supervisors"], "supervisors", require_list=True)
    if "executors" in data:
        executors = normalize_people(data["executors"], "executors", require_list=True)
    if "skeptics" in data:
        skeptics = normalize_people(data["skeptics"], "skeptics", require_list=True)
    if "high_risk_mode" in data:
        high_risk_mode = bool(data["high_risk_mode"])
    if "integration_pressure" in data:
        integration_pressure = bool(data["integration_pressure"])
    if not supervisors:
        raise ValueError("at least one supervisor is required")

    verification_history = load_verification_history(events_path)
    if "last_pass" in data:
        verification_history.append(bool(data["last_pass"]))
    scale_out = scale_out_analysis(
        owner=owner,
        supervisors=supervisors,
        executors=executors,
        skeptics=skeptics,
        high_risk_mode=high_risk_mode,
        integration_pressure=integration_pressure,
        verification_history=verification_history,
    )
except ValueError as exc:
    print(json.dumps({"error": str(exc)}, ensure_ascii=False))
    raise SystemExit(3)

team.update({
    "supervisor_min_count": 1,
    "supervisors": supervisors,
    "executors": executors,
    "skeptics": skeptics,
    "high_risk_mode": high_risk_mode,
    "integration_pressure": integration_pressure,
    "scale_out_recommended": scale_out["scale_out_recommended"],
    "scale_out_triggers": scale_out["scale_out_triggers"],
    "role_integrity": scale_out["role_integrity"],
})

state.setdefault("notes", [])
if data.get("note"):
    state["notes"].append({"timestamp": timestamp, "text": data["note"]})

state["updated_at"] = timestamp
state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

event = {
    "event_id": f"{task_id}:{timestamp}:state-update",
    "task_id": task_id,
    "op": "state_update",
    "timestamp": timestamp,
    "changes": data,
    "before_status": before.get("status"),
    "after_status": state.get("status"),
    "actor": "state-update",
}
with events_path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps(event, ensure_ascii=False) + "\n")

print(json.dumps({
    "state_path": str(state_path),
    "events_path": str(events_path),
    "updated": sorted(data.keys()),
    "status": state.get("status"),
    "mode": state.get("mode"),
}, ensure_ascii=False))
PY
) || status_code=$?

status_code=${status_code:-0}
json_out "$payload"
if [[ "$status_code" -ne 0 ]]; then
  exit "$status_code"
fi
