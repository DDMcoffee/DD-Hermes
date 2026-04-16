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
