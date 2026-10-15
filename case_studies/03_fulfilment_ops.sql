-- name: Order lifecycle funnel (all months)
select
    sum(orders_placed)                                              as placed,
    sum(orders_approved)                                            as approved,
    sum(orders_shipped)                                             as shipped,
    sum(orders_delivered)                                           as delivered,
    sum(orders_reviewed)                                            as reviewed,
    round(sum(orders_delivered) * 100.0 / sum(orders_placed), 2)    as placed_to_delivered_pct
from main.mart_order_funnel;

-- name: Where the delivery time goes (median hours per hop, delivered orders)
select
    median(date_diff('hour', purchased_at, approved_at))  as purchase_to_approve_h,
    median(date_diff('hour', approved_at, shipped_at))    as approve_to_carrier_h,
    median(date_diff('hour', shipped_at, delivered_at))   as carrier_to_customer_h,
    median(date_diff('hour', purchased_at, delivered_at)) as total_h
from main.fct_orders
where is_delivered and approved_at is not null and shipped_at is not null;

-- name: Late-delivery rate by month
select
    strftime(purchase_month, '%Y-%m')                  as month,
    sum(delivered_orders)                              as delivered,
    round(sum(late_rate * delivered_orders) * 100.0 / sum(delivered_orders), 1) as late_pct,
    round(sum(avg_review_score * delivered_orders) / sum(delivered_orders), 2)  as avg_review
from main.mart_delivery_performance
where purchase_month between date '2017-01-01' and date '2018-08-01'
group by purchase_month
order by purchase_month;

-- name: States with the worst late rates (500+ delivered orders)
select
    customer_state                                    as state,
    sum(delivered_orders)                             as delivered,
    round(sum(late_rate * delivered_orders) * 100.0 / sum(delivered_orders), 1) as late_pct,
    round(sum(avg_days_to_deliver * delivered_orders) / sum(delivered_orders), 1) as avg_days,
    round(sum(avg_review_score * delivered_orders) / sum(delivered_orders), 2)    as avg_review
from main.mart_delivery_performance
group by 1
having sum(delivered_orders) >= 500
order by late_pct desc
limit 10;

-- name: Seller concentration (share of GMV from top sellers)
with seller_gmv as (
    select seller_id, sum(item_price + freight_value) as gmv
    from main.fct_order_items
    where order_status not in ('canceled', 'unavailable')
    group by 1
),
ranked as (
    select gmv, row_number() over (order by gmv desc) as rnk, count(*) over () as sellers, sum(gmv) over () as total
    from seller_gmv
)
select
    max(sellers)                                                      as total_sellers,
    round(sum(case when rnk <= sellers * 0.01 then gmv end) * 100 / max(total), 1) as top_1pct_share,
    round(sum(case when rnk <= sellers * 0.10 then gmv end) * 100 / max(total), 1) as top_10pct_share,
    round(sum(case when rnk <= sellers * 0.20 then gmv end) * 100 / max(total), 1) as top_20pct_share
from ranked;
