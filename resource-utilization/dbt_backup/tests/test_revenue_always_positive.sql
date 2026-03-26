-- Test: Revenue should never be negative
-- If this returns rows, we have negative revenue (bad data!)

select
    account_id,
    model_variant,
    source_region,
    revenue_date,
    total_gross_revenue,
    net_revenue,
    'Negative revenue detected' as issue
from {{ ref('int_revenue_daily') }}
where total_gross_revenue < 0
   or net_revenue < 0
