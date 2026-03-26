-- Test: Net revenue should never exceed gross revenue
-- net_revenue = gross_revenue - discounts - savings_plan
-- If net > gross, discount logic is inverted or there is a calculation bug

select
    account_id,
    month_start_date,
    total_gross_revenue,
    total_net_revenue,
    total_net_revenue - total_gross_revenue as overage,
    'Net revenue exceeds gross revenue'     as issue

from {{ ref('customer_revenue_monthly') }}
where total_net_revenue > total_gross_revenue
