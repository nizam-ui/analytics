{{ config(
    materialized='view',
    database='DEV',
    schema='REPORTING',
    secure=true,
    tags=['reporting']
) }}

select
    foi.order_item_key,
    foi.order_id,
    foi.order_item_id,

    foi.customer_key,
    dc.customer_id,
    dc.customer_name,
    dc.email,
    dc.phone,
    dc.customer_status,

    foi.product_key,
    dp.product_id,
    dp.product_name,
    dp.sku,
    dp.product_status,
    dp.category_id,
    dp.category_name,
    dp.parent_category_name,

    foi.location_key,
    dl.city_id,
    dl.city,
    dl.state,
    dl.country,
    dl.region,

    foi.order_date,
    foi.order_status,
    foi.payment_method,

    foi.quantity,
    foi.unit_price,
    foi.discount,
    foi.total_amount,

    foi.deleted_flag as fact_deleted_flag,
    dc.deleted_flag as customer_deleted_flag,
    dp.deleted_flag as product_deleted_flag,
    dl.deleted_flag as location_deleted_flag,

    foi.source_audit_datetime,
    foi.current_audit_datetime

from {{ ref('fct_order_items') }} foi

left join {{ ref('dim_customers') }} dc
    on foi.customer_key = dc.customer_key
    and dc.deleted_flag = 'N'

left join {{ ref('dim_products') }} dp
    on foi.product_key = dp.product_key
    and dp.deleted_flag = 'N'

left join {{ ref('dim_locations') }} dl
    on foi.location_key = dl.location_key
    and dl.deleted_flag = 'N'

where foi.deleted_flag = 'N'