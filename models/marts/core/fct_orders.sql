-- Grain: one row per order. The single source for every order-level metric in this project.
with orders as (
    select * from {{ ref('stg_olist__orders') }}
),

customers as (
    select * from {{ ref('stg_olist__customers') }}
),

items as (
    select
        order_id,
        count(*)                    as item_count,
        count(distinct seller_id)   as seller_count,
        sum(item_price)             as items_value,
        sum(freight_value)          as freight_value
    from {{ ref('stg_olist__order_items') }}
    group by 1
),

payments as (
    select
        order_id,
        sum(payment_value)                                   as payment_value,
        max(installments)                                    as max_installments,
        arg_max(payment_type, payment_value)                 as primary_payment_type
    from {{ ref('stg_olist__payments') }}
    group by 1
),

reviews as (
    select
        order_id,
        arg_max(review_score, review_answered_at)            as review_score,
        bool_or(has_comment)                                 as has_review_comment,
        min(review_created_at)                               as first_review_at
    from {{ ref('stg_olist__reviews') }}
    group by 1
),

joined as (
    select
        o.order_id,
        c.customer_unique_id,
        c.state                                              as customer_state,
        o.order_status,
        o.purchased_at,
        date_trunc('month', o.purchased_at)::date            as purchase_month,
        o.approved_at,
        o.shipped_at,
        o.delivered_at,
        o.estimated_delivery_at,

        coalesce(i.item_count, 0)                            as item_count,
        coalesce(i.seller_count, 0)                          as seller_count,
        coalesce(i.items_value, 0)                           as items_value,
        coalesce(i.freight_value, 0)                         as freight_value,
        coalesce(i.items_value, 0) + coalesce(i.freight_value, 0) as gmv,
        p.payment_value,
        p.primary_payment_type,
        p.max_installments,

        r.review_score,
        r.has_review_comment,

        o.delivered_at is not null                           as is_delivered,
        date_diff('hour', o.purchased_at, o.approved_at)     as hours_to_approve,
        date_diff('day', o.purchased_at, o.delivered_at)     as days_to_deliver,
        date_diff('day', o.estimated_delivery_at::date, o.delivered_at::date) as days_vs_estimate,
        o.delivered_at::date > o.estimated_delivery_at::date as is_late
    from orders as o
    left join customers as c on o.customer_id = c.customer_id
    left join items     as i on o.order_id = i.order_id
    left join payments  as p on o.order_id = p.order_id
    left join reviews   as r on o.order_id = r.order_id
)

select
    *,
    row_number() over (partition by customer_unique_id order by purchased_at, order_id) as customer_order_number
from joined
