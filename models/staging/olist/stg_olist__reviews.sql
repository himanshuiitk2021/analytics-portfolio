-- The raw file repeats some review_id values across orders, so the grain here is review + order.
with source as (
    select * from {{ source('olist', 'olist_order_reviews_dataset') }}
)

select
    review_id || '-' || order_id                  as review_key,
    review_id,
    order_id,
    cast(review_score as integer)                 as review_score,
    review_comment_title,
    review_comment_message,
    review_comment_message is not null
        and trim(review_comment_message) <> ''    as has_comment,
    cast(review_creation_date as timestamp)       as review_created_at,
    cast(review_answer_timestamp as timestamp)    as review_answered_at
from source
qualify row_number() over (partition by review_id, order_id order by review_answer_timestamp desc) = 1
