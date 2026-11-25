select distinct
    cast(strftime(sale_date, '%Y%m%d') as integer) as date_key,
    sale_date                                      as date_day,
    year(sale_date)                                as year,
    quarter(sale_date)                             as quarter,
    month(sale_date)                               as month
from {{ ref('stg_dvf') }}
where sale_date is not null
