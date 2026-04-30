{{
    config(
        materialized = 'table',
        pre_hook = ["truncate table hr.audit", "
            insert into {{ source('hr', 'audit') }} (
                model_name,
                run_id,
                start_time,
                end_time,
                run_by_user 
            )
            values(
                '{{this}}',
                '{{ invocation_id }}',
                current_timestamp,
                null,
                current_user
            )
        "],
        post_hook = ["
            update {{ source('hr', 'audit') }}
            set end_time = current_timestamp
            where model_name = '{{this}}'
            and run_id = '{{ invocation_id }}'
        "]


        )
}}

with emp as (
    select * FROM {{ source('hr', 'src_employees') }} as src
)

SELECT 
{{ dbt_utils.generate_surrogate_key(['EMPLOYEE_ID', 'DEPARTMENT_ID']) }} as sk,
EMPLOYEE_ID,
FIRST_NAME,
LAST_NAME,
EMAIL,
PHONE_NUMBER,
HIRE_DATE,
JOB_ID,
SALARY,
COMMISSION_PCT,
MANAGER_ID,
DEPARTMENT_ID,
gender,
current_timestamp as LOAD_TIME
from emp AS SRC
