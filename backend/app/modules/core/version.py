"""Version utility module.

Provides centralized version reading from pyproject.toml.
"""

import re
import logging
from pathlib import Path

logger = logging.getLogger(__name__)


def get_version() -> str:
    """Read version from pyproject.toml.

    Returns:
        Version string (e.g., "0.1.0").

    Raises:
        FileNotFoundError: If pyproject.toml not found.
        ValueError: If version field not found.
    """
    pyproject_path = Path(__file__).parent.parent.parent.parent / "pyproject.toml"

    if not pyproject_path.exists():
        logger.warning("pyproject.toml not found at %s", pyproject_path)
        return "0.0.0"

    content = pyproject_path.read_text(encoding="utf-8")

    # Match version = "x.y.z" or version = 'x.y.z'
    match = re.search(r'^version\s*=\s*["\']([^"\']+)["\']', content, re.MULTILINE)

    if not match:
        logger.warning("version field not found in pyproject.toml")
        return "0.0.0"

    return match.group(1)


__all__ = ["get_version"]