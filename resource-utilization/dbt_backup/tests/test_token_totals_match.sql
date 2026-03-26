-- Test: total_tokens should equal input + output + cache tokens
-- If this returns rows, token math is wrong

with token_validation as (
    select
        account_id,
        model_variant,
        source_region,
        event_date,
        total_tokens,
        input_tokens,
        output_tokens,
        cache_read_tokens,
        cache_write_tokens,
        
        -- Calculate what total should be
        coalesce(input_tokens, 0) 
        + coalesce(output_tokens, 0) 
        + coalesce(cache_read_tokens, 0) 
        + coalesce(cache_write_tokens, 0) as calculated_total,
        
        -- Calculate difference
        abs(
            total_tokens - (
                coalesce(input_tokens, 0) 
                + coalesce(output_tokens, 0) 
                + coalesce(cache_read_tokens, 0) 
                + coalesce(cache_write_tokens, 0)
            )
        ) as difference
        
    from {{ ref('int_token_usage_minute') }}
    where total_tokens is not null
)

select
    account_id,
    model_variant,
    source_region,
    event_date,
    total_tokens,
    calculated_total,
    difference,
    'Token totals do not match components' as issue
from token_validation
where difference > 1  -- Allow 1 token rounding difference
