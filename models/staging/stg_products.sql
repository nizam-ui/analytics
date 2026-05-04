{{ config(materialized='view', database='DEV', schema='STAGE') }}

select
    product_id,
    category_id,
    product_name,
    sku,
    price,
    status,
    load_time
from {{ source('raw', 'products') }}