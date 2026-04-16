#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

kind=""
memory_id=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --kind) kind="$2"; shift 2 ;;
    --id) memory_id="$2"; shift 2 ;;
    --stdin|--json) shift ;;
    *) shift ;;
  esac
done

input_json=$(read_stdin_json)
if [[ -z "$kind" || -z "$memory_id" ]]; then
  json_out '{"error":"kind and id are required"}'
  exit 3
fi

case "$kind" in
  user|task|world|self) ;;
  *)
    json_out '{"error":"invalid kind"}'
    exit 3
    ;;
esac

if [[ "$memory_id" == *".."* || "$memory_id" == /* || "$memory_id" == *"*"* || "$memory_id" == *"?"* || "$memory_id" == *"["* ]]; then
  json_out '{"error":"invalid memory id"}'
  exit 3
fi

repo=$(repo_root)
mkdir -p "$repo/memory/$kind" "$repo/memory/journal"
journal_path="$repo/memory/journal/$(today_utc).jsonl"

result=$(INPUT_JSON="$input_json" KIND="$kind" MEMORY_ID="$memory_id" REPO="$repo" JOURNAL="$journal_path" python3 - <<'PY'
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

data = json.loads(os.environ["INPUT_JSON"])
kind = os.environ["KIND"]
memory_id = os.environ["MEMORY_ID"]
repo = Path(os.environ["REPO"])
journal = Path(os.environ["JOURNAL"])
timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

card_path = repo / "memory" / kind / f"{memory_id}.md"
card_path.parent.mkdir(parents=True, exist_ok=True)

memory_type = data["type"]
content = data["content"]
source = data["source"]
scope = data["scope"]
confidence = data["confidence"]
status = data["status"]
decay_policy = data.get("decay_policy", "manual")

deduped = False
conflicts = []
existing = None

if not re.fullmatch(r"[A-Za-z0-9._/-]+", memory_id):
    print(json.dumps({"error": "invalid memory id"}, ensure_ascii=False))
    raise SystemExit(3)

def parse_frontmatter(path: Path):
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return None, text
    parts = text.split("---\n", 2)
    frontmatter_lines = parts[1].splitlines()
    frontmatter = {}
    for line in frontmatter_lines:
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = value.strip().strip('"')
    return frontmatter, text

def yaml_scalar(value):
    if isinstance(value, (int, float)):
        return str(value)
    return json.dumps(str(value), ensure_ascii=False)

if card_path.exists():
    existing, text = parse_frontmatter(card_path)

if memory_type == "constraint":
    for other_path in (repo / "memory").rglob("*.md"):
        frontmatter, _ = parse_frontmatter(other_path)
        if not frontmatter or frontmatter.get("type") != "constraint":
            continue
        if frontmatter.get("id") == memory_id:
            continue
        if frontmatter.get("scope") == scope and frontmatter.get("content") != content:
            event = {
                "event_id": f"{memory_id}:{timestamp}:reject-conflicting-constraint",
                "memory_id": memory_id,
                "op": "conflict",
                "actor": "memory-write",
                "timestamp": timestamp,
                "before": frontmatter,
                "after": data,
                "reason": "constraint scope already has a different policy reference",
                "source_ref": source,
                "scope": scope,
                "confidence_delta": 0,
                "result": "rejected",
            }
            with journal.open("a", encoding="utf-8") as fh:
                fh.write(json.dumps(event, ensure_ascii=False) + "\n")
            print(json.dumps({
                "card_path": str(card_path),
                "journal_path": str(journal),
                "deduped": False,
                "conflicts": ["conflicting_constraint_scope"],
                "blocked": True,
            }, ensure_ascii=False))
            raise SystemExit(2)

if existing:
    if existing.get("type") == "constraint" and existing.get("content") != content:
        event = {
            "event_id": f"{memory_id}:{timestamp}:reject",
            "memory_id": memory_id,
            "op": "conflict",
            "actor": "memory-write",
            "timestamp": timestamp,
            "before": existing,
            "after": data,
            "reason": "constraint memory cannot rewrite policy",
            "source_ref": source,
            "scope": scope,
            "confidence_delta": 0,
            "result": "rejected",
        }
        with journal.open("a", encoding="utf-8") as fh:
            fh.write(json.dumps(event, ensure_ascii=False) + "\n")
        print(json.dumps({
            "card_path": str(card_path),
            "journal_path": str(journal),
            "deduped": False,
            "conflicts": ["constraint_rewrite_blocked"],
            "blocked": True,
        }, ensure_ascii=False))
        raise SystemExit(2)
    if existing.get("content") == content and existing.get("scope") == scope:
        deduped = True
    else:
        conflicts.append({
            "existing_content": existing.get("content"),
            "incoming_content": content,
            "timestamp": timestamp,
        })
        text += "\n## Conflicts\n\n" + "\n".join(
            f"- {item['timestamp']}: {item['incoming_content']}" for item in conflicts
        ) + "\n"
        card_path.write_text(text, encoding="utf-8")
else:
    body = (
        "---\n"
        f"id: {yaml_scalar(memory_id)}\n"
        f"type: {yaml_scalar(memory_type)}\n"
        f"content: {yaml_scalar(content)}\n"
        f"source: {yaml_scalar(source)}\n"
        f"scope: {yaml_scalar(scope)}\n"
        f"confidence: {yaml_scalar(confidence)}\n"
        f"created_at: {yaml_scalar(timestamp)}\n"
        f"last_validated_at: {yaml_scalar(timestamp)}\n"
        f"decay_policy: {yaml_scalar(decay_policy)}\n"
        f"status: {yaml_scalar(status)}\n"
        "---\n\n"
        "# Memory Card\n\n"
        "## Evidence\n\n"
        f"- Source: {source}\n"
        f"- Scope: {scope}\n"
    )
    card_path.write_text(body, encoding="utf-8")

event = {
    "event_id": f"{memory_id}:{timestamp}:{'dedupe' if deduped else 'write'}",
    "memory_id": memory_id,
    "op": "write" if not conflicts else "conflict",
    "actor": "memory-write",
    "timestamp": timestamp,
    "before": existing,
    "after": data,
    "reason": "deduped" if deduped else "write_memory",
    "source_ref": source,
    "scope": scope,
    "confidence_delta": 0,
    "result": "ok",
}
with journal.open("a", encoding="utf-8") as fh:
    fh.write(json.dumps(event, ensure_ascii=False) + "\n")

print(json.dumps({
    "card_path": str(card_path),
    "journal_path": str(journal),
    "deduped": deduped,
    "conflicts": conflicts,
    "blocked": False,
}, ensure_ascii=False))
PY
) || status_code=$?

status_code=${status_code:-0}
"$SCRIPT_DIR/memory-refresh-views.sh" >/dev/null || true
json_out "$result"
if [[ "$status_code" -ne 0 ]]; then
  exit "$status_code"
fi
