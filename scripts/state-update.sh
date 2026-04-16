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

from team_governance import (
    degraded_ack_analysis,
    default_product_anchors,
    default_quality_anchors,
    default_skeptics,
    normalize_people,
    product_gate_analysis,
    quality_anchor_analysis,
    quality_review_analysis,
    scale_out_analysis,
)

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
    "discussion_policy",
    "decision_id",
    "explorer_queue",
    "explorer_findings",
    "synthesis_path",
    "current_executor",
    "textbook_entry_path",
    "textbook_summary_path",
    "textbook_summary_at",
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
    "product_goal",
    "user_value",
    "non_goals",
    "product_acceptance",
    "drift_risk",
    "product_goal_status",
    "goal_drift_flags",
    "last_product_review_at",
    "quality_review_status",
    "quality_review_findings",
    "quality_review_examples",
    "quality_last_review_at",
    "degraded_ack_by",
    "degraded_ack_at",
    "supervisors",
    "executors",
    "skeptics",
    "product_anchors",
    "quality_anchors",
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

state.setdefault("discussion", {})
if "discussion_policy" in data:
    state["discussion"]["policy"] = data["discussion_policy"]
if "decision_id" in data:
    state["discussion"]["decision_id"] = data["decision_id"]
if "explorer_queue" in data:
    state["discussion"]["explorer_queue"] = data["explorer_queue"]
if "explorer_findings" in data:
    state["discussion"]["explorer_findings"] = data["explorer_findings"]
if "synthesis_path" in data:
    state["discussion"]["synthesis_path"] = data["synthesis_path"]
if "current_executor" in data:
    state["discussion"]["current_executor"] = data["current_executor"]

state.setdefault("textbook", {})
if "textbook_entry_path" in data:
    state["textbook"]["last_entry_path"] = data["textbook_entry_path"]
if "textbook_summary_path" in data:
    state["textbook"]["last_summary_path"] = data["textbook_summary_path"]
if "textbook_summary_at" in data:
    state["textbook"]["last_summary_at"] = data["textbook_summary_at"]

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

state.setdefault("product", {})
if "product_goal" in data:
    state["product"]["goal"] = data["product_goal"]
    lease_goal = state.get("lease", {}).get("goal", "")
    previous_goal = before.get("product", {}).get("goal", "") if isinstance(before.get("product"), dict) else ""
    if "goal" not in data and (not isinstance(lease_goal, str) or not lease_goal.strip() or lease_goal == previous_goal):
        state.setdefault("lease", {})
        state["lease"]["goal"] = data["product_goal"]
if "user_value" in data:
    state["product"]["user_value"] = data["user_value"]
if "non_goals" in data:
    state["product"]["non_goals"] = data["non_goals"]
if "product_acceptance" in data:
    state["product"]["product_acceptance"] = data["product_acceptance"]
if "drift_risk" in data:
    state["product"]["drift_risk"] = data["drift_risk"]
if "product_goal_status" in data:
    state["product"]["goal_status"] = data["product_goal_status"]
if "goal_drift_flags" in data:
    state["product"]["goal_drift_flags"] = data["goal_drift_flags"]
if "last_product_review_at" in data:
    state["product"]["last_product_review_at"] = data["last_product_review_at"]

state.setdefault("quality", {})
if "quality_review_status" in data:
    state["quality"]["review_status"] = data["quality_review_status"]
if "quality_review_findings" in data:
    state["quality"]["review_findings"] = data["quality_review_findings"]
if "quality_review_examples" in data:
    state["quality"]["review_examples"] = data["quality_review_examples"]
if "quality_last_review_at" in data:
    state["quality"]["last_review_at"] = data["quality_last_review_at"]

state.setdefault("team", {})
team = state["team"] if isinstance(state["team"], dict) else {}
state["team"] = team
existing_role_integrity = team.get("role_integrity", {}) if isinstance(team.get("role_integrity"), dict) else {}

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
    product_anchors = normalize_people(team.get("product_anchors", []), "team.product_anchors", require_list=True) if "product_anchors" in team else []
    if not product_anchors:
        product_anchors = default_product_anchors(owner, supervisors)
    quality_anchors = normalize_people(team.get("quality_anchors", []), "team.quality_anchors", require_list=True) if "quality_anchors" in team else []
    if not quality_anchors:
        quality_anchors = default_quality_anchors(owner, supervisors, skeptics, executors)
    high_risk_mode = bool(team.get("high_risk_mode", False))
    integration_pressure = bool(team.get("integration_pressure", False))

    if "supervisors" in data:
        supervisors = normalize_people(data["supervisors"], "supervisors", require_list=True)
    if "executors" in data:
        executors = normalize_people(data["executors"], "executors", require_list=True)
    if "skeptics" in data:
        skeptics = normalize_people(data["skeptics"], "skeptics", require_list=True)
    if "product_anchors" in data:
        product_anchors = normalize_people(data["product_anchors"], "product_anchors", require_list=True)
    if "quality_anchors" in data:
        quality_anchors = normalize_people(data["quality_anchors"], "quality_anchors", require_list=True)
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
    role_integrity = {
        **scale_out["role_integrity"],
        "degraded_ack_by": data.get("degraded_ack_by", existing_role_integrity.get("degraded_ack_by", "")),
        "degraded_ack_at": data.get("degraded_ack_at", existing_role_integrity.get("degraded_ack_at", "")),
    }
except ValueError as exc:
    print(json.dumps({"error": str(exc)}, ensure_ascii=False))
    raise SystemExit(3)

team.update({
    "supervisor_min_count": 1,
    "supervisors": supervisors,
    "executors": executors,
    "skeptics": skeptics,
    "product_anchors": product_anchors,
    "quality_anchors": quality_anchors,
    "anchor_policy": {
        "product_anchor_role": "supervisor",
        "quality_anchor_role": "skeptic",
        "constant_anchor_seats": True,
    },
    "high_risk_mode": high_risk_mode,
    "integration_pressure": integration_pressure,
    "scale_out_recommended": scale_out["scale_out_recommended"],
    "scale_out_triggers": scale_out["scale_out_triggers"],
    "role_integrity": role_integrity,
})

state["product"].setdefault("anchor", product_anchors[0] if product_anchors else owner)
state["product"].setdefault("goal", "")
state["product"].setdefault("user_value", "")
state["product"].setdefault("non_goals", [])
state["product"].setdefault("product_acceptance", [])
state["product"].setdefault("drift_risk", "")
state["product"].setdefault("goal_status", "defined" if state["product"].get("goal") else "missing")
state["product"].setdefault("goal_drift_flags", [])
state["product"].setdefault("last_product_review_at", "")
state["product"]["anchor"] = product_anchors[0] if product_anchors else owner

state["quality"].setdefault("anchor", quality_anchors[0] if quality_anchors else "")
state["quality"].setdefault("review_status", "pending")
state["quality"].setdefault("review_findings", [])
state["quality"].setdefault("review_examples", [])
state["quality"].setdefault("last_review_at", "")
state["quality"]["anchor"] = quality_anchors[0] if quality_anchors else ""

product_gate = product_gate_analysis(state.get("product", {}), product_anchors, team.get("anchor_policy", {}))
quality_anchor = quality_anchor_analysis(state.get("quality", {}), quality_anchors, team.get("anchor_policy", {}))
quality_review = quality_review_analysis(state.get("quality", {}), quality_anchors, team.get("anchor_policy", {}))
degraded_ack = degraded_ack_analysis(role_integrity)

state.setdefault("notes", [])
if data.get("note"):
    state["notes"].append({
        "timestamp": timestamp,
        "text": data["note"],
        "product_gate_ready": product_gate["ready"],
        "quality_anchor_ready": quality_anchor["ready"],
        "quality_review_ready": quality_review["ready"],
        "degraded_ack_ready": degraded_ack["ready"],
    })

state["updated_at"] = timestamp
state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

event = {
    "event_id": f"{task_id}:{timestamp}:state-update",
    "source": "state",
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
