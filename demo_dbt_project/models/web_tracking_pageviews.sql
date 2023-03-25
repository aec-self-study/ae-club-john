{{ config(materialized='table') }}

with first_visitor_per_customer as (
select
    * except (visitor_id),
    --the first known visitor ID associated with this customer (if not null)
    case
        when customer_id is not null
        then first_value(visitor_id) over (partition by customer_id order by timestamp)
        else null
    end as visitor_id
from {{ source('web_tracking', 'pageviews') }}
),

define_new_sessions as (
select
    *,
    --identify where there's a gap in the 'sessions' > 30 mins for a given customer_id (not not null)
    case
        when customer_id is not null
        then    cast(
                datetime_diff
                (
                    timestamp,
                    coalesce(lag(timestamp) over (partition by customer_id order by timestamp), timestamp),
                    minute
                ) > 30
                as int64)
        else null end as is_new_session
from first_visitor_per_customer
),

group_sessions as (
    --Using a running SUM, we give unique INT values to each session for a given customer_id (if not null)
select
    *,
    sum(is_new_session) over (partition by customer_id order by timestamp) as running_sum_session_id
from define_new_sessions
)

select
    --hash the session ID
    * except(is_new_session, running_sum_session_id),
    to_base64(md5(concat(customer_id, running_sum_session_id))) as session_id
from group_sessions