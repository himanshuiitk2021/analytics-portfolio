-- Grain: purchase month x customer state, delivered orders only.
select
    purchase_month,
    customer_state,
    count(*)                                   as delivered_orders,
    round(avg(is_late::int), 4)                as late_rate,
    round(avg(days_to_deliver), 1)             as avg_days_to_deliver,
    round(avg(days_vs_estimate), 1)            as avg_days_vs_estimate,
    round(avg(review_score), 2)                as avg_review_score
from {{ ref('fct_orders') }}
where is_delivered
group by 1, 2
