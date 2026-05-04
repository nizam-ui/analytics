{{ config(materialized='view', database='DEV', schema='STAGE') }}

select
    payment_id,
    order_id,
    payment_date,
    payment_method,
    amount,
    payment_status,
    transaction_id,
    load_time
from {{ source('raw', 'payments') }}