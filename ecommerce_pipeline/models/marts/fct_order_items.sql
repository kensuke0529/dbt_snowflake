{{config (materialized='table')}}

select
    order_id,
    product_id,
    product_name,
    category,
    unit_price,
    quantity,
    (unit_price * quantity) as line_item_revenue
from {{ ref('int_order_items_flattened') }}