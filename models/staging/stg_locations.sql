select
    city_id,
    city,
    state,
    country,
    region,
    load_time
from {{ source('raw', 'locations') }}