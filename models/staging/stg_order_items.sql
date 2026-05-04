{{ config(materialized='view', database='DEV', schema='STAGE') }}

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount,
    total_amount,
    load_time
from {{ source('raw', 'order_items') }}