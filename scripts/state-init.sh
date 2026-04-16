#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
owner="lead"
experts=""
status="initialized"
mode="planning"
current_focus="bootstrap"
discussion_policy="auto"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --owner) owner="$2"; shift 2 ;;
    --experts) experts="$2"; shift 2 ;;
    --status) status="$2"; shift 2 ;;
    --mode) mode="$2"; shift 2 ;;
    --current-focus) current_focus="$2"; shift 2 ;;
    --discussion-policy) discussion_policy="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

if [[ -z "$task_id" ]]; then
  json_out '{"error":"task_id is required"}'
  exit 3
fi

repo=$(shared_repo_root)
payload=$(python3 - <<'PY' "$repo" "$task_id" "$owner" "$experts" "$status" "$mode" "$current_focus" "$discussion_policy" "$SCRIPT_DIR"
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
task_id = sys.argv[2]
owner = sys.argv[3]
experts_csv = sys.argv[4]
status = sys.argv[5]
mode = sys.argv[6]
current_focus = sys.argv[7]
discussion_policy = sys.argv[8]
script_dir = Path(sys.argv[9]).resolve()
sys.path.insert(0, str(script_dir))
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

from team_governance import (
    default_product_anchors,
    default_quality_anchors,
    default_skeptics,
    normalize_people,
    product_gate_analysis,
    quality_anchor_analysis,
    quality_review_analysis,
    scale_out_analysis,
)

state_dir = repo / "workspace" / "state" / task_id
state_dir.mkdir(parents=True, exist_ok=True)
state_path = state_dir / "state.json"
events_path = state_dir / "events.jsonl"
contract_path = repo / "workspace" / "contracts" / f"{task_id}.md"
handoff_paths = sorted(str(path) for path in (repo / "workspace" / "handoffs").glob(f"{task_id}-*.md"))
exploration_paths = sorted(str(path) for path in (repo / "workspace" / "exploration").glob(f"*{task_id}*.md"))
openspec = {
    "stage": "proposal",
    "proposal_path": str(repo / "openspec" / "proposals" / f"{task_id}.md") if (repo / "openspec" / "proposals" / f"{task_id}.md").exists() else "",
    "design_path": str(repo / "openspec" / "designs" / f"{task_id}.md") if (repo / "openspec" / "designs" / f"{task_id}.md").exists() else "",
    "task_path": str(repo / "openspec" / "tasks" / f"{task_id}.md") if (repo / "openspec" / "tasks" / f"{task_id}.md").exists() else "",
    "archive_path": str(repo / "openspec" / "archive" / f"{task_id}.md") if (repo / "openspec" / "archive" / f"{task_id}.md").exists() else "",
}


def infer_discussion_policy(policy_hint: str):
    allowed = {"auto", "direct", "3-explorer-then-execute"}
    if policy_hint not in allowed:
        raise ValueError(f"unsupported discussion policy: {policy_hint}")
    if policy_hint != "auto":
        return policy_hint

    signal_text = "\n".join(
        part for part in (
            task_id,
            current_focus,
        ) if part
    ).lower()

    architecture_signals = (
        "architecture",
        "control-plane",
        "control plane",
        "thread model",
        "thread-switch",
        "policy",
        "strategy",
        "state",
        "memory",
        "coordination",
        "worktree",
        "schema",
        "protocol",
        "governance",
        "routing",
        "gate",
        "安全",
        "权限",
        "架构",
        "线程",
        "策略",
        "控制面",
        "状态",
        "记忆",
        "协调",
        "协议",
        "治理",
        "路由",
        "gate",
    )
    if any(keyword in signal_text for keyword in architecture_signals):
        return "3-explorer-then-execute"
    return "direct"


def parse_frontmatter(path: Path):
    if not path.exists():
        return {}
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return {}
    lines = text.split("---\n", 2)[1].splitlines()
    data = {}
    current = None
    for line in lines:
        if not line.strip():
            continue
        if line.startswith("  - ") and current:
            data.setdefault(current, []).append(line[4:].strip().strip('"'))
            continue
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()
        if value:
            data[key] = value.strip('"')
            current = None
        else:
            data[key] = []
            current = key
    return data

contract_frontmatter = parse_frontmatter(contract_path)
memory_reads = contract_frontmatter.get("memory_reads", [])
memory_writes = contract_frontmatter.get("memory_writes", [])
schema_version = str(contract_frontmatter.get("schema_version", "1")).strip() or "1"
product_goal = contract_frontmatter.get("product_goal", "")
user_value = contract_frontmatter.get("user_value", "")
non_goals = contract_frontmatter.get("non_goals", [])
product_acceptance = contract_frontmatter.get("product_acceptance", [])
drift_risk = contract_frontmatter.get("drift_risk", "")
experts = normalize_people(experts_csv.split(","))
if not experts:
    experts = normalize_people(contract_frontmatter.get("experts", []))
if not experts:
    experts = normalize_people([path.split("-to-")[-1].removesuffix(".md") for path in handoff_paths])

created = not state_path.exists()
if state_path.exists():
    state = json.loads(state_path.read_text(encoding="utf-8"))
else:
    resolved_discussion_policy = infer_discussion_policy(discussion_policy)
    state = {
        "state_version": 2,
        "created_at": timestamp,
        "git": {
            "baseline_commit": "",
            "latest_commit": "",
            "latest_branch": "",
            "latest_upstream": "",
            "latest_remote_urls": {},
        },
        "discussion": {
            "policy": resolved_discussion_policy,
            "decision_id": "",
            "explorer_queue": [],
            "explorer_findings": [],
            "synthesis_path": "",
            "current_executor": "",
        },
        "verification": {
            "last_pass": False,
            "last_run_at": "",
            "verified_steps": [],
            "verified_files": [],
        },
        "runtime": {
            "preferred_surface": "repo-first",
            "worktree_strategy": "isolated",
            "last_context_path": "",
            "last_runtime_report_path": "",
            "last_worktree_path": "",
        },
        "lease": {
            "goal": "",
            "status": "idle",
            "duration_hours": 0,
            "started_at": "",
            "deadline_at": "",
            "paused_at": "",
            "pause_reason": "",
            "resume_after": "",
            "resume_checkpoint": "",
            "dispatch_cursor": "",
        },
        "memory": {
            "reads": [],
            "writes": [],
            "last_selected_ids": [],
        },
        "product": {
            "anchor": "",
            "goal": "",
            "user_value": "",
            "non_goals": [],
            "product_acceptance": [],
            "drift_risk": "",
            "goal_status": "missing",
            "goal_drift_flags": [],
            "last_product_review_at": "",
        },
        "quality": {
            "anchor": "",
            "review_status": "pending",
            "review_findings": [],
            "review_examples": [],
            "last_review_at": "",
        },
        "textbook": {
            "last_entry_path": "",
            "last_summary_path": "",
            "last_summary_at": "",
        },
        "notes": [],
    }

if state_path.exists() and discussion_policy != "auto":
    state.setdefault("discussion", {})
    state["discussion"]["policy"] = infer_discussion_policy(discussion_policy)

if openspec["archive_path"]:
    openspec["stage"] = "archive"
elif openspec["task_path"]:
    openspec["stage"] = "task"
elif openspec["design_path"]:
    openspec["stage"] = "design"

resolved_owner = contract_frontmatter.get("owner") or state.get("owner") or owner
existing_team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
supervisors = normalize_people(existing_team.get("supervisors", [])) or normalize_people([resolved_owner or "lead"])
executors = normalize_people(existing_team.get("executors", [])) or experts
skeptics = normalize_people(existing_team.get("skeptics", []))
if not skeptics:
    skeptics = default_skeptics(resolved_owner, supervisors, executors)
product_anchors = normalize_people(existing_team.get("product_anchors", []))
if not product_anchors:
    product_anchors = default_product_anchors(resolved_owner, supervisors)
quality_anchors = normalize_people(existing_team.get("quality_anchors", []))
if not quality_anchors:
    quality_anchors = default_quality_anchors(resolved_owner, supervisors, skeptics, executors)
high_risk_mode = bool(existing_team.get("high_risk_mode", False))
integration_pressure = bool(existing_team.get("integration_pressure", False))
scale_out = scale_out_analysis(
    owner=resolved_owner,
    supervisors=supervisors,
    executors=executors,
    skeptics=skeptics,
    high_risk_mode=high_risk_mode,
    integration_pressure=integration_pressure,
)

state.update({
    "state_version": 2 if schema_version == "2" else state.get("state_version", 1),
    "task_id": task_id,
    "status": state.get("status", status) if not created else status,
    "mode": state.get("mode", mode) if not created else mode,
    "current_focus": state.get("current_focus", current_focus) if not created else current_focus,
    "owner": resolved_owner,
    "experts": experts,
    "active_expert": state.get("active_expert", ""),
    "blocked_reason": state.get("blocked_reason", ""),
    "contract_path": str(contract_path) if contract_path.exists() else "",
    "handoff_paths": handoff_paths,
    "exploration_paths": exploration_paths,
    "openspec": {
        **state.get("openspec", {}),
        **openspec,
    },
    "team": {
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
        "role_integrity": scale_out["role_integrity"],
    },
    "updated_at": timestamp,
})
state["memory"]["reads"] = memory_reads
state["memory"]["writes"] = memory_writes
state.setdefault("product", {})
state["product"].update({
    "anchor": product_anchors[0] if product_anchors else resolved_owner,
    "goal": product_goal,
    "user_value": user_value,
    "non_goals": non_goals,
    "product_acceptance": product_acceptance,
    "drift_risk": drift_risk,
    "goal_status": "defined" if product_goal else "missing",
    "goal_drift_flags": state.get("product", {}).get("goal_drift_flags", []),
    "last_product_review_at": timestamp if product_goal else state.get("product", {}).get("last_product_review_at", ""),
})
lease_goal = state.get("lease", {}).get("goal", "")
if not isinstance(lease_goal, str) or not lease_goal.strip():
    state.setdefault("lease", {})
    state["lease"]["goal"] = product_goal
state.setdefault("quality", {})
state["quality"].update({
    "anchor": quality_anchors[0] if quality_anchors else "",
    "review_status": state.get("quality", {}).get("review_status", "pending"),
    "review_findings": state.get("quality", {}).get("review_findings", []),
    "review_examples": state.get("quality", {}).get("review_examples", []),
    "last_review_at": state.get("quality", {}).get("last_review_at", ""),
})
product_gate = product_gate_analysis(state.get("product", {}), product_anchors, state["team"].get("anchor_policy", {}))
quality_anchor = quality_anchor_analysis(state.get("quality", {}), quality_anchors, state["team"].get("anchor_policy", {}))
quality_review = quality_review_analysis(state.get("quality", {}), quality_anchors, state["team"].get("anchor_policy", {}))
state.setdefault("notes", [])
state["notes"].append({
    "timestamp": timestamp,
    "text": "anchor governance initialized",
    "product_gate_ready": product_gate["ready"],
    "quality_anchor_ready": quality_anchor["ready"],
    "quality_review_ready": quality_review["ready"],
})

state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
event = {
    "event_id": f"{task_id}:{timestamp}:{'state-init' if created else 'state-refresh'}",
    "source": "state",
    "task_id": task_id,
    "op": "state_init" if created else "state_refresh",
    "timestamp": timestamp,
    "status": state["status"],
    "mode": state["mode"],
    "actor": "state-init",
}
with events_path.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps(event, ensure_ascii=False) + "\n")

print(json.dumps({
    "state_path": str(state_path),
    "events_path": str(events_path),
    "created": created,
    "status": state["status"],
    "mode": state["mode"],
}, ensure_ascii=False))
PY
)
json_out "$payload"
