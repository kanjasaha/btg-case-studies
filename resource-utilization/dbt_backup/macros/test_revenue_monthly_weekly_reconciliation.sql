-- Test: Monthly revenue should never exceed weekly revenue summed for the same period
-- net_revenue in monthly mart should reconcile with weekly mart
-- If this returns rows, there is a double-counting or aggregation bug

select
    m.account_id,
    m.month_start_date,
    m.total_net_revenue                             as monthly_net_revenue,
    sum(w.total_net_revenue)                        as weekly_net_revenue_sum,
    m.total_net_revenue - sum(w.total_net_revenue)  as discrepancy,
    'Monthly and weekly revenue do not reconcile'   as issue

from {{ ref('customer_revenue_monthly') }} m
left join {{ ref('customer_revenue_weekly') }} w
    on m.account_id = w.account_id
    and w.week_start_date >= m.month_start_date
    and w.week_start_date <= m.month_end_date

group by
    m.account_id,
    m.month_start_date,
    m.total_net_revenue

having
    -- allow small rounding differences
    abs(m.total_net_revenue - sum(w.total_net_revenue)) > 0.01
