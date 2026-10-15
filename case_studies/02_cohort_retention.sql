-- name: Repeat purchase headline
select
    count(*)                                         as customers,
    sum(is_repeat_customer::int)                     as repeat_customers,
    round(avg(is_repeat_customer::int) * 100, 2)     as repeat_rate_pct,
    round(avg(lifetime_orders), 3)                   as avg_orders_per_customer
from main.dim_customers;

-- name: Monthly cohort retention, months 1-6 (cohorts with 1,000+ customers)
select
    strftime(cohort_month, '%Y-%m')                                           as cohort,
    max(cohort_customers)                                                     as customers,
    round(max(case when months_since_first = 1 then retention_rate end) * 100, 2) as m1_pct,
    round(max(case when months_since_first = 2 then retention_rate end) * 100, 2) as m2_pct,
    round(max(case when months_since_first = 3 then retention_rate end) * 100, 2) as m3_pct,
    round(max(case when months_since_first = 6 then retention_rate end) * 100, 2) as m6_pct
from main.mart_cohort_retention
where cohort_month between date '2017-01-01' and date '2018-03-01'
group by cohort_month
having max(cohort_customers) >= 1000
order by cohort_month;

-- name: First-order review score vs coming back
select
    first_order_review_score                         as first_order_review,
    count(*)                                         as customers,
    round(avg(is_repeat_customer::int) * 100, 2)     as pct_who_ordered_again
from main.dim_customers
where first_order_review_score is not null
group by 1
order by 1;

-- name: Categories that bring customers back (first-order category, 1,000+ first orders)
with first_orders as (
    select o.customer_unique_id, i.category
    from main.fct_orders as o
    join main.fct_order_items as i using (order_id)
    where o.customer_order_number = 1 and i.order_item_seq = 1
)
select
    f.category,
    count(*)                                         as first_orders,
    round(avg(c.is_repeat_customer::int) * 100, 2)   as repeat_rate_pct
from first_orders as f
join main.dim_customers as c using (customer_unique_id)
group by 1
having count(*) >= 1000
order by repeat_rate_pct desc
limit 10;
