select distinct
    commune_code,
    commune_name,
    department_code
from {{ ref('stg_dvf') }}
where commune_code is not null
