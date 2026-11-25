-- Grain: one row per sale (id_mutation).
-- DVF repeats the total price on every line of a mutation, so lines are aggregated first
-- to avoid double counting. Rules:
--   * only nature_mutation = 'Vente' with a positive price;
--   * built area = sum over Maison/Appartement lines only (dependencies excluded);
--   * property type = the dwelling type with the largest built area, else 'Terrain / autre'.
with lines as (
    select * from {{ ref('stg_dvf') }}
    where nature_mutation = 'Vente' and sale_value_eur > 0
),
dwelling_area as (
    select id_mutation, local_type, sum(built_area_m2) as area
    from lines
    where local_type in ('Maison', 'Appartement')
    group by 1, 2
),
main_type as (
    select id_mutation, arg_max(local_type, area) as property_type_key
    from dwelling_area
    group by 1
),
agg as (
    select
        id_mutation,
        min(sale_date)                                                          as sale_date,
        min(commune_code)                                                       as commune_code,
        max(sale_value_eur)                                                     as sale_value_eur,
        sum(case when local_type in ('Maison','Appartement') then built_area_m2 end) as built_area_m2,
        sum(case when local_type in ('Maison','Appartement') then 1 else 0 end) as dwelling_lines,
        sum(land_area_m2)                                                       as land_area_m2
    from lines
    group by 1
)
select
    a.id_mutation                                              as sale_id,
    cast(strftime(a.sale_date, '%Y%m%d') as integer)           as date_key,
    a.commune_code,
    coalesce(m.property_type_key, 'Terrain / autre')           as property_type_key,
    a.sale_value_eur,
    a.built_area_m2,
    a.land_area_m2,
    case when a.built_area_m2 > 0 then a.sale_value_eur / a.built_area_m2 end as price_per_m2
from agg a
left join main_type m using (id_mutation)
