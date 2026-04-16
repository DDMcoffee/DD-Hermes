#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

keep_days="90"
dry_run="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-days) keep_days="$2"; shift 2 ;;
    --dry-run) dry_run="true"; shift ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

repo=$(repo_root)
payload=$(python3 - <<'PY' "$repo" "$keep_days" "$dry_run"
import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

repo = Path(sys.argv[1])
keep_days = int(sys.argv[2])
dry_run = sys.argv[3] == "true"
cutoff = datetime.now(timezone.utc) - timedelta(days=keep_days)

journal_dir = repo / "memory" / "journal"
if not journal_dir.exists():
    print(json.dumps({"compacted": 0, "kept": 0, "archived": 0, "dry_run": dry_run, "warnings": ["journal directory not found"]}))
    raise SystemExit(0)

archive_dir = journal_dir / "archive"
compacted = 0
kept = 0
archived_files = []

for jf in sorted(journal_dir.glob("*.jsonl")):
    date_str = jf.stem
    try:
        file_date = datetime.strptime(date_str, "%Y-%m-%d").replace(tzinfo=timezone.utc)
    except ValueError:
        kept += 1
        continue

    if file_date < cutoff:
        if not dry_run:
            archive_dir.mkdir(parents=True, exist_ok=True)
            jf.rename(archive_dir / jf.name)
        archived_files.append(jf.name)
        compacted += 1
    else:
        kept += 1

print(json.dumps({
    "compacted": compacted,
    "kept": kept,
    "archived_files": archived_files,
    "archive_dir": str(archive_dir) if compacted else "",
    "keep_days": keep_days,
    "cutoff": cutoff.strftime("%Y-%m-%d"),
    "dry_run": dry_run,
    "warnings": [],
}, ensure_ascii=False))
PY
)

json_out "$payload"
