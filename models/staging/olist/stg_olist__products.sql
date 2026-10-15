with products as (
    select * from {{ source('olist', 'olist_products_dataset') }}
),

translation as (
    select * from {{ source('olist', 'product_category_name_translation') }}
)

select
    p.product_id,
    p.product_category_name                                    as category_pt,
    coalesce(t.product_category_name_english,
             p.product_category_name, 'unknown')               as category,
    cast(p.product_photos_qty as integer)                      as photo_count,
    cast(p.product_weight_g as integer)                        as weight_g,
    cast(p.product_length_cm as integer)
        * cast(p.product_height_cm as integer)
        * cast(p.product_width_cm as integer)                  as volume_cm3
from products as p
left join translation as t
    on p.product_category_name = t.product_category_name
