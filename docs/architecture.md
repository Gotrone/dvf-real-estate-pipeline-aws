# Architecture

```mermaid
flowchart LR
    A[data.gouv.fr<br/>DVF open data CSV] -->|download| B[(S3 raw<br/>csv.gz)]
    B -->|convert, partition| C[(S3 bronze<br/>Parquet year/department)]
    C -->|Glue Data Catalog| D[Athena]
    D -->|dbt models| E[(S3 gold<br/>star schema)]
    E --> F[Athena queries / BI]
    G[Airflow] -. orchestrates .-> B
    G -.-> C
    G -.-> D
    H[GitHub Actions] -. lint, tests, dbt build, terraform validate .-> I[Terraform]
```

## Status of each box

| Component | Status |
|---|---|
| Download + CSV -> Parquet (bronze), local | Done (Milestone 1) |
| dbt star schema on DuckDB | Done; run on real data for one department-year (Milestone 2) |
| CI (lint, tests, dbt, terraform validate) | Done (Milestone 1) |
| Terraform for S3 / Glue / Athena / budget | Applied in `eu-north-1` (Milestone 3) |
| Bronze on S3, Glue catalog table, Athena queries | Done by hand for one department-year, no crawler (Milestone 3) |
| S3 raw upload | Not written yet |
| dbt on Athena | Planned (Milestone 4) |
| Airflow orchestration | Planned (Milestone 5) |

## Star schema

```mermaid
erDiagram
    fact_sale }o--|| dim_date : date_key
    fact_sale }o--|| dim_commune : commune_code
    fact_sale }o--|| dim_property_type : property_type_key
    fact_sale {
        string sale_id PK
        int date_key FK
        string commune_code FK
        string property_type_key FK
        decimal sale_value_eur
        double built_area_m2
        int dwelling_units
        double land_area_m2
        double price_per_m2
        boolean is_mixed_use
        boolean is_multi_commune
        boolean is_price_outlier
    }
```

Grain of `fact_sale`: one row per sale (`id_mutation`). DVF repeats the total price on every
line of a sale, so lines are aggregated first. A naive sum over lines would multiply the
price by the number of lines; a dbt test (`assert_sale_total_not_duplicated`) guards that.
