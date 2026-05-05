{{
    config(
        materialized = 'incremental',
        database = 'DEV',
        schema = 'DIM',
        unique_key = 'location_key',
        incremental_strategy = 'merge',
        post_hook = "
        update {{this}} as dim
        set 
            delete_flag = 'Y',
            current_audit_datetime = current_timestamp()
        where not exists(
            select 1 
            from {{ ref('stg_locations') }} as stg
            where stg.city_id = dim.city_id
        )
        "
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['CITY_ID']) }} as location_key,
    CITY_ID,
    CITY,
    STATE,
    COUNTRY,
    REGION,
    LOAD_TIME as source_audit_datetime,
    current_timestamp() as current_audit_datetime,
    'N' as delete_flag
from {{ ref('stg_locations') }}

{% if is_incremental() %}

where LOAD_TIME > (
    select coalesce(max(source_audit_datetime), '1900-01-01'::timestamp)
    from {{this}}
)

{% endif %}






