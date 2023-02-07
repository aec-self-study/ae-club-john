with orders as (
    select * from {{ source('coffee_shop', 'orders') }}
)

select * from orders