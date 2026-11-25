# ADR 0001: dataset and stack

**Dataset: DVF (Demandes de valeurs foncières).** Real, public (Etalab open licence), updated
twice a year, tens of millions of lines nationwide. Chosen because the grain problem
(price repeated on every line of a sale) forces real modelling decisions, the star schema is
natural (sale / date / commune / property type), and the volume justifies Parquet and
partitioning while a single department fits on a laptop.

**Alternative considered:** French electricity grid open data (RTE eco2mix). Cleaner time
series, but modelling is trivial (one wide table), so it exercises star-schema design less.

**Stack:** S3 + Glue Data Catalog + Athena, dbt, Terraform, GitHub Actions; Airflow later.
Spark is deliberately left out of the first milestones. DuckDB runs the same Parquet locally
so every milestone is testable without an AWS account.

**Cost rule:** nothing is deployed without an explicit decision; Athena has a per-query scan
cap and the account has a budget alert (see `terraform/`).
