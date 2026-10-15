-- name: Review score by delivery outcome
-- Delivered orders only. Does missing the promised date move the review score?
select
    case
        when days_vs_estimate <= -7 then '1. 7+ days early'
        when days_vs_estimate < 0   then '2. 1-6 days early'
        when days_vs_estimate = 0   then '3. On the promised day'
        when days_vs_estimate <= 3  then '4. 1-3 days late'
        when days_vs_estimate <= 7  then '5. 4-7 days late'
        else                             '6. 8+ days late'
    end                                            as delivery_vs_promise,
    count(*)                                       as orders,
    round(avg(review_score), 2)                    as avg_review,
    round(avg((review_score <= 2)::int) * 100, 1)  as pct_1_2_star,
    round(avg((review_score = 5)::int) * 100, 1)   as pct_5_star
from main.fct_orders
where is_delivered and review_score is not null
group by 1
order by 1;

-- name: Late vs on-time headline
select
    case when is_late then 'Late' else 'On time / early' end as outcome,
    count(*)                                                  as orders,
    round(count(*) * 100.0 / sum(count(*)) over (), 1)        as pct_of_orders,
    round(avg(review_score), 2)                               as avg_review,
    round(avg((review_score <= 2)::int) * 100, 1)             as pct_1_2_star
from main.fct_orders
where is_delivered and review_score is not null
group by 1
order by 1;

-- name: Does a late first order hurt repeat purchase?
select
    case when first_order_was_late then 'First order late' else 'First order on time' end as first_order,
    count(*)                                                    as customers,
    round(avg(is_repeat_customer::int) * 100, 2)                as pct_who_ordered_again
from main.dim_customers
where first_order_was_late is not null
group by 1
order by 1;
