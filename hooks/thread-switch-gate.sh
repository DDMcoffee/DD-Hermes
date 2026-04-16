#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

task_id=""
target_thread=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --target) target_thread="$2"; shift 2 ;;
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

payload=$(python3 - <<'PY' "$state_path" "$target_thread" "$SCRIPT_DIR/../scripts"
import json
import re
import sys
from pathlib import Path

state_path = Path(sys.argv[1])
target = sys.argv[2]
script_dir = Path(sys.argv[3]).resolve()
sys.path.insert(0, str(script_dir))

from team_governance import degraded_ack_analysis, product_gate_analysis, quality_anchor_analysis

if not state_path.exists():
    print(json.dumps({
        "pass": False,
        "target_thread": target,
        "discussion_policy": "",
        "synthesis_path": "",
        "blocked_reason": "state.json is missing; initialize task state before dispatching execution thread",
        "required_next_step": "run sprint-init/state-init before switching to execution",
    }, ensure_ascii=False))
    raise SystemExit(0)

state = json.loads(state_path.read_text(encoding="utf-8"))
repo_root = state_path.parents[3]
discussion = state.get("discussion", {})
policy = discussion.get("policy", "")
synthesis_path = discussion.get("synthesis_path", "")

reasons = []


def section_has_real_content(text: str, heading: str) -> bool:
    pattern = rf"^## {re.escape(heading)}\n\n(?P<body>.*?)(?=^## |\Z)"
    match = re.search(pattern, text, flags=re.MULTILINE | re.DOTALL)
    if not match:
        return False
    body = match.group("body")
    for raw_line in body.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line.startswith("- "):
            line = line[2:].strip()
        if not line:
            continue
        if line.startswith("State ") or line.startswith("Write "):
            continue
        return True
    return False

if target == "execution" and policy == "3-explorer-then-execute":
    if not synthesis_path:
        reasons.append("discussion.policy is 3-explorer-then-execute but synthesis_path is empty; complete synthesis before dispatching execution thread")
    else:
        synthesis_file = Path(synthesis_path)
        if not synthesis_file.exists():
            reasons.append(f"synthesis_path points to {synthesis_path} which does not exist")
        else:
            synthesis_text = synthesis_file.read_text(encoding="utf-8")
            has_accepted_path = section_has_real_content(synthesis_text, "Accepted Path")
            has_execution_boundary = section_has_real_content(synthesis_text, "Execution Boundary")
            if not has_accepted_path or not has_execution_boundary:
                reasons.append("discussion synthesis exists but still contains placeholder or empty Accepted Path / Execution Boundary content; finish synthesis before dispatching execution thread")

lease = state.get("lease", {})
lease_status = lease.get("status", "")
if target == "execution" and lease_status == "paused":
    reasons.append(f"lease is paused (reason: {lease.get('pause_reason', 'unknown')}); resume before dispatching")

if target == "execution":
    product = state.get("product", {}) if isinstance(state.get("product"), dict) else {}
    quality = state.get("quality", {}) if isinstance(state.get("quality"), dict) else {}
    team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
    role_integrity = team.get("role_integrity", {}) if isinstance(team.get("role_integrity"), dict) else {}
    product_gate = product_gate_analysis(product, team.get("product_anchors", []), team.get("anchor_policy", {}))
    quality_anchor = quality_anchor_analysis(quality, team.get("quality_anchors", []), team.get("anchor_policy", {}))
    degraded_ack = degraded_ack_analysis(role_integrity)
    goal = product.get("goal", "").strip()
    goal_status = product.get("goal_status", "")
    drift_flags = product.get("goal_drift_flags", [])
    if not goal:
        reasons.append("product.goal is missing; define product anchor intent before entering implementation mode")
    if goal_status in {"drifted", "blocked"}:
        reasons.append(f"product.goal_status is {goal_status}; resolve product drift before entering implementation mode")
    if drift_flags:
        reasons.append(f"product.goal_drift_flags present: {', '.join(drift_flags)}")
    if not product_gate["ready"]:
        reasons.append(f"product gate not ready: {', '.join(product_gate['reasons'])}")
    if not quality_anchor["ready"]:
        reasons.append(f"quality anchor not ready: {', '.join(quality_anchor['reasons'])}")
    if not degraded_ack["ready"]:
        reasons.append(f"degraded supervision not acknowledged: {', '.join(degraded_ack['reasons'])}")

    executors = [e for e in team.get("executors", []) if isinstance(e, str) and e.strip()]
    if not executors:
        reasons.append("no executors assigned in state.team; run dispatch-create.sh first")

    contract_path = state.get("contract_path", "")
    if not contract_path or not Path(contract_path).exists():
        reasons.append("contract_path is missing or does not exist; create sprint artifacts before dispatching execution thread")

    handoff_paths = [
        path for path in state.get("handoff_paths", [])
        if isinstance(path, str) and path.strip() and Path(path).exists()
    ]
    if not handoff_paths:
        reasons.append("handoff_paths are missing or invalid; create expert handoff before dispatching execution thread")

    runtime = state.get("runtime", {}) if isinstance(state.get("runtime"), dict) else {}
    context_path = runtime.get("last_context_path", "")
    if not context_path or not Path(context_path).exists():
        reasons.append("context packet is missing; run context-build or dispatch-create before dispatching execution thread")

    worktree_candidates = []
    if runtime.get("last_worktree_path"):
        worktree_candidates.append(Path(runtime["last_worktree_path"]))
    for executor in executors:
        worktree_candidates.append(repo_root / ".worktrees" / f"{state.get('task_id', '')}-{executor}")
    if not any(candidate.exists() for candidate in worktree_candidates):
        reasons.append("execution worktree is missing; run worktree-create or dispatch-create before dispatching execution thread")

blocked = bool(reasons)
reason = "; ".join(reasons)

result = {
    "pass": not blocked,
    "target_thread": target,
    "discussion_policy": policy,
    "synthesis_path": synthesis_path,
    "blocked_reason": reason,
    "required_next_step": reason if blocked else "",
}
print(json.dumps(result, ensure_ascii=False))
PY
)

json_out "$payload"
if [[ $(PAYLOAD="$payload" python3 -c 'import json,os; print("1" if json.loads(os.environ["PAYLOAD"])["pass"] else "0")') == "1" ]]; then
  exit 0
fi
exit 2
