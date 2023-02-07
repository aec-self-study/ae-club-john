{{ config(materialized='table') }}

select
    customer_id,
    case
        when email like '%ab%'
        then true
        --else false
    end as has_ab
from {{ ref('customers') }}
