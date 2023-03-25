select
    customer_id,
    count(distinct visitor_id) as count_unique_visitors
from {{ ref('web_tracking_pageviews' )}}
group by 1
having (count_unique_visitors > 1)