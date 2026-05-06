{{ config(
    materialized='incremental',
    database=env_var('DBT_DATABASE_TARGET'),
    schema='DIM',
    unique_key='product_key',
    incremental_strategy='merge',
    tags=['dimension'],
    post_hook="
        update {{ this }} dim
        set deleted_flag = 'Y',
            current_audit_datetime = current_timestamp()
        where not exists (
            select 1
            from {{ ref('stg_products') }} stg
            where stg.product_id = dim.product_id
        )
    "
) }}

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_key,
    p.product_id,
    p.product_name,
    p.sku,
    p.price,
    p.status as product_status,

    c.category_id,
    c.category_name,
    c.parent_category_id,
    pc.category_name as parent_category_name,

    p.load_time as source_audit_datetime,
    current_timestamp() as current_audit_datetime,
    'N' as deleted_flag

from {{ ref('stg_products') }} p

left join {{ ref('stg_categories') }} c
    on p.category_id = c.category_id
    
left join {{ ref('stg_categories') }} pc
    on c.parent_category_id = pc.category_id

{% if is_incremental() %}
where p.load_time > (
    select coalesce(max(source_audit_datetime), '1900-01-01'::timestamp)
    from {{ this }}
)
{% endif %}