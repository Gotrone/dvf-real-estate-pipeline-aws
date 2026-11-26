from pathlib import Path

import duckdb

from dvf_pipeline.bronze import csv_to_bronze
from dvf_pipeline.download import build_url

FIXTURE = Path(__file__).parent / "fixtures" / "dvf_sample_synthetic.csv"


def test_build_url():
    assert build_url(2024, "34").endswith("/2024/departements/34.csv.gz")


def test_bronze_is_partitioned_and_complete(tmp_path):
    out = csv_to_bronze(FIXTURE, tmp_path, 2024, "34")
    assert out.parent.as_posix().endswith("year=2024/department=34")
    n = duckdb.sql(f"select count(*) from read_parquet('{out}')").fetchall()[0][0]
    assert n == 21  # 21 data lines in the fixture


def test_bronze_keeps_all_columns_as_text(tmp_path):
    out = csv_to_bronze(FIXTURE, tmp_path, 2024, "34")
    types = {r[0]: r[1] for r in duckdb.sql(f"describe select * from read_parquet('{out}', hive_partitioning=false)").fetchall()}
    assert set(types.values()) == {"VARCHAR"}
    assert "valeur_fonciere" in types
