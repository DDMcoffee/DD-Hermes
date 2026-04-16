#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

days="7"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) days="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
logs_dir="$repo/workspace/logs"

payload=$(python3 - <<'PY' "$logs_dir" "$days"
import json
import sys
from collections import Counter, defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

logs_dir = Path(sys.argv[1])
days = int(sys.argv[2])
cutoff = datetime.now(timezone.utc) - timedelta(days=days)

if not logs_dir.exists():
    print(json.dumps({
        "session_count": 0,
        "days_scanned": days,
        "tool_usage": {},
        "error_frequency": {},
        "total_errors": 0,
        "file_change_count": 0,
        "fragmentation_score": 0.0,
        "kb_suggestions": [],
        "warnings": ["no logs directory found"],
    }, ensure_ascii=False))
    raise SystemExit(0)

sessions = []
for log_file in sorted(logs_dir.glob("session-*.jsonl")):
    for line in log_file.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            event = json.loads(line)
            ts = event.get("timestamp", "")
            if ts:
                try:
                    event_dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
                    if event_dt < cutoff:
                        continue
                except (ValueError, TypeError):
                    pass
            sessions.append(event)
        except json.JSONDecodeError:
            continue

tool_usage = Counter()
error_frequency = Counter()
total_errors = 0
file_changes = 0
frag_signals = defaultdict(int)

for s in sessions:
    for tool, count in s.get("tool_counts", {}).items():
        tool_usage[tool] += count
    for err_type, count in s.get("error_counts", {}).items():
        error_frequency[err_type] += count
        total_errors += count
    file_changes += len(s.get("file_changes", []))
    for signal, value in s.get("fragmentation_signals", {}).items():
        frag_signals[signal] += value

frag_score = 0.0
if sessions:
    frag_total = sum(frag_signals.values())
    frag_score = round(frag_total / len(sessions), 2)

kb_suggestions = []
for err_type, count in error_frequency.most_common():
    if count >= 3:
        kb_suggestions.append({
            "error_type": err_type,
            "occurrences": count,
            "suggestion": f"Error '{err_type}' occurred {count} times in {days} days. Consider adding a knowledge base entry with resolution steps.",
        })

print(json.dumps({
    "session_count": len(sessions),
    "days_scanned": days,
    "tool_usage": dict(tool_usage.most_common(20)),
    "error_frequency": dict(error_frequency.most_common(20)),
    "total_errors": total_errors,
    "file_change_count": file_changes,
    "fragmentation_score": frag_score,
    "kb_suggestions": kb_suggestions,
    "warnings": [],
}, ensure_ascii=False))
PY
)

json_out "$payload"
