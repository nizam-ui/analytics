{{
    config(
        materialized = 'incremental',
        incremental_strategy = 'insert_overwrite',
        unique_key = 'EMPLOYEE_ID',
        partition_by = { 'field': 'LOAD_TIME', 'data_type': 'timestamp' }
    )
}}

select 
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
    LOAD_TIME
from ODS.HR.SRC_EMPLOYEES as src

{% if is_incremental() %}

where src.load_time > dateadd(day, -3, current_timestamp)

{% endif %}