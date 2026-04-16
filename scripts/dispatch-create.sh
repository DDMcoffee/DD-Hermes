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
contract_path="$repo/workspace/contracts/$task_id.md"
if [[ ! -f "$contract_path" ]]; then
  json_out '{"error":"missing sprint contract","blocked":true}'
  exit 2
fi

if [[ ! -f "$repo/workspace/state/$task_id/state.json" ]]; then
  "$SCRIPT_DIR/state-init.sh" --task-id "$task_id" >/dev/null
fi

state_json=$("$SCRIPT_DIR/state-read.sh" --task-id "$task_id")
context_json=$("$SCRIPT_DIR/context-build.sh" --task-id "$task_id" --agent-role commander)

payload=$(STATE_JSON="$state_json" CONTEXT_JSON="$context_json" python3 - <<'PY' "$repo" "$task_id" "$SCRIPT_DIR"
import json
import os
import shlex
import subprocess
import sys
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
script_dir = Path(sys.argv[3]).resolve()
sys.path.insert(0, str(script_dir))
state_wrapper = json.loads(os.environ["STATE_JSON"])
context_wrapper = json.loads(os.environ["CONTEXT_JSON"])
state = state_wrapper["state"]
context_path = context_wrapper["context_path"]
runtime_path = context_wrapper["runtime_path"]
state_path = context_wrapper["state_path"]

from team_governance import (
    degraded_ack_analysis,
    merge_triggers,
    normalize_people,
    product_gate_analysis,
    task_class_analysis,
    quality_anchor_analysis,
    quality_seat_analysis,
    scale_out_analysis,
)


def handoff_for(agent_id):
    for path in state.get("handoff_paths", []):
        if Path(path).name.endswith(f"-to-{agent_id}.md"):
            return path
    return ""


def run_json(cmd):
    proc = subprocess.run(
        cmd,
        cwd=str(repo),
        capture_output=True,
        text=True,
        check=True,
    )
    return json.loads(proc.stdout)


team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
supervisors = normalize_people(team.get("supervisors", []))
executors = normalize_people(team.get("executors", []))
skeptics = normalize_people(team.get("skeptics", []))
product_anchors = normalize_people(team.get("product_anchors", []))
quality_anchors = normalize_people(team.get("quality_anchors", []))
product = state.get("product", {}) if isinstance(state.get("product"), dict) else {}
quality = state.get("quality", {}) if isinstance(state.get("quality"), dict) else {}
task_policy = task_class_analysis(product)
role_analysis = scale_out_analysis(
    owner=state.get("owner", "lead"),
    supervisors=supervisors,
    executors=executors,
    skeptics=skeptics,
    high_risk_mode=bool(team.get("high_risk_mode", False)),
    integration_pressure=bool(team.get("integration_pressure", False)),
)
scale_out_triggers = merge_triggers(team.get("scale_out_triggers", []), role_analysis["scale_out_triggers"])
stored_role_integrity = team.get("role_integrity", {}) if isinstance(team.get("role_integrity"), dict) else {}
role_integrity = {
    **role_analysis["role_integrity"],
    "degraded_ack_by": stored_role_integrity.get("degraded_ack_by", ""),
    "degraded_ack_at": stored_role_integrity.get("degraded_ack_at", ""),
}
product_gate = product_gate_analysis(product, product_anchors, team.get("anchor_policy", {}))
quality_anchor = quality_anchor_analysis(quality, quality_anchors, team.get("anchor_policy", {}))
degraded_ack = degraded_ack_analysis(role_integrity)
quality_seat = quality_seat_analysis(role_integrity, quality_anchor, degraded_ack, None, task_policy)

if not supervisors:
    print(json.dumps({"error": "dispatch requires at least one supervisor", "blocked": True}, ensure_ascii=False))
    raise SystemExit(2)
if not executors:
    print(json.dumps({"error": "dispatch requires at least one executor", "blocked": True}, ensure_ascii=False))
    raise SystemExit(2)
if not skeptics:
    print(json.dumps({"error": "dispatch requires at least one skeptic", "blocked": True}, ensure_ascii=False))
    raise SystemExit(2)
if not product_gate["ready"]:
    print(json.dumps({
        "error": f"dispatch blocked by product gate: {', '.join(product_gate['reasons'])}",
        "blocked": True,
        "product_gate_reasons": product_gate["reasons"],
    }, ensure_ascii=False))
    raise SystemExit(2)
if not task_policy["ready"]:
    print(json.dumps({
        "error": f"dispatch blocked by task classification: {', '.join(task_policy['reasons'])}",
        "blocked": True,
        "task_class": task_policy["task_class"],
        "quality_requirement": task_policy["quality_requirement"],
        "task_policy_reasons": task_policy["reasons"],
    }, ensure_ascii=False))
    raise SystemExit(2)
if product.get("goal_status") in {"drifted", "blocked"}:
    print(json.dumps({"error": f"dispatch blocked by product.goal_status={product.get('goal_status')}", "blocked": True}, ensure_ascii=False))
    raise SystemExit(2)
if not quality_anchor["ready"]:
    print(json.dumps({
        "error": f"dispatch blocked by quality anchor: {', '.join(quality_anchor['reasons'])}",
        "blocked": True,
        "quality_anchor_reasons": quality_anchor["reasons"],
        "quality_seat_mode": quality_seat["mode"],
        "quality_seat_status": quality_seat["execution_status"],
        "quality_seat_reasons": quality_seat["execution_reasons"],
    }, ensure_ascii=False))
    raise SystemExit(2)
if not degraded_ack["ready"]:
    print(json.dumps({
        "error": f"dispatch blocked by degraded supervision: {', '.join(degraded_ack['reasons'])}",
        "blocked": True,
        "degraded_ack_reasons": degraded_ack["reasons"],
        "quality_seat_mode": quality_seat["mode"],
        "quality_seat_status": quality_seat["execution_status"],
        "quality_seat_reasons": quality_seat["execution_reasons"],
    }, ensure_ascii=False))
    raise SystemExit(2)
if not quality_seat["execution_ready"]:
    print(json.dumps({
        "error": f"dispatch blocked by quality seat policy: {', '.join(quality_seat['execution_reasons'])}",
        "blocked": True,
        "task_class": task_policy["task_class"],
        "quality_requirement": task_policy["quality_requirement"],
        "task_policy_reasons": task_policy["reasons"],
        "quality_seat_mode": quality_seat["mode"],
        "quality_seat_status": quality_seat["execution_status"],
        "quality_seat_reasons": quality_seat["execution_reasons"],
    }, ensure_ascii=False))
    raise SystemExit(2)

assignments = []
created_worktrees = []
existing_worktrees = []

for agent_id in supervisors:
    assignments.append({
        "agent_id": agent_id,
        "role": "supervisor",
        "anchor_role": "product_anchor" if agent_id in product_anchors else "",
        "status": "ready",
        "worktree_required": False,
        "worktree_path": "",
        "branch": "",
        "handoff_path": "",
        "artifacts": {
            "contract_path": state.get("contract_path", ""),
            "state_path": state_path,
            "context_path": context_path,
            "runtime_path": runtime_path,
        },
        "next_commands": [
            f"cd {shlex.quote(str(repo))}",
            f"./scripts/state-read.sh --task-id {task_id}",
            f"./scripts/context-build.sh --task-id {task_id} --agent-role supervisor",
        ],
    })

for agent_id in executors:
    expected_worktree = repo / ".worktrees" / f"{task_id}-{agent_id}"
    branch = f"{task_id}-{agent_id}"
    status = "existing"
    if expected_worktree.exists():
        existing_worktrees.append(str(expected_worktree))
    else:
        created = run_json([str(script_dir / "worktree-create.sh"), "--task-id", task_id, "--expert", agent_id])
        expected_worktree = Path(created["worktree_path"]).resolve()
        branch = created["branch"]
        status = "created"
        created_worktrees.append(str(expected_worktree))
    assignments.append({
        "agent_id": agent_id,
        "role": "executor",
        "anchor_role": "",
        "status": status,
        "worktree_required": True,
        "worktree_path": str(expected_worktree),
        "branch": branch,
        "handoff_path": handoff_for(agent_id),
        "artifacts": {
            "contract_path": state.get("contract_path", ""),
            "state_path": state_path,
            "context_path": context_path,
            "runtime_path": runtime_path,
        },
        "next_commands": [
            f"cd {shlex.quote(str(expected_worktree))}",
            "git status --short",
            f"./scripts/context-build.sh --task-id {task_id} --agent-role executor --worktree {shlex.quote(str(expected_worktree))}",
        ],
    })

for agent_id in skeptics:
    assignments.append({
        "agent_id": agent_id,
        "role": "skeptic",
        "anchor_role": "quality_anchor" if agent_id in quality_anchors else "",
        "status": "ready",
        "worktree_required": False,
        "worktree_path": "",
        "branch": "",
        "handoff_path": "",
        "artifacts": {
            "contract_path": state.get("contract_path", ""),
            "state_path": state_path,
            "context_path": context_path,
            "runtime_path": runtime_path,
        },
        "next_commands": [
            f"cd {shlex.quote(str(repo))}",
            f"./scripts/context-build.sh --task-id {task_id} --agent-role skeptic",
            f"./scripts/state-read.sh --task-id {task_id}",
        ],
    })

print(json.dumps({
    "task_id": task_id,
    "contract_path": state.get("contract_path", ""),
    "state_path": state_path,
    "context_path": context_path,
    "runtime_path": runtime_path,
    "anchors": {
        "product_anchors": product_anchors,
        "quality_anchors": quality_anchors,
        "product_goal": product.get("goal", ""),
        "product_goal_status": product.get("goal_status", ""),
        "task_class": task_policy["task_class"],
        "task_class_bucket": task_policy["bucket"],
        "task_class_rationale": product.get("task_class_rationale", "") or task_policy["rationale"],
        "quality_requirement": task_policy["quality_requirement"],
        "quality_requirement_source": task_policy["quality_requirement_source"],
        "task_policy_reasons": task_policy["reasons"],
        "product_gate_ready": product_gate["ready"],
        "product_gate_reasons": product_gate["reasons"],
        "product_user_value": product.get("user_value", ""),
        "product_non_goals": product.get("non_goals", []),
        "quality_review_status": quality.get("review_status", ""),
        "quality_anchor_ready": quality_anchor["ready"],
        "quality_anchor_reasons": quality_anchor["reasons"],
    },
    "independent_skeptic": role_integrity["independent_skeptic"],
    "degraded": role_integrity["degraded"],
    "degraded_ack_required": degraded_ack["required"],
    "degraded_ack_ready": degraded_ack["ready"],
    "degraded_ack_by": degraded_ack["ack_by"],
    "degraded_ack_at": degraded_ack["ack_at"],
    "role_conflicts": role_integrity["role_conflicts"],
    "role_overlap": role_integrity["role_overlap"],
    "quality_seat_mode": quality_seat["mode"],
    "quality_seat_ready": quality_seat["execution_ready"],
    "quality_seat_status": quality_seat["execution_status"],
    "quality_seat_reasons": quality_seat["execution_reasons"],
    "task_class": task_policy["task_class"],
    "task_class_bucket": task_policy["bucket"],
    "quality_requirement": task_policy["quality_requirement"],
    "quality_requirement_source": task_policy["quality_requirement_source"],
    "task_policy_reasons": task_policy["reasons"],
    "scale_out_recommended": bool(team.get("scale_out_recommended", False)) or bool(scale_out_triggers),
    "scale_out_triggers": scale_out_triggers,
    "summary": {
        "supervisor_count": len(supervisors),
        "executor_count": len(executors),
        "skeptic_count": len(skeptics),
        "assignment_count": len(assignments),
        "created_worktree_count": len(created_worktrees),
        "existing_worktree_count": len(existing_worktrees),
        "quality_seat_mode": quality_seat["mode"],
        "quality_seat_ready": quality_seat["execution_ready"],
        "quality_seat_status": quality_seat["execution_status"],
    },
    "created_worktrees": created_worktrees,
    "existing_worktrees": existing_worktrees,
    "assignments": assignments,
}, ensure_ascii=False))
PY
) || status_code=$?

status_code=${status_code:-0}
json_out "$payload"
if [[ "$status_code" -ne 0 ]]; then
  exit "$status_code"
fi
