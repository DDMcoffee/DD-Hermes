#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

mode=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) mode="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
if [[ -z "$mode" ]]; then
  json_out '{"error":"mode is required"}'
  exit 3
fi

case "$mode" in
  decay|reconcile|archive|delete|validate) ;;
  *)
    json_out '{"error":"invalid mode"}'
    exit 3
    ;;
esac

repo=$(repo_root)
mkdir -p "$repo/memory/journal"
journal="$repo/memory/journal/$(today_utc).jsonl"

result=$(INPUT_JSON="$input_json" MODE="$mode" REPO="$repo" JOURNAL="$journal" python3 - <<'PY'
import json
import os
from datetime import datetime, timezone
from pathlib import Path

data = json.loads(os.environ["INPUT_JSON"])
mode = os.environ["MODE"]
repo = Path(os.environ["REPO"])
journal = Path(os.environ["JOURNAL"])
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
ids = data.get("memory_ids", [])
status_override = data.get("status")
reason = data.get("reason", mode)

updated = []
archived = []
deleted = []
kept_conflicts = []

paths = []
for memory_id in ids:
    if any(token in memory_id for token in ("..", "*", "?", "[")):
        continue
    found = [path for path in (repo / "memory").rglob("*.md") if path.stem == memory_id]
    paths.extend(found)

for path in paths:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        continue
    parts = text.split("---\n", 2)
    frontmatter = {}
    for line in parts[1].splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            frontmatter[k.strip()] = v.strip().strip('"')

    before = dict(frontmatter)
    if frontmatter.get("type") == "constraint" and mode != "validate":
        kept_conflicts.append(path.name)
        event = {
            "event_id": f"{frontmatter['id']}:{timestamp}:reject-{mode}",
            "memory_id": frontmatter["id"],
            "op": "conflict",
            "actor": "memory-manage",
            "timestamp": timestamp,
            "before": before,
            "after": before,
            "reason": f"constraint memory cannot be changed through {mode}",
            "source_ref": "memory-manage",
            "scope": frontmatter.get("scope"),
            "confidence_delta": 0,
            "result": "rejected",
        }
        with journal.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(event, ensure_ascii=False) + "\n")
        continue

    if mode == "decay":
        confidence = max(0.0, float(frontmatter.get("confidence", "0")) - 0.1)
        frontmatter["confidence"] = f"{confidence:.2f}"
        updated.append(path.name)
    elif mode == "validate":
        frontmatter["last_validated_at"] = timestamp
        updated.append(path.name)
    elif mode == "archive":
        frontmatter["status"] = status_override or "archived"
        archived.append(path.name)
    elif mode == "reconcile":
        if status_override:
          frontmatter["status"] = status_override
        updated.append(path.name)
    elif mode == "delete":
        path.unlink()
        deleted.append(path.name)
        after = None
        event = {
            "event_id": f"{before['id']}:{timestamp}:delete",
            "memory_id": before["id"],
            "op": "delete",
            "actor": "memory-manage",
            "timestamp": timestamp,
            "before": before,
            "after": after,
            "reason": reason,
            "source_ref": "memory-manage",
            "scope": before.get("scope"),
            "confidence_delta": 0,
            "result": "ok",
        }
        with journal.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(event, ensure_ascii=False) + "\n")
        continue

    if mode != "delete":
        body = "---\n" + "\n".join(f"{k}: {v}" for k, v in frontmatter.items()) + "\n---\n" + parts[2]
        path.write_text(body, encoding="utf-8")
        event = {
            "event_id": f"{frontmatter['id']}:{timestamp}:{mode}",
            "memory_id": frontmatter["id"],
            "op": mode,
            "actor": "memory-manage",
            "timestamp": timestamp,
            "before": before,
            "after": frontmatter,
            "reason": reason,
            "source_ref": "memory-manage",
            "scope": frontmatter.get("scope"),
            "confidence_delta": -0.1 if mode == "decay" else 0,
            "result": "ok",
        }
        with journal.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(event, ensure_ascii=False) + "\n")

print(json.dumps({
    "updated": updated,
    "archived": archived,
    "deleted": deleted,
    "kept_conflicts": kept_conflicts,
}, ensure_ascii=False))
PY
)

"$SCRIPT_DIR/memory-refresh-views.sh" >/dev/null || true
json_out "$result"
if [[ "$result" == *"kept_conflicts"* && "$result" != *'"kept_conflicts": []'* ]]; then
  exit 2
fi
