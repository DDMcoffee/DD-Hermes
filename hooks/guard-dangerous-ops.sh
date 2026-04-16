#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../scripts/common.sh
source "$SCRIPT_DIR/../scripts/common.sh"

event="PreToolUse"
tool=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --event) event="$2"; shift 2 ;;
    --tool) tool="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)

payload=$(INPUT_JSON="$input_json" EVENT="$event" TOOL="$tool" python3 - <<'PY'
import json
import os
import re
import shlex
from pathlib import PurePosixPath

data = json.loads(os.environ.get("INPUT_JSON", "{}"))
command = data.get("command", "")
args = data.get("args") or []
if not command and args:
    command = " ".join(args)
if not command:
    command = " ".join(data.get("argv", []))
command = command.strip()

def command_tokens(raw: str):
    try:
        return shlex.split(raw)
    except ValueError:
        return raw.split()

def detect_danger(tokens, raw: str):
    lowered = [token.lower() for token in tokens]
    basenames = [PurePosixPath(token).name.lower() for token in lowered]

    if "rm" in basenames:
        rm_index = basenames.index("rm")
        rm_flags = [token.lstrip("-") for token in lowered[rm_index + 1:] if token.startswith("-")]
        has_recursive = any("r" in flag for flag in rm_flags)
        has_force = any("f" in flag for flag in rm_flags)
        if has_recursive and has_force:
            return ("rm -rf", "使用更窄的删除范围，或先人工确认。")

    for index, base in enumerate(basenames):
        if base == "git" and index + 1 < len(tokens) and lowered[index + 1] == "push":
            if any(token in ("--force", "-f") for token in lowered[index + 2:]):
                return ("git force push", "先确认 remote 和分支，再人工确认。")

    if re.search(r"\b(drop|truncate)\s+(table|database)\b", raw, flags=re.IGNORECASE):
        return ("destructive sql", "改用迁移或显式备份后的流程。")

    if re.search(r"\bchmod\s+777\b", raw, flags=re.IGNORECASE):
        return ("chmod 777", "用最小权限替代。")

    if re.search(r"(\.env(\.[A-Za-z0-9_-]+)?)(\s|$)|[>]{1,2}\s*\.env\b|tee\s+\.env\b", raw, flags=re.IGNORECASE):
        return (".env write", "敏感配置写入需要人工确认。")

    return None

matched_rule = None
reason = "allowed"
suggested_fix = ""
allow = True
match = detect_danger(command_tokens(command), command)
if match:
    allow = False
    matched_rule, suggested_fix = match
    reason = f"blocked by {matched_rule}"

result = {
    "event": os.environ.get("EVENT"),
    "tool": os.environ.get("TOOL"),
    "allow": allow,
    "reason": reason,
    "matched_rule": matched_rule,
    "suggested_fix": suggested_fix,
    "command": command,
}
print(json.dumps(result, ensure_ascii=False))
PY
)

json_out "$payload"
if [[ $(PAYLOAD="$payload" python3 - <<'PY'
import json, os
print("1" if json.loads(os.environ["PAYLOAD"])["allow"] else "0")
PY
) == "1" ]]; then
  exit 0
fi
exit 2
