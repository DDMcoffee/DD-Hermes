#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

task_id=""
max_rounds="5"
checks=""
user_gate=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --task-id) task_id="$2"; shift 2 ;;
    --max-rounds) max_rounds="$2"; shift 2 ;;
    --checks) checks="$2"; shift 2 ;;
    --user-gate) user_gate="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
repo=$(repo_root)
mkdir -p "$repo/workspace/logs"

result=$(INPUT_JSON="$input_json" CHECKS="$checks" USER_GATE="$user_gate" MAX_ROUNDS="$max_rounds" python3 - <<'PY'
import json
import os

data = json.loads(os.environ.get("INPUT_JSON", "{}"))
checks = [item for item in (os.environ.get("CHECKS") or "").split(",") if item]
checks.extend(data.get("checks", []))
user_gate = os.environ.get("USER_GATE") or data.get("user_gate", "")
max_rounds = int(os.environ.get("MAX_ROUNDS", "5"))
print(json.dumps({
    "checks": checks,
    "user_gate": user_gate,
    "max_rounds": max_rounds,
}, ensure_ascii=False))
PY
)

rounds=0
last_pass=true
remaining_failures=()
while [[ $rounds -lt $max_rounds ]]; do
  rounds=$((rounds + 1))
  check_list=()
  while IFS= read -r line; do
    check_list+=("$line")
  done < <(PAYLOAD="$result" python3 - <<'PY'
import json, os
for item in json.loads(os.environ["PAYLOAD"])["checks"]:
    print(item)
PY
  )
  last_pass=true
  remaining_failures=()
  for cmd in "${check_list[@]}"; do
    if [[ -n "$cmd" ]] && ! bash -lc "$cmd" >/dev/null 2>&1; then
      last_pass=false
      remaining_failures+=("$cmd")
    fi
  done
  if [[ "$last_pass" == true ]]; then
    break
  fi
done

user_gate_value=$(PAYLOAD="$result" python3 - <<'PY'
import json, os
print(json.loads(os.environ["PAYLOAD"])["user_gate"])
PY
)
if [[ -n "$user_gate_value" && "$user_gate_value" != "pass" ]]; then
  last_pass=false
  remaining_failures+=("user_gate:$user_gate_value")
fi

failures_serialized=""
if [[ ${#remaining_failures[@]} -gt 0 ]]; then
  failures_serialized=$(printf '%s\n' "${remaining_failures[@]}")
fi

payload=$(python3 - "$rounds" "$last_pass" "$failures_serialized" <<'PY'
import json
import sys

rounds = int(sys.argv[1])
last_pass = sys.argv[2] == "true"
failures = [line for line in sys.argv[3].splitlines() if line]
print(json.dumps({
    "rounds_used": rounds,
    "last_pass": last_pass,
    "remaining_failures": failures,
}, ensure_ascii=False))
PY
)

if [[ -n "$task_id" && -f "$repo/workspace/state/$task_id/state.json" ]]; then
  state_update=$(PAYLOAD="$result" LAST_PASS="$last_pass" python3 - <<'PY'
import json
import os

checks = json.loads(os.environ["PAYLOAD"])["checks"]
last_pass = os.environ["LAST_PASS"] == "true"
payload = {"last_pass": last_pass}
if last_pass:
    payload["append_verified_steps"] = checks
if not last_pass:
    payload["note"] = "verification failed"
print(json.dumps(payload, ensure_ascii=False))
PY
)
  printf '%s' "$state_update" | "$SCRIPT_DIR/state-update.sh" --task-id "$task_id" >/dev/null || true
fi

json_out "$payload"
if [[ "$last_pass" == true ]]; then
  exit 0
fi
exit 2
