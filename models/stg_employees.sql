{{
    config(
        materialized = 'incremental',
        schema = 'hr'
        )
}}


SELECT 
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
current_timestamp as LOAD_TIME
 FROM ods.hr.SRC_EMPLOYEES as src

{% if is_incremental() %}
where src.load_time > (
    select coalesce(max(load_time),'1900-01-01') from stg_employees
)

{% endif %}