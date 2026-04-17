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
payload=$(python3 - <<'PY' "$repo" "$task_id" "$SCRIPT_DIR"
import json
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
script_dir = Path(sys.argv[3]).resolve()
sys.path.insert(0, str(script_dir))
state_path = repo / "workspace" / "state" / task_id / "state.json"
events_path = repo / "workspace" / "state" / task_id / "events.jsonl"

from team_governance import (
    governance_snapshot,
)
from artifact_semantics import closeout_verdict

if not state_path.exists():
    print(json.dumps({"error": "state not found", "task_id": task_id}, ensure_ascii=False))
    raise SystemExit(3)

state = json.loads(state_path.read_text(encoding="utf-8"))
event_count = 0
if events_path.exists():
    event_count = sum(1 for line in events_path.read_text(encoding="utf-8").splitlines() if line.strip())

runtime = state.get("runtime", {})
verification = state.get("verification", {})
discussion = state.get("discussion", {})
team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
governance = governance_snapshot(state)
supervisors = governance["supervisors"]
executors = governance["executors"]
skeptics = governance["skeptics"]
product_anchors = governance["product_anchors"]
quality_anchors = governance["quality_anchors"]
scale_out_triggers = governance["scale_out_triggers"]
role_integrity = governance["role_integrity"]
product_gate = governance["product_gate"]
quality_anchor = governance["quality_anchor"]
quality_review = governance["quality_review"]
degraded_ack = governance["degraded_ack"]
task_policy = governance["task_policy"]
quality_seat = governance["quality_seat"]
verdicts = governance["verdicts"]
stored_verdicts = state.get("verdicts", {}) if isinstance(state.get("verdicts"), dict) else {}
execution_closeout = stored_verdicts.get("execution_closeout") if isinstance(stored_verdicts.get("execution_closeout"), dict) else None
if execution_closeout is None:
    execution_closeout = closeout_verdict(
        repo,
        task_id,
        state=state,
        updated_at=state.get("updated_at", ""),
    )
verdicts["execution_closeout"] = execution_closeout
summary = {
    "blocked": bool(state.get("blocked_reason")) or state.get("status") == "blocked",
    "paused": state.get("lease", {}).get("status") == "paused",
    "goal": state.get("product", {}).get("goal", "") or state.get("lease", {}).get("goal", ""),
    "lease_goal": state.get("lease", {}).get("goal", ""),
    "lease_status": state.get("lease", {}).get("status", ""),
    "deadline_at": state.get("lease", {}).get("deadline_at", ""),
    "resume_after": state.get("lease", {}).get("resume_after", ""),
    "resume_checkpoint": state.get("lease", {}).get("resume_checkpoint", ""),
    "dispatch_cursor": state.get("lease", {}).get("dispatch_cursor", ""),
    "current_focus": state.get("current_focus", ""),
    "active_expert": state.get("active_expert", ""),
    "discussion_policy": discussion.get("policy", ""),
    "decision_id": discussion.get("decision_id", ""),
    "current_executor": discussion.get("current_executor", ""),
    "verification_complete": bool(verification.get("last_pass")) and bool(verification.get("verified_steps")),
    "has_context": bool(runtime.get("last_context_path")) and Path(runtime.get("last_context_path", "")).exists(),
    "has_runtime_report": bool(runtime.get("last_runtime_report_path")) and Path(runtime.get("last_runtime_report_path", "")).exists(),
    "has_supervisor": len(supervisors) >= 1,
    "supervisor_count": len(supervisors),
    "executor_count": len(executors),
    "skeptic_count": len(skeptics),
    "product_anchor_count": len(product_anchors),
    "quality_anchor_count": len(quality_anchors),
    "product_anchor_name": state.get("product", {}).get("anchor", ""),
    "product_anchor_role": team.get("anchor_policy", {}).get("product_anchor_role", ""),
    "quality_anchor_name": state.get("quality", {}).get("anchor", ""),
    "quality_anchor_role": team.get("anchor_policy", {}).get("quality_anchor_role", ""),
    "product_goal_ready": bool(state.get("product", {}).get("goal", "")),
    "product_user_value": state.get("product", {}).get("user_value", ""),
    "product_non_goals": state.get("product", {}).get("non_goals", []),
    "product_acceptance": state.get("product", {}).get("product_acceptance", []),
    "task_class": task_policy["task_class"],
    "task_class_bucket": task_policy["bucket"],
    "task_class_rationale": state.get("product", {}).get("task_class_rationale", "") or task_policy["rationale"],
    "quality_requirement": task_policy["quality_requirement"],
    "quality_requirement_source": task_policy["quality_requirement_source"],
    "quality_requirement_ready": task_policy["ready"],
    "quality_requirement_reasons": task_policy["reasons"],
    "task_policy_status": verdicts["task_policy"]["status"],
    "manual_escalation_required": task_policy["manual_escalation_required"],
    "manual_escalation_reasons": task_policy["manual_escalation_reasons"],
    "product_user_value_ready": bool(state.get("product", {}).get("user_value", "")),
    "product_non_goal_count": len(state.get("product", {}).get("non_goals", [])),
    "product_acceptance_count": len(state.get("product", {}).get("product_acceptance", [])),
    "product_goal_status": state.get("product", {}).get("goal_status", ""),
    "goal_drift_flags": state.get("product", {}).get("goal_drift_flags", []),
    "product_review_recorded": bool(state.get("product", {}).get("last_product_review_at", "")),
    "product_gate_ready": product_gate["ready"],
    "product_gate_reasons": product_gate["reasons"],
    "product_gate_status": verdicts["product_gate"]["status"],
    "quality_review_status": state.get("quality", {}).get("review_status", ""),
    "quality_anchor_ready": quality_anchor["ready"],
    "quality_anchor_reasons": quality_anchor["reasons"],
    "quality_anchor_status": verdicts["quality_anchor"]["status"],
    "quality_review_recorded": bool(state.get("quality", {}).get("last_review_at", "")),
    "quality_review_ready": quality_review["ready"],
    "quality_review_reasons": quality_review["reasons"],
    "quality_review_gate_status": verdicts["quality_review"]["status"],
    "quality_seat_mode": quality_seat["mode"],
    "quality_seat_ready": quality_seat["execution_ready"],
    "quality_seat_status": quality_seat["execution_status"],
    "quality_seat_reasons": quality_seat["execution_reasons"],
    "quality_seat_completion_ready": quality_seat["completion_ready"],
    "quality_seat_completion_status": quality_seat["completion_status"],
    "quality_seat_completion_reasons": quality_seat["completion_reasons"],
    "execution_closeout_ready": execution_closeout["ready"],
    "execution_closeout_status": execution_closeout["status"],
    "execution_closeout_reasons": execution_closeout["reasons"],
    "execution_closeout_path": execution_closeout["closeout_path"],
    "execution_closeout_selected_by": execution_closeout["selected_by"],
    "execution_closeout_candidate_count": execution_closeout["candidate_count"],
    "execution_closeout_semantic_valid": execution_closeout["semantic_valid"],
    "ready_for_execution_slice_done": execution_closeout["ready_for_execution_slice_done"],
    "anchor_policy_constant_seats": bool(team.get("anchor_policy", {}).get("constant_anchor_seats", False)),
    "independent_skeptic": role_integrity["independent_skeptic"],
    "role_integrity_degraded": role_integrity["degraded"],
    "degraded_ack_required": degraded_ack["required"],
    "degraded_ack_ready": degraded_ack["ready"],
    "degraded_ack_status": verdicts["degraded_ack"]["status"],
    "degraded_ack_by": degraded_ack["ack_by"],
    "degraded_ack_at": degraded_ack["ack_at"],
    "role_conflicts": role_integrity["role_conflicts"],
    "scale_out_recommended": governance["scale_out_recommended"],
    "scale_out_triggers": scale_out_triggers,
    "verdicts_updated_at": verdicts["updated_at"],
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
