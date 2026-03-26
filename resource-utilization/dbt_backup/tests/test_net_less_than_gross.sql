-- Test: Net revenue should always be <= gross revenue
-- If this returns rows, we have accounting issues

select
    account_id,
    model_variant,
    source_region,
    revenue_date,
    total_gross_revenue,
    net_revenue,
    savings_plan_amount,
    discount_amount,
    net_revenue - total_gross_revenue as excess_amount,
    'Net revenue exceeds gross revenue' as issue
from {{ ref('int_revenue_daily') }}
where net_revenue > total_gross_revenue
