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
errors = []
checked = []
script_dir = (repo / "scripts").resolve()
sys.path.insert(0, str(script_dir))

from artifact_semantics import closeout_semantic_analysis, closeout_verdict, parse_frontmatter, skeptic_lane_verdict


def check_markdown(path, required_frontmatter, required_sections, label):
    if not path.exists():
        errors.append(f"{label} missing: {path}")
        return {}
    text = path.read_text(encoding="utf-8")
    frontmatter = parse_frontmatter(text)
    missing_keys = [key for key in required_frontmatter if key not in frontmatter]
    if missing_keys:
        errors.append(f"{label} missing frontmatter keys {missing_keys}: {path}")
    for section in required_sections:
        if section not in text:
            errors.append(f"{label} missing section '{section}': {path}")
    checked.append(str(path))
    return frontmatter


def schema_v2(frontmatter):
    return str(frontmatter.get("schema_version", "")).strip() == "2"


contract_path = repo / "workspace" / "contracts" / f"{task_id}.md"
contract_frontmatter = check_markdown(
    contract_path,
    required_frontmatter=("task_id", "owner", "experts", "acceptance", "blocked_if", "memory_reads", "memory_writes"),
    required_sections=("## Context", "## Scope", "## Required Fields", "## Acceptance", "## Verification", "## Open Questions"),
    label="contract",
)
if schema_v2(contract_frontmatter):
    missing = [key for key in ("schema_version", "product_goal", "user_value", "task_class", "quality_requirement", "task_class_rationale", "non_goals", "product_acceptance", "drift_risk") if key not in contract_frontmatter]
    if missing:
        errors.append(f"contract missing v2 frontmatter keys {missing}: {contract_path}")
    if "## Product Gate" not in contract_path.read_text(encoding="utf-8"):
        errors.append(f"contract missing section '## Product Gate': {contract_path}")

handoff_paths = sorted((repo / "workspace" / "handoffs").glob(f"{task_id}-*.md"))
if not handoff_paths:
    errors.append(f"handoff missing for task {task_id}")
for handoff_path in handoff_paths:
    handoff_frontmatter = check_markdown(
        handoff_path,
        required_frontmatter=("from", "to", "scope", "files", "decisions", "risks", "next_checks"),
        required_sections=("## Context", "## Required Fields", "## Acceptance", "## Verification", "## Open Questions"),
        label="handoff",
    )
    if schema_v2(handoff_frontmatter):
        missing = [key for key in ("schema_version", "product_rationale", "goal_drift_risk", "user_visible_outcome") if key not in handoff_frontmatter]
        if missing:
            errors.append(f"handoff missing v2 frontmatter keys {missing}: {handoff_path}")
        if "## Product Check" not in handoff_path.read_text(encoding="utf-8"):
            errors.append(f"handoff missing section '## Product Check': {handoff_path}")

closeout_paths = sorted((repo / "workspace" / "closeouts").glob(f"{task_id}-*.md"))
if not closeout_paths:
    errors.append(f"closeout missing for task {task_id}")
closeout_semantics = []
for closeout_path in closeout_paths:
    closeout_text = closeout_path.read_text(encoding="utf-8") if closeout_path.exists() else ""
    closeout_frontmatter = check_markdown(
        closeout_path,
        required_frontmatter=(
            "task_id",
            "from",
            "to",
            "scope",
            "execution_commit",
            "state_path",
            "context_path",
            "runtime_path",
            "verified_steps",
            "verified_files",
            "open_risks",
            "next_actions",
        ),
        required_sections=("## Context", "## Required Fields", "## Completion", "## Verification", "## Open Questions"),
        label="closeout",
    )
    if schema_v2(closeout_frontmatter):
        missing = [key for key in ("schema_version", "quality_review_status", "quality_findings_summary") if key not in closeout_frontmatter]
        if missing:
            errors.append(f"closeout missing v2 frontmatter keys {missing}: {closeout_path}")
        if "## Quality Review" not in closeout_text:
            errors.append(f"closeout missing section '## Quality Review': {closeout_path}")
    closeout_semantics.append({
        "path": str(closeout_path),
        **closeout_semantic_analysis(closeout_frontmatter, closeout_text),
    })

state_path = repo / "workspace" / "state" / task_id / "state.json"
state = None
if not state_path.exists():
    errors.append(f"state missing: {state_path}")
else:
    state = json.loads(state_path.read_text(encoding="utf-8"))
    required_state_keys = ("task_id", "status", "mode", "owner", "experts", "verification", "runtime", "git", "memory", "team", "updated_at")
    missing_state = [key for key in required_state_keys if key not in state]
    if missing_state:
        errors.append(f"state missing keys {missing_state}: {state_path}")
    team = state.get("team", {}) if isinstance(state.get("team"), dict) else {}
    required_team_keys = ("supervisors", "executors", "skeptics", "scale_out_recommended", "scale_out_triggers", "role_integrity")
    missing_team = [key for key in required_team_keys if key not in team]
    if missing_team:
        errors.append(f"state.team missing keys {missing_team}: {state_path}")
    integrity = team.get("role_integrity", {}) if isinstance(team.get("role_integrity"), dict) else {}
    required_integrity_keys = ("independent_skeptic", "degraded", "degraded_ack_by", "degraded_ack_at", "role_conflicts", "role_overlap")
    missing_integrity = [key for key in required_integrity_keys if key not in integrity]
    if missing_integrity:
        errors.append(f"state.team.role_integrity missing keys {missing_integrity}: {state_path}")
    if int(state.get("state_version", 1) or 1) >= 2:
        verdicts = state.get("verdicts", {}) if isinstance(state.get("verdicts"), dict) else {}
        if "skeptic_lane" not in verdicts:
            verdicts["skeptic_lane"] = skeptic_lane_verdict(
                repo,
                task_id,
                state=state,
                updated_at=state.get("updated_at", ""),
            )
        required_verdicts = (
            "updated_at",
            "task_policy",
            "product_gate",
            "quality_anchor",
            "quality_review",
            "degraded_ack",
            "quality_seat_execution",
            "quality_seat_completion",
            "skeptic_lane",
            "execution_closeout",
        )
        missing_verdicts = [key for key in required_verdicts if key not in verdicts]
        if missing_verdicts:
            errors.append(f"state.verdicts missing keys {missing_verdicts}: {state_path}")
        required_team_v2 = ("product_anchors", "quality_anchors", "anchor_policy")
        missing_team_v2 = [key for key in required_team_v2 if key not in team]
        if missing_team_v2:
            errors.append(f"state.team missing v2 keys {missing_team_v2}: {state_path}")
        anchor_policy = team.get("anchor_policy", {}) if isinstance(team.get("anchor_policy"), dict) else {}
        required_anchor_policy = ("product_anchor_role", "quality_anchor_role", "constant_anchor_seats")
        missing_anchor_policy = [key for key in required_anchor_policy if key not in anchor_policy]
        if missing_anchor_policy:
            errors.append(f"state.team.anchor_policy missing keys {missing_anchor_policy}: {state_path}")
        product = state.get("product", {}) if isinstance(state.get("product"), dict) else {}
        required_product = ("anchor", "goal", "user_value", "task_class", "quality_requirement", "task_class_rationale", "non_goals", "product_acceptance", "drift_risk", "goal_status", "goal_drift_flags", "last_product_review_at")
        missing_product = [key for key in required_product if key not in product]
        if missing_product:
            errors.append(f"state.product missing keys {missing_product}: {state_path}")
        quality = state.get("quality", {}) if isinstance(state.get("quality"), dict) else {}
        required_quality = ("anchor", "review_status", "review_findings", "review_examples", "last_review_at")
        missing_quality = [key for key in required_quality if key not in quality]
        if missing_quality:
            errors.append(f"state.quality missing keys {missing_quality}: {state_path}")
        required_verdict_entry = ("status", "ready", "reasons", "updated_at")
        for verdict_key in ("task_policy", "product_gate", "quality_anchor", "quality_review", "degraded_ack", "quality_seat_execution", "quality_seat_completion", "skeptic_lane", "execution_closeout"):
            verdict = verdicts.get(verdict_key, {}) if isinstance(verdicts.get(verdict_key), dict) else {}
            missing_verdict_entry = [key for key in required_verdict_entry if key not in verdict]
            if missing_verdict_entry:
                errors.append(f"state.verdicts.{verdict_key} missing keys {missing_verdict_entry}: {state_path}")
    checked.append(str(state_path))

semantic_errors = []
execution_closeout = {
    "status": "blocked",
    "ready": False,
    "reasons": ["state_missing"],
    "updated_at": "",
    "closeout_path": "",
    "selected_by": "",
    "candidate_count": 0,
    "semantic_valid": False,
    "ready_for_execution_slice_done": False,
}
if state is not None:
    execution_closeout = closeout_verdict(
        repo,
        task_id,
        state=state,
        updated_at=state.get("updated_at", ""),
    )
    if execution_closeout.get("status") == "not-required":
        closeout_semantics = []
    else:
        closeout_semantics = [
            {
                "path": item["path"],
                **closeout_semantic_analysis(
                    parse_frontmatter(Path(item["path"]).read_text(encoding="utf-8")),
                    Path(item["path"]).read_text(encoding="utf-8"),
                    state,
                ),
            }
            for item in closeout_semantics
        ]
for item in closeout_semantics:
    for reason in item.get("reasons", []):
        semantic_errors.append(f"{reason}: {item['path']}")

result = {
    "task_id": task_id,
    "checked": checked,
    "artifacts": {
        "contract_path": str(contract_path),
        "handoff_paths": [str(path) for path in handoff_paths],
        "closeout_paths": [str(path) for path in closeout_paths],
        "state_path": str(state_path),
    },
    "errors": errors,
    "valid": len(errors) == 0,
    "closeout_semantics": closeout_semantics,
    "execution_closeout": execution_closeout,
    "semantic_errors": semantic_errors,
    "semantic_valid": len(semantic_errors) == 0,
    "ready_for_execution_slice_done": execution_closeout.get("ready_for_execution_slice_done", False),
}
print(json.dumps(result, ensure_ascii=False))
PY
) || status_code=$?

status_code=${status_code:-0}
json_out "$payload"
if [[ "$status_code" -ne 0 ]]; then
  exit "$status_code"
fi

is_valid=$(PAYLOAD="$payload" python3 - <<'PY'
import json
import os
print("1" if json.loads(os.environ["PAYLOAD"]).get("valid") else "0")
PY
)
if [[ "$is_valid" != "1" ]]; then
  exit 2
fi
