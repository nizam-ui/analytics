{{
    config(
        materialized = 'table'
        )
}}

with emp as (
    select * FROM {{ source('hr', 'src_employees') }} as src
)

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
gender,
current_timestamp as LOAD_TIME
from emp AS SRC
