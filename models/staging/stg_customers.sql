select
    customer_id,
    customer_name,
    email,
    phone,
    city_id,
    registered_date,
    status,
    load_time
from {{ source('raw', 'customers') }}