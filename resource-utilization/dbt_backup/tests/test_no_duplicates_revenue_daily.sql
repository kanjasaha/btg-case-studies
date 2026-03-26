-- Test: No duplicate records should exist based on unique_key
-- If this returns rows, incremental strategy has issues

with duplicates as (
    select
        account_id,
        model_variant,
        source_region,
        revenue_date,
        count(*) as duplicate_count
    from {{ ref('int_revenue_daily') }}
    group by 1, 2, 3, 4
    having count(*) > 1
)

select
    account_id,
    model_variant,
    source_region,
    revenue_date,
    duplicate_count,
    'Duplicate records detected' as issue
from duplicates
