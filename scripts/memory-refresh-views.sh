#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/common.sh"

repo=$(repo_root)
payload=$(python3 - <<'PY' "$repo"
import json
import sys
from collections import Counter
from pathlib import Path

repo = Path(sys.argv[1]).resolve()
views_dir = repo / "memory" / "views"
views_dir.mkdir(parents=True, exist_ok=True)


def parse_frontmatter(path: Path):
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        return None
    frontmatter = {}
    for line in text.split("---\n", 2)[1].splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = value.strip().strip('"')
    frontmatter["path"] = str(path)
    frontmatter["kind"] = path.parent.name
    return frontmatter


cards = []
for root in ("user", "task", "world", "self"):
    for path in sorted((repo / "memory" / root).glob("*.md")):
        card = parse_frontmatter(path)
        if card:
            cards.append(card)

conflicts = []
for journal in sorted((repo / "memory" / "journal").glob("*.jsonl")):
    for line in journal.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        event = json.loads(line)
        if event.get("op") == "conflict":
            conflicts.append(event)

active = [card for card in cards if card.get("status") == "active"]
expired = [card for card in cards if card.get("status") == "expired"]
counts = Counter(card["kind"] for card in cards)
status_counts = Counter(card.get("status", "unknown") for card in cards)

index_md = [
    "# Memory Views",
    "",
    f"- Total cards: {len(cards)}",
    f"- Active: {len(active)}",
    f"- Expired: {len(expired)}",
    f"- Conflict events: {len(conflicts)}",
    "",
    "## By Kind",
    "",
]
for kind in ("user", "task", "world", "self"):
    index_md.append(f"- {kind}: {counts.get(kind, 0)}")
index_md.extend(["", "## By Status", ""])
for status in sorted(status_counts):
    index_md.append(f"- {status}: {status_counts[status]}")

active_md = ["# Active Memories", ""]
for card in active:
    active_md.append(
        f"- `{card['kind']}/{card.get('id', '')}` | {card.get('type', '')} | "
        f"scope={card.get('scope', '')} | confidence={card.get('confidence', '')}"
    )
    active_md.append(f"  {card.get('content', '')}")
if len(active_md) == 2:
    active_md.append("- None")

expired_md = ["# Expired Memories", ""]
for card in expired:
    expired_md.append(f"- `{card['kind']}/{card.get('id', '')}` | scope={card.get('scope', '')}")
if len(expired_md) == 2:
    expired_md.append("- None")

conflicts_md = ["# Memory Conflicts", ""]
for event in conflicts:
    conflicts_md.append(
        f"- {event.get('timestamp', '')} | {event.get('memory_id', '')} | "
        f"{event.get('reason', '')} | result={event.get('result', '')}"
    )
if len(conflicts_md) == 2:
    conflicts_md.append("- None")

(views_dir / "index.md").write_text("\n".join(index_md) + "\n", encoding="utf-8")
(views_dir / "active.md").write_text("\n".join(active_md) + "\n", encoding="utf-8")
(views_dir / "expired.md").write_text("\n".join(expired_md) + "\n", encoding="utf-8")
(views_dir / "conflicts.md").write_text("\n".join(conflicts_md) + "\n", encoding="utf-8")

print(json.dumps({
    "views": {
        "index": str(views_dir / "index.md"),
        "active": str(views_dir / "active.md"),
        "expired": str(views_dir / "expired.md"),
        "conflicts": str(views_dir / "conflicts.md"),
    },
    "card_count": len(cards),
    "conflict_count": len(conflicts),
}, ensure_ascii=False))
PY
)
json_out "$payload"
