-- Grain: one row per order item, enriched with product, seller and order context.
select
    i.order_item_key,
    i.order_id,
    i.order_item_seq,
    i.product_id,
    p.category,
    i.seller_id,
    s.state                     as seller_state,
    o.customer_state,
    o.purchase_month,
    o.order_status,
    o.is_late,
    o.review_score,
    i.item_price,
    i.freight_value
from {{ ref('stg_olist__order_items') }} as i
left join {{ ref('stg_olist__products') }} as p on i.product_id = p.product_id
left join {{ ref('stg_olist__sellers') }}  as s on i.seller_id = s.seller_id
left join {{ ref('fct_orders') }}          as o on i.order_id = o.order_id
