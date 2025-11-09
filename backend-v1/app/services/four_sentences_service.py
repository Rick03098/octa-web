"""Helpers for generating BaZi four-sentence narratives."""
from __future__ import annotations

from typing import Dict, Tuple

from app.models.profiles import BaziChart
from app.services.bazi_service import GAN_TO_ELEMENT
from app.services.four_mapping import get_four_sentences

# Branch hidden stems with weights
BRANCH_HIDDEN = {
    "子": [("癸", 1.0)],
    "丑": [("己", 0.6), ("癸", 0.2), ("辛", 0.2)],
    "寅": [("甲", 0.7), ("丙", 0.2), ("戊", 0.1)],
    "卯": [("乙", 1.0)],
    "辰": [("戊", 0.6), ("乙", 0.2), ("癸", 0.2)],
    "巳": [("丙", 0.7), ("戊", 0.2), ("庚", 0.1)],
    "午": [("丁", 0.7), ("己", 0.3)],
    "未": [("己", 0.6), ("丁", 0.2), ("乙", 0.2)],
    "申": [("庚", 0.7), ("壬", 0.2), ("戊", 0.1)],
    "酉": [("辛", 1.0)],
    "戌": [("戊", 0.6), ("辛", 0.2), ("丁", 0.2)],
    "亥": [("壬", 0.7), ("甲", 0.3)],
}

# Seasonal strength modifiers (month branch -> element strength)
SEASONAL_STRENGTH = {
    "寅": {"wood": 1.0, "fire": 0.7, "water": 0.4, "metal": 0.2, "earth": 0.3},
    "卯": {"wood": 1.0, "fire": 0.7, "water": 0.4, "metal": 0.2, "earth": 0.3},
    "巳": {"fire": 1.0, "earth": 0.7, "wood": 0.3, "metal": 0.3, "water": 0.2},
    "午": {"fire": 1.0, "earth": 0.7, "wood": 0.3, "metal": 0.3, "water": 0.2},
    "申": {"metal": 1.0, "water": 0.7, "earth": 0.4, "fire": 0.3, "wood": 0.2},
    "酉": {"metal": 1.0, "water": 0.7, "earth": 0.4, "fire": 0.3, "wood": 0.2},
    "亥": {"water": 1.0, "wood": 0.7, "metal": 0.3, "earth": 0.3, "fire": 0.2},
    "子": {"water": 1.0, "wood": 0.7, "metal": 0.3, "earth": 0.3, "fire": 0.2},
    "辰": {"earth": 1.0, "metal": 0.7, "fire": 0.5, "wood": 0.4, "water": 0.3},
    "戌": {"earth": 1.0, "metal": 0.7, "fire": 0.5, "wood": 0.4, "water": 0.3},
    "丑": {"earth": 1.0, "metal": 0.7, "water": 0.5, "wood": 0.3, "fire": 0.3},
    "未": {"earth": 1.0, "fire": 0.7, "wood": 0.5, "metal": 0.3, "water": 0.3},
}

ELEM_CYCLE = {
    "wood": {"gen": "water", "leak": "fire", "controls": "earth", "beaten_by": "metal"},
    "fire": {"gen": "wood", "leak": "earth", "controls": "metal", "beaten_by": "water"},
    "earth": {"gen": "fire", "leak": "metal", "controls": "water", "beaten_by": "wood"},
    "metal": {"gen": "earth", "leak": "water", "controls": "wood", "beaten_by": "fire"},
    "water": {"gen": "metal", "leak": "wood", "controls": "fire", "beaten_by": "earth"},
}


def determine_day_master_strength(chart: BaziChart) -> Tuple[str, float]:
    """Return (label, score) for the日主强弱判定."""
    day_gan = chart.day_pillar.heavenly_stem
    year_gan = chart.year_pillar.heavenly_stem
    year_zhi = chart.year_pillar.earthly_branch
    month_gan = chart.month_pillar.heavenly_stem
    month_zhi = chart.month_pillar.earthly_branch
    day_zhi = chart.day_pillar.earthly_branch
    hour_gan = chart.hour_pillar.heavenly_stem or None
    hour_zhi = chart.hour_pillar.earthly_branch or None

    dm_elem = GAN_TO_ELEMENT.get(day_gan)
    if dm_elem is None:
        raise ValueError(f"Unsupported day master heavenly stem: {day_gan}")

    cycle = ELEM_CYCLE[dm_elem]
    season = SEASONAL_STRENGTH.get(month_zhi, {})
    season_score = (season.get(dm_elem, 0.4) * 3.0)

    def hidden_score(zhi: str, pos_weight: float) -> float:
        entries = BRANCH_HIDDEN.get(zhi, [])
        score = 0.0
        for gan, weight in entries:
            elem = GAN_TO_ELEMENT.get(gan)
            if elem == dm_elem:
                score += 1.0 * weight * pos_weight
            elif elem == cycle["gen"]:
                score += 0.8 * weight * pos_weight
        return score

    root_score = 0.0
    root_score += hidden_score(day_zhi, 2.0)
    root_score += hidden_score(month_zhi, 1.5)
    root_score += hidden_score(year_zhi, 1.0)
    if hour_zhi:
        root_score += hidden_score(hour_zhi, 1.0)

    def stem_effect(gan: str | None, pos_weight: float) -> float:
        if not gan:
            return 0.0
        elem = GAN_TO_ELEMENT.get(gan)
        if elem == dm_elem:
            return 1.0 * pos_weight
        if elem == cycle["gen"]:
            return 0.8 * pos_weight
        if elem == cycle["leak"]:
            return -0.7 * pos_weight
        if elem == cycle["controls"]:
            return -0.9 * pos_weight
        if elem == cycle["beaten_by"]:
            return -1.1 * pos_weight
        return 0.0

    help_penalty = 0.0
    help_penalty += stem_effect(month_gan, 1.5)
    help_penalty += stem_effect(day_gan, 1.2)
    help_penalty += stem_effect(year_gan, 1.0)
    help_penalty += stem_effect(hour_gan, 1.0)

    raw = season_score + root_score + help_penalty
    score = max(0.0, min(100.0, 50.0 + raw * 6.0))
    label = "身强" if score >= 55.0 else "身弱"
    return label, round(score, 1)


def build_four_sentences(chart: BaziChart) -> Tuple[str, str, Dict[str, str]]:
    """Generate day pillar, strength label and four-sentence content."""
    day_pillar = f"{chart.day_pillar.heavenly_stem}{chart.day_pillar.earthly_branch}"
    label, _ = determine_day_master_strength(chart)
    sentences = get_four_sentences(day_pillar, label)
    return day_pillar, label, sentences


__all__ = ["determine_day_master_strength", "build_four_sentences"]
