-- Expected values for the synthetic fixture (ids 'T-...'). On any other dataset no such id
-- exists and the test returns no row.
with expected (sale_id, built_area_m2, land_area_m2, commune_code, is_mixed_use, is_multi_commune, is_price_outlier) as (
    values
        ('T-1',  50,   null, '34032', false, false, false),
        ('T-2',  100,  400,  '34172', false, false, false),
        ('T-3',  null, 600,  '34032', false, false, false),
        ('T-6',  100,  null, '34032', false, false, false),
        -- one house repeated under two land uses
        ('T-7',  140,  1504, '34032', false, false, false),
        -- two identical houses, each repeated under two land uses
        ('T-8',  140,  1000, '34172', false, false, false),
        ('T-9',  130,  null, '34172', false, true,  false),
        ('T-10', 50,   null, '34172', true,  false, false),
        ('T-11', 100,  null, '34032', false, false, true)
)
select e.sale_id, f.built_area_m2, f.land_area_m2, f.commune_code
from expected e
left join {{ ref('fact_sale') }} f on f.sale_id = e.sale_id
where exists (select 1 from {{ ref('fact_sale') }} where sale_id like 'T-%')
  and (
      f.sale_id is null
      or f.built_area_m2 is distinct from e.built_area_m2
      or f.land_area_m2 is distinct from e.land_area_m2
      or f.commune_code is distinct from e.commune_code
      or f.is_mixed_use is distinct from e.is_mixed_use
      or f.is_multi_commune is distinct from e.is_multi_commune
      or f.is_price_outlier is distinct from e.is_price_outlier
  )
