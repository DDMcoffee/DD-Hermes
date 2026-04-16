#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

event="Stop"
state_path=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --event) event="$2"; shift 2 ;;
    --state) state_path="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
payload=$(INPUT_JSON="$input_json" EVENT="$event" STATE_PATH="$state_path" python3 - <<'PY' "$SCRIPT_DIR/../scripts"
import json
import os
import sys
from pathlib import Path

script_dir = Path(sys.argv[1]).resolve()
sys.path.insert(0, str(script_dir))

from team_governance import product_gate_analysis, quality_review_analysis

data = json.loads(os.environ.get("INPUT_JSON", "{}"))
state_path = os.environ.get("STATE_PATH", "")
if state_path and state_path != "-":
    path = Path(state_path)
    if path.exists():
        state_data = json.loads(path.read_text(encoding="utf-8"))
        merged = dict(state_data)
        merged.update(data)
        data = merged

changed_code = data.get("changed_code_files") or []
verified = data.get("verified_steps") or []
verified_files = set(data.get("verified_files") or [])
last_exit = data.get("last_test_exit_code")
allow_global = data.get("allow_global_verification") is True or "coverage:all" in verified
product_goal_status = data.get("product_goal_status")
if product_goal_status is None and isinstance(data.get("product"), dict):
    product_goal_status = data["product"].get("goal_status")
quality_review_status = data.get("quality_review_status")
if quality_review_status is None and isinstance(data.get("quality"), dict):
    quality_review_status = data["quality"].get("review_status")
team = data.get("team", {}) if isinstance(data.get("team"), dict) else {}
product_gate = product_gate_analysis(data.get("product", {}), team.get("product_anchors", []), team.get("anchor_policy", {}))
quality_review = quality_review_analysis(data.get("quality", {}), team.get("quality_anchors", []), team.get("anchor_policy", {}))

missing = []
uncovered = []
if changed_code and not verified:
    missing.append("verified_steps")
if changed_code and last_exit not in (None, 0):
    missing.append("last_test_exit_code")
if changed_code:
    if not allow_global and not verified_files:
        missing.append("verified_files")
    elif verified_files:
        uncovered = sorted(set(changed_code) - verified_files)
        if uncovered:
            missing.append("verified_files")
if changed_code and (product_goal_status in ("missing", "drifted", "blocked", "unknown") or not product_gate["ready"]):
    missing.append("product_gate")
if changed_code and (quality_review_status not in ("approved", "degraded-approved") or not quality_review["ready"]):
    missing.append("quality_review")

passed = not missing
result = {
    "event": os.environ.get("EVENT"),
    "pass": passed,
    "missing_verification": missing,
    "uncovered_files": uncovered,
    "product_gate_reasons": product_gate["reasons"],
    "quality_review_reasons": quality_review["reasons"],
    "blocked_reason": "" if passed else "code changed without completed and covering verification",
    "required_next_step": "" if passed else "run tests that cover changed files or pass coverage:all before claiming completion",
}
print(json.dumps(result, ensure_ascii=False))
PY
)

json_out "$payload"
if [[ $(PAYLOAD="$payload" python3 - <<'PY'
import json, os
print("1" if json.loads(os.environ["PAYLOAD"])["pass"] else "0")
PY
) == "1" ]]; then
  exit 0
fi
exit 2
