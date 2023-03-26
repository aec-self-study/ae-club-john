{{ config(materialized='table') }}

select
    session_id,
    customer_id,
    visitor_id,
    device_type,
    count(distinct page) as count_of_pages_visited,
    min(timestamp) as session_start_time,
    max(timestamp) as session_end_time,
    datetime_diff(max(timestamp), min(timestamp), second) as session_length_in_seconds,
    array_agg(page order by timestamp)[safe_offset(0)] as first_page_visited,
    array_reverse(array_agg(page order by timestamp))[safe_offset(0)] as last_page_visited,
    --having a last page visited = 'order-confirmation' means that the session ended in a purchase
    --this may not be the case, as the other pages may be visited after the 'order-confirmation' page in a given session 
    case
        when array_reverse(array_agg(page order by timestamp))[safe_offset(0)] = 'order-confirmation'
        then true
        else false
    end as session_ended_in_purchase
from {{ ref('web_tracking_pageviews') }}
where customer_id is not null --visitor_id and session_id values are only applicable to those who have customer_id records
group by 1, 2, 3, 4