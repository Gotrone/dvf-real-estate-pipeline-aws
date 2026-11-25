select * from {{ ref('fact_sale') }} where price_per_m2 is not null and price_per_m2 <= 0
