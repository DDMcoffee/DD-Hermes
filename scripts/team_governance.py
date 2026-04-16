from __future__ import annotations


def normalize_people(items, field_name="items", require_list=False):
    if items is None:
        items = []
    if isinstance(items, tuple):
        items = list(items)
    if require_list and not isinstance(items, list):
        raise ValueError(f"{field_name} must be a list of agent ids")
    if not isinstance(items, list):
        items = [items]

    seen = set()
    result = []
    for item in items:
        if not isinstance(item, str):
            if require_list:
                raise ValueError(f"{field_name} must contain strings")
            continue
        value = item.strip()
        if not value or value in seen:
            continue
        seen.add(value)
        result.append(value)
    return result


def merge_triggers(*groups):
    merged = []
    seen = set()
    for group in groups:
        for item in group or []:
            if not isinstance(item, str):
                continue
            value = item.strip()
            if not value or value in seen:
                continue
            seen.add(value)
            merged.append(value)
    return merged


def _clean_text(value):
    return value.strip() if isinstance(value, str) else ""


def _clean_list(items):
    if items is None:
        return []
    if isinstance(items, tuple):
        items = list(items)
    if not isinstance(items, list):
        items = [items]
    result = []
    for item in items:
        if not isinstance(item, str):
            continue
        value = item.strip()
        if value:
            result.append(value)
    return result


def default_skeptics(owner, supervisors, executors):
    supervisors = normalize_people(supervisors)
    executors = normalize_people(executors)

    fallback = [item for item in supervisors if item not in executors]
    owner = owner.strip() if isinstance(owner, str) else ""
    if owner and owner not in executors and owner not in fallback:
        fallback.insert(0, owner)
    if fallback:
        return fallback
    return executors[-1:] if executors else []


def default_product_anchors(owner, supervisors):
    anchors = normalize_people(supervisors)
    owner = owner.strip() if isinstance(owner, str) else ""
    if owner and owner not in anchors:
        anchors.insert(0, owner)
    return anchors or ([owner] if owner else [])


def default_quality_anchors(owner, supervisors, skeptics, executors):
    anchors = normalize_people(skeptics)
    if anchors:
        return anchors
    fallback = default_skeptics(owner, supervisors, executors)
    return normalize_people(fallback)


def product_gate_analysis(product, product_anchors=None, anchor_policy=None):
    product = product if isinstance(product, dict) else {}
    product_anchors = normalize_people(product_anchors)
    anchor_policy = anchor_policy if isinstance(anchor_policy, dict) else {}

    anchor = _clean_text(product.get("anchor", ""))
    goal = _clean_text(product.get("goal", ""))
    user_value = _clean_text(product.get("user_value", ""))
    non_goals = _clean_list(product.get("non_goals", []))
    acceptance = _clean_list(product.get("product_acceptance", []))
    drift_risk = _clean_text(product.get("drift_risk", ""))
    goal_status = _clean_text(product.get("goal_status", ""))
    goal_drift_flags = _clean_list(product.get("goal_drift_flags", []))
    last_product_review_at = _clean_text(product.get("last_product_review_at", ""))

    reasons = []
    if not product_anchors:
        reasons.append("product_anchor_unassigned")
    if not anchor:
        reasons.append("product_anchor_missing")
    elif product_anchors and anchor not in product_anchors:
        reasons.append("product_anchor_not_in_team")
    if not goal:
        reasons.append("product_goal_missing")
    if not user_value:
        reasons.append("product_user_value_missing")
    if not non_goals:
        reasons.append("product_non_goals_missing")
    if not acceptance:
        reasons.append("product_acceptance_missing")
    if not drift_risk:
        reasons.append("product_drift_risk_missing")
    if goal_status in {"", "missing", "drifted", "blocked", "unknown"}:
        reasons.append(f"product_goal_status_{goal_status or 'missing'}")
    if goal_drift_flags:
        reasons.append("product_goal_drift")
    if not last_product_review_at:
        reasons.append("product_review_missing")
    if not bool(anchor_policy.get("constant_anchor_seats", False)):
        reasons.append("constant_anchor_seats_disabled")

    return {
        "ready": not reasons,
        "reasons": reasons,
        "anchor": anchor,
        "goal": goal,
        "goal_status": goal_status,
        "user_value": user_value,
        "non_goal_count": len(non_goals),
        "product_acceptance_count": len(acceptance),
        "drift_risk": drift_risk,
        "last_product_review_at": last_product_review_at,
    }


def quality_anchor_analysis(quality, quality_anchors=None, anchor_policy=None):
    quality = quality if isinstance(quality, dict) else {}
    quality_anchors = normalize_people(quality_anchors)
    anchor_policy = anchor_policy if isinstance(anchor_policy, dict) else {}

    anchor = _clean_text(quality.get("anchor", ""))
    reasons = []
    if not quality_anchors:
        reasons.append("quality_anchor_unassigned")
    if not anchor:
        reasons.append("quality_anchor_missing")
    elif quality_anchors and anchor not in quality_anchors:
        reasons.append("quality_anchor_not_in_team")
    if not bool(anchor_policy.get("constant_anchor_seats", False)):
        reasons.append("constant_anchor_seats_disabled")

    return {
        "ready": not reasons,
        "reasons": reasons,
        "anchor": anchor,
    }


def quality_review_analysis(quality, quality_anchors=None, anchor_policy=None):
    quality = quality if isinstance(quality, dict) else {}
    anchor_status = quality_anchor_analysis(quality, quality_anchors, anchor_policy)
    review_status = _clean_text(quality.get("review_status", ""))
    last_review_at = _clean_text(quality.get("last_review_at", ""))
    findings = _clean_list(quality.get("review_findings", []))
    examples = _clean_list(quality.get("review_examples", []))

    reasons = list(anchor_status["reasons"])
    if review_status not in {"approved", "degraded-approved"}:
        reasons.append(f"quality_review_status_{review_status or 'missing'}")
    if not last_review_at:
        reasons.append("quality_review_timestamp_missing")

    return {
        "ready": not reasons,
        "reasons": reasons,
        "anchor": anchor_status["anchor"],
        "review_status": review_status,
        "last_review_at": last_review_at,
        "finding_count": len(findings),
        "example_count": len(examples),
    }


def analyze_role_integrity(supervisors, executors, skeptics):
    supervisors = normalize_people(supervisors)
    executors = normalize_people(executors)
    skeptics = normalize_people(skeptics)

    overlap = {
        "supervisor_executor_overlap": sorted(set(supervisors) & set(executors)),
        "supervisor_skeptic_overlap": sorted(set(supervisors) & set(skeptics)),
        "executor_skeptic_overlap": sorted(set(executors) & set(skeptics)),
    }

    role_conflicts = []
    for label, agents in overlap.items():
        for agent_id in agents:
            role_conflicts.append(f"{label}:{agent_id}")

    independent_skeptic = bool(skeptics) and not overlap["supervisor_skeptic_overlap"] and not overlap["executor_skeptic_overlap"]
    return {
        "independent_skeptic": independent_skeptic,
        "degraded": bool(role_conflicts),
        "role_conflicts": role_conflicts,
        "role_overlap": overlap,
    }


def scale_out_analysis(
    *,
    owner,
    supervisors,
    executors,
    skeptics,
    high_risk_mode=False,
    integration_pressure=False,
    verification_history=None,
):
    verification_history = list(verification_history or [])
    integrity = analyze_role_integrity(supervisors, executors, skeptics)
    triggers = []
    recent = verification_history[-2:]

    if len(normalize_people(executors)) >= 2:
        triggers.append("parallel_execution_slices")
    if len(recent) == 2 and not any(recent):
        triggers.append("repeated_verification_failures")
    if high_risk_mode:
        triggers.append("high_risk_mode")
    if integration_pressure:
        triggers.append("integration_pressure")

    normalized_supervisors = normalize_people(supervisors)
    normalized_executors = normalize_people(executors)
    owner = owner.strip() if isinstance(owner, str) else ""
    if owner and owner in normalized_executors and len(normalized_supervisors) == 1 and normalized_supervisors[0] == owner:
        triggers.append("lead_role_conflict")

    if not integrity["independent_skeptic"]:
        triggers.append("independent_skeptic_unavailable")
    if integrity["role_overlap"]["supervisor_skeptic_overlap"]:
        triggers.append("skeptic_supervisor_overlap")
    if integrity["role_overlap"]["executor_skeptic_overlap"]:
        triggers.append("skeptic_executor_overlap")
    if integrity["role_overlap"]["supervisor_executor_overlap"]:
        triggers.append("supervisor_executor_overlap")

    triggers = merge_triggers(triggers)
    return {
        "scale_out_recommended": bool(triggers),
        "scale_out_triggers": triggers,
        "role_integrity": integrity,
    }
