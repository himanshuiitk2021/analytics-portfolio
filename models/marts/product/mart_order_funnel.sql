-- Grain: one row per purchase month. How many orders reach each lifecycle stage, and how long each hop takes.
select
    purchase_month,
    count(*)                                                        as orders_placed,
    count(approved_at)                                              as orders_approved,
    count(shipped_at)                                               as orders_shipped,
    count(delivered_at)                                             as orders_delivered,
    count(review_score)                                             as orders_reviewed,
    round(count(delivered_at) / count(*), 4)                        as placed_to_delivered_rate,
    median(date_diff('hour', purchased_at, approved_at))            as median_hours_to_approve,
    median(date_diff('hour', approved_at, shipped_at))              as median_hours_approve_to_ship,
    median(date_diff('hour', shipped_at, delivered_at))             as median_hours_ship_to_deliver
from {{ ref('fct_orders') }}
group by 1
