"""Download DVF department files published on data.gouv.fr (open licence, Etalab)."""
from __future__ import annotations

from pathlib import Path

import requests

BASE_URL = "https://files.data.gouv.fr/geo-dvf/latest/csv/{year}/departements/{department}.csv.gz"


def build_url(year: int, department: str) -> str:
    return BASE_URL.format(year=year, department=department)


def download(year: int, department: str, dest_dir: Path) -> Path:
    """Stream one department-year file to `dest_dir` and return its path."""
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest = dest_dir / f"dvf_{year}_{department}.csv.gz"
    with requests.get(build_url(year, department), stream=True, timeout=60) as resp:
        resp.raise_for_status()
        with dest.open("wb") as fh:
            for chunk in resp.iter_content(chunk_size=1 << 20):
                fh.write(chunk)
    return dest
