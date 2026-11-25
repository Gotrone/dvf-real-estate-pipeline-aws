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
| dbt star schema on DuckDB | Done on a synthetic fixture (Milestone 1) |
| CI (lint, tests, dbt, terraform validate) | Done (Milestone 1) |
| Terraform for S3 / Glue / Athena / budget | Written, **not applied** |
| Glue Crawler / catalog, Athena queries | Planned (Milestone 3) |
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
        double sale_value_eur
        double built_area_m2
        double land_area_m2
        double price_per_m2
    }
```

Grain of `fact_sale`: one row per sale (`id_mutation`). DVF repeats the total price on every
line of a sale, so lines are aggregated first. A naive sum over lines would multiply the
price by the number of lines; a dbt test (`assert_sale_total_not_duplicated`) guards that.
