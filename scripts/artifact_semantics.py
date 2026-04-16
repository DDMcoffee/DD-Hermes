from __future__ import annotations

import re


def parse_frontmatter(text: str) -> dict:
    if not isinstance(text, str) or not text.startswith("---\n"):
        return {}
    try:
        _, frontmatter, _ = text.split("---\n", 2)
    except ValueError:
        return {}

    data = {}
    current = None
    for line in frontmatter.splitlines():
        if not line.strip():
            continue
        if line.startswith("  - ") and current:
            data.setdefault(current, []).append(line[4:].strip())
            continue
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        value = value.strip()
        if value:
            data[key] = value.strip('"')
            current = None
        else:
            data[key] = []
            current = key
    return data


def _clean_text(value):
    return value.strip() if isinstance(value, str) else ""


def _clean_list(value):
    if value is None:
        return []
    if isinstance(value, tuple):
        value = list(value)
    if not isinstance(value, list):
        value = [value]
    cleaned = []
    for item in value:
        if not isinstance(item, str):
            continue
        text = item.strip()
        if text:
            cleaned.append(text)
    return cleaned


def _looks_placeholder(value: str, *, path_like: bool = False) -> bool:
    text = _clean_text(value).lower()
    if not text:
        return True
    blocked = {
        "tbd",
        "none at bootstrap time.",
        "awaiting quality anchor review after execution evidence is written.",
        "update with execution evidence before handing back to lead.",
        "command and result",
        "residual risk",
        "follow-up action",
        "summarize the quality anchor review status here.",
    }
    if path_like:
        blocked.add("path/to/file")
    return text in blocked


def _section_body(text: str, heading: str) -> str:
    if not isinstance(text, str):
        return ""
    pattern = rf"^## {re.escape(heading)}\n\n(?P<body>.*?)(?=^## |\Z)"
    match = re.search(pattern, text, flags=re.MULTILINE | re.DOTALL)
    if not match:
        return ""
    return match.group("body").strip()


def closeout_semantic_analysis(frontmatter: dict, text: str = "", state: dict | None = None) -> dict:
    frontmatter = frontmatter if isinstance(frontmatter, dict) else {}
    state = state if isinstance(state, dict) else {}

    execution_commit = _clean_text(frontmatter.get("execution_commit", ""))
    verified_steps = _clean_list(frontmatter.get("verified_steps", []))
    verified_files = _clean_list(frontmatter.get("verified_files", []))
    review_status = _clean_text(frontmatter.get("quality_review_status", ""))
    findings = _clean_list(frontmatter.get("quality_findings_summary", []))

    reasons = []

    if _looks_placeholder(execution_commit):
        reasons.append("execution_commit_missing")
    if not verified_steps or any(_looks_placeholder(item) for item in verified_steps):
        reasons.append("verified_steps_incomplete")
    if not verified_files or any(_looks_placeholder(item, path_like=True) for item in verified_files):
        reasons.append("verified_files_incomplete")
    if review_status not in {"approved", "degraded-approved"}:
        reasons.append(f"quality_review_status_{review_status or 'missing'}")
    if not findings or any(_looks_placeholder(item) for item in findings):
        reasons.append("quality_findings_summary_incomplete")

    completion_body = _section_body(text, "Completion")
    verification_body = _section_body(text, "Verification")
    quality_body = _section_body(text, "Quality Review")
    if not completion_body or completion_body.lower().startswith("replace this placeholder"):
        reasons.append("completion_section_incomplete")
    if not verification_body or verification_body.lower().startswith("add exact commands"):
        reasons.append("verification_section_incomplete")
    if not quality_body or quality_body.lower().startswith("record the quality anchor judgment"):
        reasons.append("quality_review_section_incomplete")

    latest_commit = ""
    if isinstance(state.get("git"), dict):
        latest_commit = _clean_text(state["git"].get("latest_commit", ""))
    if execution_commit and latest_commit and execution_commit != latest_commit:
        if not latest_commit.startswith(execution_commit) and not execution_commit.startswith(latest_commit):
            reasons.append("execution_commit_mismatch_state_git")

    return {
        "ready": not reasons,
        "reasons": reasons,
        "execution_commit": execution_commit,
        "quality_review_status": review_status,
        "verified_step_count": len(verified_steps),
        "verified_file_count": len(verified_files),
        "quality_findings_count": len(findings),
    }
