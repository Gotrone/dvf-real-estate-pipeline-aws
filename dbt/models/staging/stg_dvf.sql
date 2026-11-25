-- One row per DVF line, typed. No business filtering here.
with src as (
    select * from read_parquet('{{ env_var("DVF_BRONZE_GLOB", "../data/bronze/**/*.parquet") }}', hive_partitioning = true)
)
select
    id_mutation,
    cast(date_mutation as date)                                as sale_date,
    nature_mutation,
    try_cast(nullif(valeur_fonciere, '') as double)            as sale_value_eur,
    code_commune                                               as commune_code,
    nom_commune                                                as commune_name,
    code_departement                                           as department_code,
    code_postal                                                as postal_code,
    id_parcelle                                                as parcel_id,
    type_local                                                 as local_type,
    try_cast(nullif(surface_reelle_bati, '') as double)        as built_area_m2,
    try_cast(nullif(nombre_pieces_principales, '') as integer) as rooms,
    try_cast(nullif(surface_terrain, '') as double)            as land_area_m2
from src
where id_mutation is not null
