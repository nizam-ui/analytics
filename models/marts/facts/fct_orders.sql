{{ config(
    materialized='incremental',
    database='DEV',
    schema='FCT',
    unique_key='order_key',
    incremental_strategy='delete+insert',
    tags=['fact'],
    post_hook="
        update {{ this }} fct
        set deleted_flag = 'Y',
            current_audit_datetime = current_timestamp()
        where not exists (
            select 1
            from {{ ref('stg_orders') }} stg
            where stg.order_id = fct.order_id
        )
    "
) }}

select
    {{ dbt_utils.generate_surrogate_key(['o.order_id']) }} as order_key,
    o.order_id,

    dc.customer_key,
    dl.location_key,

    o.order_date,
    o.order_status,
    o.payment_method,
    o.grand_total,

    o.load_time as source_audit_datetime,
    current_timestamp() as current_audit_datetime,
    'N' as deleted_flag

from {{ ref('stg_orders') }} o

left join {{ ref('dim_customers') }} dc
    on o.customer_id = dc.customer_id
    and dc.deleted_flag = 'N'

left join {{ ref('dim_locations') }} dl
    on o.shipping_city_id = dl.city_id
    and dl.deleted_flag = 'N'

{% if is_incremental() %}
where o.load_time > (
    select coalesce(max(source_audit_datetime), '1900-01-01'::timestamp)
    from {{ this }}
)
{% endif %}