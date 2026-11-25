"""Bronze layer: raw DVF CSV -> Parquet, partitioned like the future S3 layout.

Layout: <out>/year=<YYYY>/department=<DD>/part.parquet  (Hive-style, Athena/Glue friendly).
All columns are kept as strings: typing happens in dbt staging, not at ingestion.
"""
from __future__ import annotations

from pathlib import Path

import duckdb


def csv_to_bronze(src: Path, out_root: Path, year: int, department: str) -> Path:
    part_dir = out_root / f"year={year}" / f"department={department}"
    part_dir.mkdir(parents=True, exist_ok=True)
    target = part_dir / "part.parquet"
    con = duckdb.connect()
    try:
        con.execute(
            "COPY (SELECT * FROM read_csv(?, header=true, all_varchar=true)) "
            "TO ? (FORMAT PARQUET, COMPRESSION ZSTD)",
            [str(src), str(target)],
        )
    finally:
        con.close()
    return target
