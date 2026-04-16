#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
worktree=""
agent_role="commander"
memory_limit="8"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --worktree) worktree="$2"; shift 2 ;;
    --agent-role) agent_role="$2"; shift 2 ;;
    --memory-limit) memory_limit="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
contract_path="$repo/workspace/contracts/$task_id.md"
if [[ ! -f "$contract_path" ]]; then
  json_out '{"error":"missing sprint contract","blocked":true}'
  exit 2
fi

worktree=${worktree:-$(repo_root)}
if [[ ! -f "$repo/workspace/state/$task_id/state.json" ]]; then
  "$SCRIPT_DIR/state-init.sh" --task-id "$task_id" >/dev/null
fi

runtime_json=$("$SCRIPT_DIR/runtime-report.sh" --task-id "$task_id" --worktree "$worktree" --agent-role "$agent_role")
state_json=$("$SCRIPT_DIR/state-read.sh" --task-id "$task_id")

payload=$(RUNTIME_JSON="$runtime_json" STATE_JSON="$state_json" python3 - <<'PY' "$repo" "$task_id" "$agent_role" "$memory_limit" "$SCRIPT_DIR"
import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
agent_role = sys.argv[3]
memory_limit = sys.argv[4]
script_dir = Path(sys.argv[5]).resolve()
sys.path.insert(0, str(script_dir))
runtime = json.loads(os.environ["RUNTIME_JSON"])
state_wrapper = json.loads(os.environ["STATE_JSON"])
state = state_wrapper["state"]
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state_dir = repo / "workspace" / "state" / task_id
state_path = state_dir / "state.json"
events_path = state_dir / "events.jsonl"
runtime_path = state_dir / "runtime.json"
context_path = state_dir / "context.json"

from team_governance import (
    degraded_ack_analysis,
    merge_triggers,
    product_gate_analysis,
    quality_anchor_analysis,
    quality_review_analysis,
    scale_out_analysis,
)


def read_doc(path: Path):
    if not path or not path.exists():
        return None
    return {"path": str(path), "text": path.read_text(encoding="utf-8")}


contract = read_doc(repo / "workspace" / "contracts" / f"{task_id}.md")
handoffs = [read_doc(path) for path in sorted((repo / "workspace" / "handoffs").glob(f"{task_id}-*.md"))]
handoffs = [item for item in handoffs if item]
exploration = [read_doc(path) for path in sorted((repo / "workspace" / "exploration").glob(f"*{task_id}*.md"))]
exploration = [item for item in exploration if item]
openspec = {
    "proposal": read_doc(repo / "openspec" / "proposals" / f"{task_id}.md"),
    "design": read_doc(repo / "openspec" / "designs" / f"{task_id}.md"),
    "task": read_doc(repo / "openspec" / "tasks" / f"{task_id}.md"),
    "archive": read_doc(repo / "openspec" / "archive" / f"{task_id}.md"),
}

seed_parts = [task_id]
for doc in [contract, *handoffs, *exploration, *[item for item in openspec.values() if item]]:
    seed_parts.append(doc["text"])
seed = "\n".join(seed_parts)[:12000]

memory_proc = subprocess.run(
    [
        str(repo / "scripts" / "memory-read.sh"),
        "--task-context",
        seed,
        "--kind",
        "all",
        "--limit",
        memory_limit,
    ],
    capture_output=True,
    text=True,
    check=True,
)
memory = json.loads(memory_proc.stdout)
selected_ids = [item.get("memory_id") for item in memory.get("matches", []) if item.get("memory_id")]

runtime_path.write_text(json.dumps(runtime, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
packet = {
    "task_id": task_id,
    "agent_role": agent_role,
    "generated_at": timestamp,
    "sources": {
        "contract_path": contract["path"] if contract else "",
        "handoff_paths": [item["path"] for item in handoffs],
        "exploration_paths": [item["path"] for item in exploration],
        "state_path": str(state_path),
        "runtime_path": str(runtime_path),
        "openspec": {name: item["path"] if item else "" for name, item in openspec.items()},
    },
    "runtime": runtime,
    "state": state,
    "memory": memory,
    "discussion": state.get("discussion", {}),
    "product": state.get("product", {}),
    "quality": state.get("quality", {}),
    "continuation": {
        "goal": state.get("product", {}).get("goal", "") or state.get("lease", {}).get("goal", ""),
        "lease": state.get("lease", {}),
        "current_focus": state.get("current_focus", ""),
        "active_expert": state.get("active_expert", ""),
        "blocked_reason": state.get("blocked_reason", ""),
        "current_executor": state.get("discussion", {}).get("current_executor", ""),
    },
    "documents": {
        "contract": contract,
        "handoffs": handoffs,
        "exploration": exploration,
        "openspec": openspec,
    },
    "context_summary": {
        "memory_ids": selected_ids,
        "handoff_count": len(handoffs),
        "exploration_count": len(exploration),
        "has_design": bool(openspec["design"]),
        "has_task": bool(openspec["task"]),
        "lease_status": state.get("lease", {}).get("status", ""),
        "resume_checkpoint": state.get("lease", {}).get("resume_checkpoint", ""),
        "discussion_policy": state.get("discussion", {}).get("policy", ""),
        "decision_id": state.get("discussion", {}).get("decision_id", ""),
        "runtime_generated_at": timestamp,
        "runtime_stale_warning": "",
        "supervisor_count": len(state.get("team", {}).get("supervisors", [])) if isinstance(state.get("team"), dict) else 0,
        "product_anchor_count": len(state.get("team", {}).get("product_anchors", [])) if isinstance(state.get("team"), dict) else 0,
        "quality_anchor_count": len(state.get("team", {}).get("quality_anchors", [])) if isinstance(state.get("team"), dict) else 0,
        "product_anchor_name": state.get("product", {}).get("anchor", ""),
        "product_anchor_role": state.get("team", {}).get("anchor_policy", {}).get("product_anchor_role", "") if isinstance(state.get("team"), dict) else "",
        "quality_anchor_name": state.get("quality", {}).get("anchor", ""),
        "quality_anchor_role": state.get("team", {}).get("anchor_policy", {}).get("quality_anchor_role", "") if isinstance(state.get("team"), dict) else "",
        "product_goal": state.get("product", {}).get("goal", ""),
        "product_goal_status": state.get("product", {}).get("goal_status", ""),
        "goal_drift_flags": state.get("product", {}).get("goal_drift_flags", []),
        "quality_review_status": state.get("quality", {}).get("review_status", ""),
        "independent_skeptic": False,
        "role_integrity_degraded": False,
        "role_conflicts": [],
        "scale_out_recommended": False,
        "scale_out_triggers": [],
    },
}

team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
role_analysis = scale_out_analysis(
    owner=state.get("owner", "lead"),
    supervisors=team.get("supervisors", []),
    executors=team.get("executors", []),
    skeptics=team.get("skeptics", []),
    high_risk_mode=bool(team.get("high_risk_mode", False)),
    integration_pressure=bool(team.get("integration_pressure", False)),
)
role_integrity = dict(role_analysis["role_integrity"])
stored_role_integrity = team.get("role_integrity", {}) if isinstance(team.get("role_integrity"), dict) else {}
role_integrity["degraded_ack_by"] = stored_role_integrity.get("degraded_ack_by", "")
role_integrity["degraded_ack_at"] = stored_role_integrity.get("degraded_ack_at", "")
product_anchors = team.get("product_anchors", []) if isinstance(team.get("product_anchors"), list) else []
quality_anchors = team.get("quality_anchors", []) if isinstance(team.get("quality_anchors"), list) else []
product_gate = product_gate_analysis(state.get("product", {}), product_anchors, team.get("anchor_policy", {}))
quality_anchor = quality_anchor_analysis(state.get("quality", {}), quality_anchors, team.get("anchor_policy", {}))
quality_review = quality_review_analysis(state.get("quality", {}), quality_anchors, team.get("anchor_policy", {}))
degraded_ack = degraded_ack_analysis(role_integrity)
packet["context_summary"]["independent_skeptic"] = role_integrity["independent_skeptic"]
packet["context_summary"]["role_integrity_degraded"] = role_integrity["degraded"]
packet["context_summary"]["degraded_ack_required"] = degraded_ack["required"]
packet["context_summary"]["degraded_ack_ready"] = degraded_ack["ready"]
packet["context_summary"]["degraded_ack_by"] = degraded_ack["ack_by"]
packet["context_summary"]["degraded_ack_at"] = degraded_ack["ack_at"]
packet["context_summary"]["role_conflicts"] = role_integrity["role_conflicts"]
packet["context_summary"]["scale_out_triggers"] = merge_triggers(team.get("scale_out_triggers", []), role_analysis["scale_out_triggers"])
packet["context_summary"]["scale_out_recommended"] = bool(team.get("scale_out_recommended", False)) or bool(packet["context_summary"]["scale_out_triggers"])
packet["context_summary"]["product_user_value"] = state.get("product", {}).get("user_value", "")
packet["context_summary"]["product_non_goals"] = state.get("product", {}).get("non_goals", [])
packet["context_summary"]["product_acceptance"] = state.get("product", {}).get("product_acceptance", [])
packet["context_summary"]["product_drift_risk"] = state.get("product", {}).get("drift_risk", "")
packet["context_summary"]["product_gate_ready"] = product_gate["ready"]
packet["context_summary"]["product_gate_reasons"] = product_gate["reasons"]
packet["context_summary"]["quality_anchor_ready"] = quality_anchor["ready"]
packet["context_summary"]["quality_anchor_reasons"] = quality_anchor["reasons"]
packet["context_summary"]["quality_review_ready"] = quality_review["ready"]
packet["context_summary"]["quality_review_reasons"] = quality_review["reasons"]
packet["context_summary"]["quality_review_findings"] = state.get("quality", {}).get("review_findings", [])
packet["context_summary"]["quality_review_examples"] = state.get("quality", {}).get("review_examples", [])
packet["context_summary"]["anchor_policy"] = team.get("anchor_policy", {})

if runtime_path.exists():
    try:
        prev_runtime = json.loads(runtime_path.read_text(encoding="utf-8"))
        prev_ts = prev_runtime.get("generated_at", "")
        if prev_ts:
            prev_dt = datetime.fromisoformat(prev_ts.replace("Z", "+00:00"))
            now_dt = datetime.now(timezone.utc)
            age_minutes = (now_dt - prev_dt).total_seconds() / 60
            if age_minutes > 60:
                packet["context_summary"]["runtime_stale_warning"] = f"previous runtime snapshot is {int(age_minutes)} minutes old"
    except (json.JSONDecodeError, ValueError, KeyError):
        pass

context_path.write_text(json.dumps(packet, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

state.setdefault("runtime", {})
state["runtime"]["last_context_path"] = str(context_path)
state["runtime"]["last_runtime_report_path"] = str(runtime_path)
state.setdefault("memory", {})
state["memory"]["last_selected_ids"] = selected_ids
state["updated_at"] = timestamp
state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

event = {
    "event_id": f"{task_id}:{timestamp}:context-build",
    "source": "state",
    "task_id": task_id,
    "op": "context_build",
    "timestamp": timestamp,
    "context_path": str(context_path),
    "runtime_path": str(runtime_path),
    "memory_ids": selected_ids,
    "actor": "context-build",
}
with events_path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps(event, ensure_ascii=False) + "\n")

print(json.dumps({
    "context_path": str(context_path),
    "runtime_path": str(runtime_path),
    "state_path": str(state_path),
    "memory_count": len(memory.get("matches", [])),
    "handoff_count": len(handoffs),
    "exploration_count": len(exploration),
}, ensure_ascii=False))
PY
)
json_out "$payload"
