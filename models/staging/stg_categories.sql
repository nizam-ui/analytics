select
    category_id,
    category_name,
    parent_category_id,
    status,
    load_time
from {{ source('raw', 'categories') }}