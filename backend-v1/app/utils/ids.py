"""
ID generation utilities.
"""
from ulid import ULID


def generate_id() -> str:
    """
    Generate a unique, sortable ID using ULID.

    Returns:
        String representation of ULID
    """
    return str(ULID())


def generate_prefixed_id(prefix: str) -> str:
    """
    Generate an ID with a prefix.

    Args:
        prefix: Prefix for the ID (e.g., "user", "report")

    Returns:
        Prefixed ID string
    """
    return f"{prefix}_{ULID()}"


def is_valid_ulid(value: str) -> bool:
    """
    Check if a string is a valid ULID.

    Args:
        value: String to check

    Returns:
        True if valid ULID, False otherwise
    """
    try:
        # Remove prefix if present
        if "_" in value:
            value = value.split("_", 1)[1]
        ULID.from_str(value)
        return True
    except (ValueError, AttributeError):
        return False