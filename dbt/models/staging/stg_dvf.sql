-- One row per DVF line, typed. No business filtering here.
with src as (
    select * from read_parquet('{{ env_var("DVF_BRONZE_GLOB", "../data/bronze/**/*.parquet") }}', hive_partitioning = true)
)
select
    id_mutation,
    cast(date_mutation as date)                                as sale_date,
    numero_disposition                                         as disposition_number,
    nature_mutation,
    -- decimal, not double: real prices have cents and sums must be exact
    try_cast(nullif(valeur_fonciere, '') as decimal(14, 2))    as sale_value_eur,
    adresse_numero                                             as address_number,
    adresse_suffixe                                            as address_suffix,
    adresse_code_voie                                          as street_code,
    code_commune                                               as commune_code,
    nom_commune                                                as commune_name,
    code_departement                                           as department_code,
    code_postal                                                as postal_code,
    id_parcelle                                                as parcel_id,
    numero_volume                                              as volume_number,
    lot1_numero                                                as lot1_number,
    lot2_numero                                                as lot2_number,
    lot3_numero                                                as lot3_number,
    lot4_numero                                                as lot4_number,
    lot5_numero                                                as lot5_number,
    type_local                                                 as local_type,
    try_cast(nullif(surface_reelle_bati, '') as double)        as built_area_m2,
    try_cast(nullif(nombre_pieces_principales, '') as integer) as rooms,
    code_nature_culture                                        as land_use_code,
    code_nature_culture_speciale                               as special_land_use_code,
    try_cast(nullif(surface_terrain, '') as double)            as land_area_m2
from src
where id_mutation is not null
