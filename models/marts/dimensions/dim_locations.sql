{{ config(
    materialized='incremental',
    database='DEV',
    schema='DIM',
    unique_key='location_key',
    incremental_strategy='merge',
    tags=['dimension'],
    post_hook="
        update {{ this }} dim
        set deleted_flag = 'Y',
            current_audit_datetime = current_timestamp()
        where not exists (
            select 1
            from {{ ref('stg_locations') }} stg
            where stg.city_id = dim.city_id
        )
    "
) }}

select
	{{ dbt_utils.generate_surrogate_key(['city_id']) }} as location_key,
	city_id,
	city,
	state,
	country,
	region,
	load_time as source_audit_datetime,
	current_timestamp() as current_audit_datetime,
	'N' as deleted_flag
from {{ ref('stg_locations') }}

{% if is_incremental() %}
where load_time > (
    select coalesce(max(source_audit_datetime), '1900-01-01'::timestamp)
    from {{ this }}
)
{% endif %}