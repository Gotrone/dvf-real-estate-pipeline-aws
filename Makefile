.PHONY: install lint test dbt-build sample
install:
	pip install -e ".[dev]"
lint:
	ruff check src tests
test:
	pytest -q
# Build the bronze layer from the tiny synthetic fixture, then run dbt on it.
sample:
	dvf bronze --input tests/fixtures/dvf_sample_synthetic.csv --out data/bronze --year 2024 --department 34
dbt-build: sample
	cd dbt && DVF_BRONZE_GLOB="../data/bronze/**/*.parquet" dbt build --profiles-dir .
