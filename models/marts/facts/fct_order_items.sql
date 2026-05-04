{{ config(
    materialized='incremental',
    database='DEV',
    schema='FCT',
    unique_key='order_item_key',
    incremental_strategy='delete+insert',
    tags=['fact'],
    post_hook="
        update {{ this }} fct
        set deleted_flag = 'Y',
            current_audit_datetime = current_timestamp()
        where not exists (
            select 1
            from {{ ref('stg_order_items') }} stg
            where stg.order_item_id = fct.order_item_id
        )
    "
) }}

select
    {{ dbt_utils.generate_surrogate_key(['oi.order_item_id']) }} as order_item_key,
    oi.order_item_id,
    oi.order_id,

    dc.customer_key,
    dp.product_key,
    dl.location_key,

    o.order_date,
    o.order_status,
    o.payment_method,

    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.total_amount,

    oi.load_time as source_audit_datetime,
    current_timestamp() as current_audit_datetime,
    'N' as deleted_flag

from {{ ref('stg_order_items') }} oi

left join {{ ref('stg_orders') }} o
    on oi.order_id = o.order_id

left join {{ ref('dim_customers') }} dc
    on o.customer_id = dc.customer_id
    and dc.deleted_flag = 'N'

left join {{ ref('dim_products') }} dp
    on oi.product_id = dp.product_id
    and dp.deleted_flag = 'N'

left join {{ ref('dim_locations') }} dl
    on o.shipping_city_id = dl.city_id
    and dl.deleted_flag = 'N'

{% if is_incremental() %}
where oi.load_time > (
    select coalesce(max(source_audit_datetime), '1900-01-01'::timestamp)
    from {{ this }}
)
{% endif %}