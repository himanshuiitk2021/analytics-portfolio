{{ config(severity = 'warn') }}
-- Payments should match items + freight. Olist has a small number of known mismatches (vouchers, rounding),
-- so this warns instead of failing and the count is reported in the README.
select order_id, gmv, payment_value
from {{ ref('fct_orders') }}
where payment_value is not null
  and abs(gmv - payment_value) > 1.00
