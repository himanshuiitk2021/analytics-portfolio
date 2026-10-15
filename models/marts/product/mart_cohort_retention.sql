-- Grain: cohort month x months since first order. Retention = share of the cohort that ordered again in that month.
with orders as (
    select
        o.customer_unique_id,
        o.purchase_month,
        c.cohort_month
    from {{ ref('fct_orders') }} as o
    join {{ ref('dim_customers') }} as c using (customer_unique_id)
    where o.order_status not in ('canceled', 'unavailable')
),

activity as (
    select
        cohort_month,
        date_diff('month', cohort_month, purchase_month) as months_since_first,
        count(distinct customer_unique_id)               as active_customers
    from orders
    group by 1, 2
),

cohort_size as (
    select cohort_month, count(*) as cohort_customers
    from {{ ref('dim_customers') }}
    group by 1
)

select
    a.cohort_month,
    a.months_since_first,
    s.cohort_customers,
    a.active_customers,
    round(a.active_customers / s.cohort_customers, 4) as retention_rate
from activity as a
join cohort_size as s using (cohort_month)
