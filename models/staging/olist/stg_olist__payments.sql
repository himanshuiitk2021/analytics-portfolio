with source as (
    select * from {{ source('olist', 'olist_order_payments_dataset') }}
)

select
    order_id || '-' || cast(payment_sequential as varchar) as payment_key,
    order_id,
    cast(payment_sequential as integer)          as payment_seq,
    payment_type,
    cast(payment_installments as integer)        as installments,
    cast(payment_value as decimal(12, 2))        as payment_value
from source
