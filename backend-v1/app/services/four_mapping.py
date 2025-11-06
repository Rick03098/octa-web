"""Utility helpers for retrieving the four-sentence mapping for a BaZi day pillar.

This module reads from ``bazi_four_sentences_mapping.json`` and exposes a simple
function that frontend code can call to fetch the narrative components for a
given日柱 (day pillar) and身强/身弱 classification.
"""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path
from typing import Dict

_DATA_FILE = Path(__file__).with_name("bazi_four_sentences_mapping.json")


@lru_cache(maxsize=1)
def _load_mapping() -> Dict[str, Dict[str, dict]]:
    """Load the JSON mapping from disk once."""
    try:
        with _DATA_FILE.open(encoding="utf-8") as fp:
            payload = json.load(fp)
    except FileNotFoundError as exc:
        raise RuntimeError(f"Mapping file not found: {_DATA_FILE}") from exc
    except json.JSONDecodeError as exc:
        raise RuntimeError(f"Mapping file is not valid JSON: {_DATA_FILE}") from exc

    mapping = payload.get("mapping")
    if not isinstance(mapping, dict):
        raise RuntimeError("Mapping file missing 'mapping' object")
    return mapping


def get_four_sentences(day_pillar: str, strength: str) -> Dict[str, str]:
    """Return the four narrative sentences for the given day pillar and strength.

    Args:
        day_pillar: The user's日柱, e.g. ``"甲子"``.
        strength: Either ``"身强"`` or ``"身弱"``, matched exactly.

    Returns:
        A dictionary with keys ``纳音``, ``舒适区``, ``能量来源``, ``相冲能量``.

    Raises:
        ValueError: If inputs are empty.
        KeyError: If the combination is not defined in the mapping file.
        RuntimeError: If the mapping file cannot be loaded.
    """

    if not day_pillar or not strength:
        raise ValueError("day_pillar and strength must both be provided")

    mapping = _load_mapping()
    pillar_entry = mapping.get(day_pillar)
    if pillar_entry is None:
        raise KeyError(f"Unsupported day pillar: {day_pillar}")

    strength_entry = pillar_entry.get(strength)
    if strength_entry is None:
        raise KeyError(f"Unsupported strength '{strength}' for day pillar '{day_pillar}'")

    components = strength_entry.get("components")
    if not isinstance(components, dict):
        raise KeyError(f"No components defined for {day_pillar} / {strength}")

    # Return a shallow copy so callers can't mutate our cached data.
    return dict(components)


__all__ = ["get_four_sentences"]
