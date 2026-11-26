-- External table over the bronze Parquet files. Source columns are kept as text.
-- Replace <lake-bucket> with the Terraform output lake_bucket.
-- Run each statement separately, in the workgroup and database created by Terraform.
CREATE EXTERNAL TABLE dvf_bronze (
  id_mutation string,
  date_mutation string,
  numero_disposition string,
  nature_mutation string,
  valeur_fonciere string,
  adresse_numero string,
  adresse_suffixe string,
  adresse_nom_voie string,
  adresse_code_voie string,
  code_postal string,
  code_commune string,
  nom_commune string,
  code_departement string,
  ancien_code_commune string,
  ancien_nom_commune string,
  id_parcelle string,
  ancien_id_parcelle string,
  numero_volume string,
  lot1_numero string,
  lot1_surface_carrez string,
  lot2_numero string,
  lot2_surface_carrez string,
  lot3_numero string,
  lot3_surface_carrez string,
  lot4_numero string,
  lot4_surface_carrez string,
  lot5_numero string,
  lot5_surface_carrez string,
  nombre_lots string,
  code_type_local string,
  type_local string,
  surface_reelle_bati string,
  nombre_pieces_principales string,
  code_nature_culture string,
  nature_culture string,
  code_nature_culture_speciale string,
  nature_culture_speciale string,
  surface_terrain string,
  longitude string,
  latitude string
)
PARTITIONED BY (year int, department string)
STORED AS PARQUET
LOCATION 's3://<lake-bucket>/bronze/';

MSCK REPAIR TABLE dvf_bronze;
