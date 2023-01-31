select
    customers.id as customer_id,
    customers.name as customer_name,
    customers.email,
    min(orders.created_at) as first_order_at,
    count(distinct orders.id) as number_of_orders
from `analytics-engineers-club.coffee_shop.customers` as customers
inner join `analytics-engineers-club.coffee_shop.orders` as orders on customers.id = orders.customer_id
group by 1, 2, 3
order by first_order_at
limit 5
