-- Test: Active days in a month should be reasonable (1-31)
-- If this returns rows, aggregation or data is wrong

select
    account_id,
    month_start_date,
    month_end_date,
    active_days,
    extract(day from month_end_date) as days_in_month,
    'Active days exceeds days in month' as issue
from {{ ref('customer_revenue_monthly') }}
where active_days > extract(day from month_end_date)
   or active_days < 1
   or active_days > 31
