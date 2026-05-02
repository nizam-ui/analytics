{% snapshot employees_snapshot %}

{{
    config(
        unique_key = 'employee_id',
        strategy = 'timestamp',
        updated_at = 'load_time',
        invalidate_hard_deletes = true
    )
}}

select
    EMPLOYEE_ID,
    FIRST_NAME,
    LAST_NAME,
    LOAD_TIME
from
    {{ source('hr', 'src_employees') }}

{% endsnapshot %}