{{ config(
    materialized='incremental',
    database=env_var('DBT_DATABASE_TARGET'),
    schema='DIM',
    unique_key='customer_key',
    incremental_strategy='merge',
    tags=['dimension'],
    post_hook="
        update {{ this }} dim
        set deleted_flag = 'Y',
            current_audit_datetime = current_timestamp()
        where not exists (
            select 1
            from {{ ref('stg_customers') }} stg
            where stg.customer_id = dim.customer_id
        )
    "
) }}

select
    {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} as customer_key,
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone,
    c.registered_date,
    c.status as customer_status,

    l.city,
    l.state,
    l.country,
    l.region,

    c.load_time as source_audit_datetime,
    current_timestamp() as current_audit_datetime,
    'N' as deleted_flag

from {{ ref('stg_customers') }} c
left join {{ ref('stg_locations') }} l
    on c.city_id = l.city_id

{% if is_incremental() %}
where c.load_time > (
    select coalesce(max(source_audit_datetime), '1900-01-01'::timestamp)
    from {{ this }}
)
{% endif %}