select
    order_id,
    customer_id,
    order_date,
    order_status,
    payment_method,
    grand_total,
    shipping_city_id,
    load_time
from {{ source('raw', 'orders') }}