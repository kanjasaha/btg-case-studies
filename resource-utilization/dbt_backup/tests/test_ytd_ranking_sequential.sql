-- Test: YTD rankings should be sequential with no gaps
-- If this returns rows, ranking logic is broken

with ranking_check as (
    select
        rank_overall,
        lead(rank_overall) over (order by rank_overall) as next_rank,
        lead(rank_overall) over (order by rank_overall) - rank_overall as gap
    from {{ ref('customer_revenue_ytd') }}
)

select
    rank_overall,
    next_rank,
    gap,
    'Gap detected in ranking sequence' as issue
from ranking_check
where gap > 1  -- Should always be 1 (next rank)
   or gap is null and next_rank is not null  -- Shouldn't happen
