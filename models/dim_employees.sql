{{
    config(materialized = 'table')
}}

select 
    employee_id,
    concat(first_name, ' ', last_name) as name,
    replace(email,'example','hcl') as email,
    phone_number,
    to_char(hire_date,'dd/mm/yyyy') as hire_date,
    job_id,
    salary,
    coalesce(commission_pct,0) as commission_pct,
    coalesce(manager_id,0) as manager_id,
    department_id,
    current_timestamp as load_time
from {{ ref('stg_employees')}}
