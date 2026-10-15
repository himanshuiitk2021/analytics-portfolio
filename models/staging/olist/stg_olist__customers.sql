-- customer_id is per order; customer_unique_id is the real person, used for cohorts and repeat purchase.
with source as (
    select * from {{ source('olist', 'olist_customers_dataset') }}
)

select
    customer_id,
    customer_unique_id,
    lpad(cast(customer_zip_code_prefix as varchar), 5, '0') as zip_prefix,
    customer_city                                       as city,
    customer_state                                      as state
from source
