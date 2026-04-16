#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

file_path=""
language=""
event="PostToolUse"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --event) event="$2"; shift 2 ;;
    --file) file_path="$2"; shift 2 ;;
    --language) language="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
repo=$(repo_root)
mkdir -p "$repo/workspace/logs"
if [[ -z "$file_path" ]]; then
  file_path=$(INPUT_JSON="$input_json" python3 - <<'PY'
import json, os
data = json.loads(os.environ.get("INPUT_JSON", "{}"))
print(data.get("file_path", ""))
PY
)
fi

if [[ -z "$language" ]]; then
  case "$file_path" in
    *.ts) language="ts" ;;
    *.tsx) language="tsx" ;;
    *.dart) language="dart" ;;
    *) language="other" ;;
  esac
fi

triggered=false
checker=""
exit_code=0
mode="not_applicable"
log_path="$repo/workspace/logs/typecheck-$(slugify "${file_path:-unknown}")-$(date -u +%H%M%S).log"

if [[ "$language" == "ts" || "$language" == "tsx" ]]; then
  triggered=true
  checker="tsc --noEmit"
  if [[ "${HOOKS_FAKE_TYPECHECK:-0}" == "1" ]]; then
    mode="fake"
    printf 'fake typecheck ok for %s\n' "$file_path" > "$log_path"
  elif command -v tsc >/dev/null 2>&1; then
    mode="real"
    if (cd "$repo" && tsc --noEmit >"$log_path" 2>&1); then
      exit_code=0
    else
      exit_code=$?
    fi
  else
    mode="skipped"
    printf 'tsc not found; skipped\n' > "$log_path"
  fi
elif [[ "$language" == "dart" ]]; then
  triggered=true
  checker="dart analyze"
  if [[ "${HOOKS_FAKE_TYPECHECK:-0}" == "1" ]]; then
    mode="fake"
    printf 'fake dart analyze ok for %s\n' "$file_path" > "$log_path"
  elif command -v dart >/dev/null 2>&1; then
    mode="real"
    if (cd "$repo" && dart analyze >"$log_path" 2>&1); then
      exit_code=0
    else
      exit_code=$?
    fi
  else
    mode="skipped"
    printf 'dart not found; skipped\n' > "$log_path"
  fi
else
  printf 'non-target file; no typecheck triggered\n' > "$log_path"
fi

payload=$(python3 - <<'PY' "$event" "$file_path" "$language" "$triggered" "$checker" "$exit_code" "$log_path" "$mode"
import json
import sys

event, file_path, language, triggered, checker, exit_code, log_path, mode = sys.argv[1:]
print(json.dumps({
    "event": event,
    "file_path": file_path,
    "language": language,
    "triggered": triggered == "true",
    "checker": checker,
    "exit_code": int(exit_code),
    "log_path": log_path,
    "mode": mode,
}, ensure_ascii=False))
PY
)

json_out "$payload"
if [[ "$exit_code" -eq 0 ]]; then
  exit 0
fi
exit "$exit_code"
