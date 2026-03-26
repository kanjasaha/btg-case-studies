-- Test: All source_regions used in revenue should have region mapping
-- If this returns rows, we have unmapped regions

with revenue_regions as (
    select distinct source_region
    from {{ ref('int_revenue_daily') }}
),

mapped_regions as (
    select distinct source_region
    from {{ ref('region_mapping') }}
),

unmapped as (
    select
        r.source_region,
        'Region not in mapping table' as issue
    from revenue_regions r
    left join mapped_regions m
        on r.source_region = m.source_region
    where m.source_region is null
)

select * from unmapped
