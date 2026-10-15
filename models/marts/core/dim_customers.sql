-- Grain: one row per real customer (customer_unique_id).
with orders as (
    select * from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
)

select
    customer_unique_id,
    arg_min(customer_state, purchased_at)          as first_state,
    min(purchased_at)                              as first_order_at,
    max(purchased_at)                              as last_order_at,
    date_trunc('month', min(purchased_at))::date   as cohort_month,
    count(*)                                       as lifetime_orders,
    sum(gmv)                                       as lifetime_gmv,
    count(*) > 1                                   as is_repeat_customer,
    arg_min(review_score, purchased_at)            as first_order_review_score,
    arg_min(is_late, purchased_at)                 as first_order_was_late
from orders
group by 1
