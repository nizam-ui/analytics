{{ config(
    materialized='incremental',
    database=env_var('DBT_DATABASE_TARGET'),
    schema='FCT',
    unique_key='payment_key',
    incremental_strategy='delete+insert',
    tags=['fact'],
    post_hook="
        update {{ this }} fct
        set deleted_flag = 'Y',
            current_audit_datetime = current_timestamp()
        where not exists (
            select 1
            from {{ ref('stg_payments') }} stg
            where stg.payment_id = fct.payment_id
        )
    "
) }}

select
    {{ dbt_utils.generate_surrogate_key(['p.payment_id']) }} as payment_key,
    p.payment_id,
    p.order_id,

    fo.order_key,

    p.payment_date,
    p.payment_method,
    p.amount,
    p.payment_status,
    p.transaction_id,

    p.load_time as source_audit_datetime,
    current_timestamp() as current_audit_datetime,
    'N' as deleted_flag

from {{ ref('stg_payments') }} p

left join {{ ref('fct_orders') }} fo
    on p.order_id = fo.order_id
    and fo.deleted_flag = 'N'

{% if is_incremental() %}
where p.load_time > (
    select coalesce(max(source_audit_datetime), '1900-01-01'::timestamp)
    from {{ this }}
)
{% endif %}