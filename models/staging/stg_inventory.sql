select
    inventory_id,
    product_id,
    warehouse_id,
    stock_quantity,
    last_updated,
    load_time
from {{ source('raw', 'inventory') }}