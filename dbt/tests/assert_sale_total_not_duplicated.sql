-- Total of the fact table must equal the sum of one price per eligible mutation.
with expected as (
    select sum(p) as total from (
        select id_mutation, max(sale_value_eur) as p
        from {{ ref('stg_dvf') }}
        where nature_mutation = 'Vente' and sale_value_eur > 0
        group by 1
    )
),
actual as (select sum(sale_value_eur) as total from {{ ref('fact_sale') }})
select * from expected, actual where expected.total <> actual.total
