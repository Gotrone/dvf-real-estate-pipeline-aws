-- Reconciliation between Athena (bronze) and the local DuckDB run, Herault 2024.
-- Run each statement separately. The expected values hold for the source file as downloaded
-- in November 2026; they can change when the source is republished.

-- Expected: 69651 lines, 29565 mutations.
SELECT count(*) AS raw_lines, count(DISTINCT id_mutation) AS mutations
FROM dvf_bronze
WHERE year = 2024 AND department = '34';

-- Expected: 60775 lines, 26652 sales (the row count of fact_sale in the local run).
SELECT count(*) AS eligible_lines, count(DISTINCT id_mutation) AS sales
FROM dvf_bronze
WHERE year = 2024 AND department = '34'
  AND nature_mutation = 'Vente'
  AND try_cast(valeur_fonciere AS decimal(14, 2)) > 0;
