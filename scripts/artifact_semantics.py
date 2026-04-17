from __future__ import annotations

import re
from pathlib import Path


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


def _merge_reasons(*groups):
    merged = []
    seen = set()
    for group in groups:
        for item in group or []:
            text = _clean_text(item)
            if not text or text in seen:
                continue
            seen.add(text)
            merged.append(text)
    return merged


def lane_slug(agent_role: str = "", agent_id: str = "") -> str:
    role = _clean_text(agent_role)
    agent = _clean_text(agent_id)
    if not role or role == "commander":
        return ""
    return f"{role}-{agent}" if agent else role


def lane_artifact_paths(repo_root, task_id: str, *, agent_role: str = "", agent_id: str = "") -> dict:
    repo_root = Path(repo_root).resolve()
    task_id = _clean_text(task_id)
    state_dir = repo_root / "workspace" / "state" / task_id
    slug = lane_slug(agent_role, agent_id)
    if slug:
        return {
            "context_path": state_dir / f"context-{slug}.json",
            "runtime_path": state_dir / f"runtime-{slug}.json",
            "slug": slug,
        }
    return {
        "context_path": state_dir / "context.json",
        "runtime_path": state_dir / "runtime.json",
        "slug": "",
    }


def skeptic_lane_verdict(repo_root, task_id: str, *, state: dict | None = None, updated_at: str = "") -> dict:
    repo_root = Path(repo_root).resolve()
    task_id = _clean_text(task_id)
    state = state if isinstance(state, dict) else {}
    updated_at = _clean_text(updated_at) or _clean_text(state.get("updated_at", ""))

    task_policy = {}
    role_integrity = {}
    skeptics = []
    try:
        from team_governance import governance_snapshot

        governance = governance_snapshot(state)
        task_policy = governance.get("task_policy", {})
        role_integrity = governance.get("role_integrity", {})
        skeptics = governance.get("skeptics", [])
    except Exception:
        task_policy = {}
        role_integrity = {}
        skeptics = []

    requires_independent = bool(task_policy.get("requires_independent", False))
    independent_skeptic = bool(role_integrity.get("independent_skeptic", False))

    if not requires_independent and not independent_skeptic:
        return {
            "status": "not-required",
            "ready": True,
            "reasons": [],
            "updated_at": updated_at,
            "required": False,
            "independent_skeptic": False,
            "lane_count": 0,
            "ready_lane_count": 0,
            "lanes": [],
        }

    if not independent_skeptic:
        return {
            "status": "blocked",
            "ready": False,
            "reasons": ["independent_skeptic_unavailable"],
            "updated_at": updated_at,
            "required": requires_independent,
            "independent_skeptic": False,
            "lane_count": 0,
            "ready_lane_count": 0,
            "lanes": [],
        }

    lanes = []
    reasons = []
    ready_lane_count = 0
    for agent_id in _clean_list(skeptics):
        worktree_path = repo_root / ".worktrees" / f"{task_id}-{agent_id}"
        handoff_path = repo_root / "workspace" / "handoffs" / f"{task_id}-lead-to-{agent_id}.md"
        paths = lane_artifact_paths(repo_root, task_id, agent_role="skeptic", agent_id=agent_id)
        lane_reasons = []
        if not handoff_path.exists():
            lane_reasons.append(f"skeptic_handoff_missing:{agent_id}")
        if not worktree_path.exists():
            lane_reasons.append(f"skeptic_worktree_missing:{agent_id}")
        if not paths["context_path"].exists():
            lane_reasons.append(f"skeptic_context_missing:{agent_id}")
        if not paths["runtime_path"].exists():
            lane_reasons.append(f"skeptic_runtime_missing:{agent_id}")
        if not lane_reasons:
            ready_lane_count += 1
        reasons = _merge_reasons(reasons, lane_reasons)
        lanes.append(
            {
                "agent_id": agent_id,
                "ready": not lane_reasons,
                "reasons": lane_reasons,
                "handoff_path": str(handoff_path),
                "worktree_path": str(worktree_path),
                "context_path": str(paths["context_path"]),
                "runtime_path": str(paths["runtime_path"]),
            }
        )

    ready = bool(lanes) and not reasons
    return {
        "status": "ready" if ready else "blocked",
        "ready": ready,
        "reasons": reasons,
        "updated_at": updated_at,
        "required": True,
        "independent_skeptic": True,
        "lane_count": len(lanes),
        "ready_lane_count": ready_lane_count,
        "lanes": lanes,
    }


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


def closeout_verdict(repo_root, task_id: str, *, state: dict | None = None, active_expert: str = "", updated_at: str = "") -> dict:
    repo_root = Path(repo_root).resolve()
    task_id = _clean_text(task_id)
    state = state if isinstance(state, dict) else {}
    active_expert = _clean_text(active_expert) or _clean_text(state.get("active_expert", ""))
    updated_at = _clean_text(updated_at) or _clean_text(state.get("updated_at", ""))

    closeout_dir = repo_root / "workspace" / "closeouts"
    candidates = sorted(closeout_dir.glob(f"{task_id}-*.md")) if task_id else []

    task_policy = {}
    try:
        from team_governance import task_class_analysis

        task_policy = task_class_analysis(state.get("product", {}))
    except Exception:
        task_policy = {}

    if task_policy.get("bucket") == "no-execution":
        return {
            "status": "not-required",
            "ready": True,
            "reasons": [],
            "updated_at": updated_at,
            "closeout_path": "",
            "selected_by": "task_policy",
            "candidate_count": len(candidates),
            "semantic_valid": True,
            "ready_for_execution_slice_done": True,
            "execution_commit": "",
            "quality_review_status": _clean_text((state.get("quality") or {}).get("review_status", "")),
            "verified_step_count": 0,
            "verified_file_count": 0,
            "quality_findings_count": 0,
        }

    closeout_path = ""
    selection_reasons = []
    selected_by = ""
    semantic = {
        "ready": False,
        "reasons": [],
        "execution_commit": "",
        "quality_review_status": "",
        "verified_step_count": 0,
        "verified_file_count": 0,
        "quality_findings_count": 0,
    }

    selected = []
    if active_expert:
        selected = [candidate for candidate in candidates if candidate.name == f"{task_id}-{active_expert}.md"]
        if selected:
            selected_by = "active_expert"
        elif candidates:
            selection_reasons.append(f"closeout_for_active_expert_missing:{active_expert}")
        else:
            selection_reasons.append("closeout_missing")
    elif len(candidates) == 1:
        selected = candidates
        selected_by = "single_match"
    elif candidates:
        selection_reasons.append("closeout_selection_ambiguous")
    else:
        selection_reasons.append("closeout_missing")

    if selected:
        closeout_path = str(selected[0])
        closeout_text = selected[0].read_text(encoding="utf-8")
        closeout_frontmatter = parse_frontmatter(closeout_text)
        semantic = closeout_semantic_analysis(closeout_frontmatter, closeout_text, state)

    reasons = _merge_reasons(selection_reasons, semantic.get("reasons", []))
    ready = not reasons
    return {
        "status": "ready" if ready else "blocked",
        "ready": ready,
        "reasons": reasons,
        "updated_at": updated_at,
        "closeout_path": closeout_path,
        "selected_by": selected_by,
        "candidate_count": len(candidates),
        "semantic_valid": bool(semantic.get("ready", False)),
        "ready_for_execution_slice_done": ready,
        "execution_commit": semantic.get("execution_commit", ""),
        "quality_review_status": semantic.get("quality_review_status", ""),
        "verified_step_count": semantic.get("verified_step_count", 0),
        "verified_file_count": semantic.get("verified_file_count", 0),
        "quality_findings_count": semantic.get("quality_findings_count", 0),
    }
