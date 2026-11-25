-- Grain: one row per sale (id_mutation).
-- DVF repeats the total price on every line of a mutation, so lines are aggregated first
-- to avoid double counting. Rules:
--   * only nature_mutation = 'Vente' with a positive price;
--   * built area = sum over Maison/Appartement units only (dependencies excluded);
--   * property type = the dwelling type with the largest built area, else 'Terrain / autre'.
--
-- Surfaces are repeated too. DVF can emit one line per cadastral land use ("nature de
-- culture") of a parcel, so the same dwelling appears once for each land use, and the same
-- land area appears once for each dwelling or lot on the parcel. Both are deduplicated
-- (separately) before summing. This is a heuristic: DVF has no unique dwelling identifier.
with lines as (
    select * from {{ ref('stg_dvf') }}
    where nature_mutation = 'Vente' and sale_value_eur > 0
),

-- Dwellings. Count identical lines inside each land use, then keep the largest count:
-- repeats across land uses collapse, while identical units listed several times within one
-- land use (for example two similar houses without lot numbers) are all kept.
dwelling_per_land_use as (
    select
        id_mutation, parcel_id, disposition_number, local_type, built_area_m2, rooms,
        address_number, address_suffix, street_code, volume_number,
        lot1_number, lot2_number, lot3_number, lot4_number, lot5_number,
        commune_code,
        land_use_code, special_land_use_code, land_area_m2,
        count(*) as copies
    from lines
    where local_type in ('Maison', 'Appartement')
    group by all
),
dwellings as (
    select
        id_mutation, parcel_id, disposition_number, local_type, built_area_m2, rooms,
        address_number, address_suffix, street_code, volume_number,
        lot1_number, lot2_number, lot3_number, lot4_number, lot5_number,
        commune_code,
        max(copies) as units
    from dwelling_per_land_use
    group by all
),

-- Land. One area per (parcel, disposition, land use, area). Two sub-parcels sharing all
-- of these values would be merged.
land_parts as (
    select distinct
        id_mutation, parcel_id, disposition_number,
        land_use_code, special_land_use_code, land_area_m2
    from lines
    where land_area_m2 is not null
),
land as (
    select id_mutation, sum(land_area_m2) as land_area_m2
    from land_parts
    group by 1
),

dwelling_area_by_type as (
    select id_mutation, local_type, sum(built_area_m2 * units) as area
    from dwellings
    group by 1, 2
),
main_type as (
    select id_mutation, local_type as property_type_key
    from dwelling_area_by_type
    where area is not null
    qualify row_number() over (partition by id_mutation order by area desc, local_type) = 1
),
dwelling_totals as (
    select id_mutation, sum(built_area_m2 * units) as built_area_m2, sum(units) as dwelling_units
    from dwellings
    group by 1
),

-- A sale can span several communes: keep the one with the largest dwelling built area,
-- ties (including sales without any dwelling) broken by the lowest commune code.
dwelling_area_by_commune as (
    select id_mutation, commune_code, sum(built_area_m2 * units) as area
    from dwellings
    group by 1, 2
),
main_commune as (
    select l.id_mutation, l.commune_code
    from (select distinct id_mutation, commune_code from lines) l
    left join dwelling_area_by_commune d
        on d.id_mutation = l.id_mutation and d.commune_code = l.commune_code
    qualify row_number() over (
        partition by l.id_mutation order by coalesce(d.area, 0) desc, l.commune_code
    ) = 1
),

agg as (
    select
        id_mutation,
        min(sale_date)                 as sale_date,
        max(sale_value_eur)            as sale_value_eur,
        count(distinct commune_code) > 1 as is_multi_commune,
        -- mixed use: at least one dwelling and one commercial or industrial unit
        bool_or(coalesce(local_type in ('Maison', 'Appartement'), false))
            and bool_or(coalesce(local_type = 'Local industriel. commercial ou assimilé', false))
                                       as is_mixed_use
    from lines
    group by 1
),
sales as (
    select
        a.id_mutation                                              as sale_id,
        cast(strftime(a.sale_date, '%Y%m%d') as integer)           as date_key,
        c.commune_code,
        coalesce(m.property_type_key, 'Terrain / autre')           as property_type_key,
        a.sale_value_eur,
        t.built_area_m2,
        coalesce(t.dwelling_units, 0)                              as dwelling_units,
        l.land_area_m2,
        case when t.built_area_m2 > 0 then a.sale_value_eur / t.built_area_m2 end as price_per_m2,
        a.is_mixed_use,
        a.is_multi_commune
    from agg a
    left join main_commune c on c.id_mutation = a.id_mutation
    left join main_type m on m.id_mutation = a.id_mutation
    left join dwelling_totals t on t.id_mutation = a.id_mutation
    left join land l on l.id_mutation = a.id_mutation
)
select
    *,
    -- Outlier thresholds (judgement calls, not validated against an external reference):
    -- price per m2 below 300 or above 30000 EUR, or dwelling built area under 9 m2.
    coalesce(price_per_m2 < 300 or price_per_m2 > 30000, false)
        or coalesce(built_area_m2 < 9, false)                      as is_price_outlier
from sales
