{{ config(materialized='table') }}

select
    session_id,
    customer_id,
    visitor_id,
    count(distinct id) as count_of_sessions,
    min(timestamp) as session_start_time,
    max(timestamp) as session_end_time
from {{ ref('web_tracking_pageviews') }}
group by 1, 2, 3
