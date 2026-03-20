-- =============================================================================
-- Seed Data: revenue_account_daily
-- =============================================================================
-- Date: 2026-02-25
-- Author: Data Engineering Team
-- Purpose: Populate daily revenue table from inference usage tables
--          for Jan 13-19 2026 (aligns with 003_seed_bronze_tables.sql)
--
-- Source tables:
--   raw_bronze.inference_user_token_usage_proprietary
--   raw_bronze.inference_user_token_usage_open_source
--
-- Pricing logic:
--   Realistic per-model pricing based on public API rates (per 1M tokens)
--   Defined in CTE: model_pricing
--
-- Savings plan:
--   Applied to Strategic/Enterprise accounts: ACC001, ACC002, ACC005, ACC007, ACC010
--   Rate: 15% of gross revenue (committed use discount)
--
-- Discount:
--   Strategic segment:  5% negotiated contract discount
--   Commercial segment: 2% volume discount
--   SMB segment:        0% no discount
--
-- product_sku: bedrock_core (all records)
-- billing_type: derived from account segment
--   Strategic  → savings-plan
--   Commercial → pay-as-you-go
--   SMB        → pay-as-you-go
--
-- currency_code:
--   US, CA accounts → USD
--   UK (ACC005)     → GBP
--   DE (ACC006)     → EUR
--   SG (ACC007)     → USD (billed in USD)
--   ES (ACC009)     → EUR
-- =============================================================================


INSERT INTO raw_bronze.revenue_account_daily (
    account_id,
    product_sku,
    model_variant,
    inference_scope,
    region,
    gross_rev_input_tokens,
    gross_rev_output_tokens,
    gross_rev_cache_read_tokens,
    gross_rev_cache_write_tokens,
    savings_plan,
    discount_amount,
    currency_code,
    billing_type,
    revenue_date,
    snapshot_date,
    source_file
)

WITH

-- =============================================================================
-- Model pricing rates (per 1M tokens, USD)
-- Based on realistic public API pricing as of early 2026
-- =============================================================================
model_pricing AS (
    SELECT * FROM (VALUES
        -- Anthropic
        ('claude-sonnet-4_200k_20250514',       3.000000, 15.000000, 0.300000,  3.750000),
        ('claude-3.5-sonnet_200k_20241022',     3.000000, 15.000000, 0.300000,  3.750000),
        ('claude-3-opus_200k_20240229',         15.000000,75.000000, 1.500000, 18.750000),
        ('claude-3-haiku_200k_20240307',         0.250000,  1.250000, 0.025000,  0.312500),
        ('claude-3-sonnet_200k_20240229',        3.000000, 15.000000, 0.300000,  3.750000),
        ('claude-2.1_100k_20231128',             8.000000, 24.000000, 0.800000, 10.000000),
        -- OpenAI
        ('gpt-4o_128k_20240513',                 2.500000, 10.000000, 1.250000,  0.000000),
        ('gpt-4-turbo_128k_20240409',           10.000000, 30.000000, 0.000000,  0.000000),
        ('gpt-4_8k_20230613',                   30.000000, 60.000000, 0.000000,  0.000000),
        ('gpt-3.5-turbo_16k_20250125',           0.500000,  1.500000, 0.000000,  0.000000),
        -- Google
        ('gemini-1.5-pro_1m_20240214',           3.500000, 10.500000, 0.000000,  0.000000),
        ('gemini-1.5-flash_1m_20240214',         0.075000,  0.300000, 0.000000,  0.000000),
        ('gemini-1.0-pro_32k_20231206',          0.500000,  1.500000, 0.000000,  0.000000),
        -- Meta (open source)
        ('llama-3.1_70b_20240723',               0.900000,  0.900000, 0.000000,  0.000000),
        ('llama-3.1_405b_20240723',              5.000000,  5.000000, 0.000000,  0.000000),
        ('llama-3_8b_20240418',                  0.200000,  0.200000, 0.000000,  0.000000),
        -- Mistral
        ('mixtral-8x7b_32k_20231211',            0.700000,  0.700000, 0.000000,  0.000000),
        ('mistral-large_128k_20240724',          2.000000,  6.000000, 0.000000,  0.000000),
        ('mistral_7b_32k_20240522',              0.250000,  0.250000, 0.000000,  0.000000),
        -- Cohere
        ('command-r-plus_128k_20240404',         3.000000, 15.000000, 0.000000,  0.000000),
        ('command_128k_20240301',                1.000000,  2.000000, 0.000000,  0.000000),
        -- AI21
        ('jamba-1.5-large_256k_20240815',        2.000000,  8.000000, 0.000000,  0.000000)
    ) AS t (
        model_variant,
        price_input_per_1m,
        price_output_per_1m,
        price_cache_read_per_1m,
        price_cache_write_per_1m
    )
),

-- =============================================================================
-- Account attributes for billing context
-- =============================================================================
account_attrs AS (
    SELECT * FROM (VALUES
        ('ACC001', 'Strategic',  'Enterprise', 'USD', 'savings-plan',   0.15, 0.05),
        ('ACC002', 'Strategic',  'Enterprise', 'USD', 'savings-plan',   0.15, 0.05),
        ('ACC003', 'Commercial', 'Mid-Market', 'USD', 'pay-as-you-go',  0.00, 0.02),
        ('ACC004', 'Commercial', 'SMB',        'USD', 'pay-as-you-go',  0.00, 0.02),
        ('ACC005', 'Strategic',  'Enterprise', 'GBP', 'savings-plan',   0.15, 0.05),
        ('ACC006', 'Commercial', 'Mid-Market', 'EUR', 'pay-as-you-go',  0.00, 0.02),
        ('ACC007', 'Strategic',  'Enterprise', 'USD', 'savings-plan',   0.15, 0.05),
        ('ACC008', 'Commercial', 'Mid-Market', 'USD', 'pay-as-you-go',  0.00, 0.02),
        ('ACC009', 'Commercial', 'SMB',        'EUR', 'pay-as-you-go',  0.00, 0.00),
        ('ACC010', 'Strategic',  'Enterprise', 'USD', 'savings-plan',   0.15, 0.05)
    ) AS t (
        account_id,
        segment,
        account_size,
        currency_code,
        billing_type,
        savings_plan_rate,
        discount_rate
    )
),

-- =============================================================================
-- Union proprietary and open source inference usage
-- =============================================================================
all_inference AS (
    SELECT
        account_id,
        model_variant,
        inference_scope,
        source_region,
        input_token,
        output_token,
        cache_read_token,
        cache_write_token,
        DATE(event_timestamp)   AS revenue_date
    FROM raw_bronze.inference_user_token_usage_proprietary
    WHERE DATE(event_timestamp) BETWEEN '2026-01-13' AND '2026-01-19'

    UNION ALL

    SELECT
        account_id,
        model_variant,
        inference_scope,
        source_region,
        input_token,
        output_token,
        cache_read_token,
        cache_write_token,
        DATE(event_timestamp)   AS revenue_date
    FROM raw_bronze.inference_user_token_usage_open_source
    WHERE DATE(event_timestamp) BETWEEN '2026-01-13' AND '2026-01-19'
),

-- =============================================================================
-- Aggregate to daily grain per account + model + region
-- =============================================================================
daily_usage AS (
    SELECT
        account_id,
        model_variant,
        inference_scope,
        source_region,
        revenue_date,
        SUM(input_token)        AS total_input_tokens,
        SUM(output_token)       AS total_output_tokens,
        SUM(cache_read_token)   AS total_cache_read_tokens,
        SUM(cache_write_token)  AS total_cache_write_tokens
    FROM all_inference
    GROUP BY
        account_id,
        model_variant,
        inference_scope,
        source_region,
        revenue_date
),

-- =============================================================================
-- Calculate gross revenue by token type
-- =============================================================================
daily_revenue AS (
    SELECT
        u.account_id,
        u.model_variant,
        u.inference_scope,
        u.source_region,
        u.revenue_date,

        -- Gross revenue per token type (tokens / 1,000,000 * price per 1M)
        ROUND((u.total_input_tokens       / 1000000.0) * p.price_input_per_1m,      6) AS gross_rev_input_tokens,
        ROUND((u.total_output_tokens      / 1000000.0) * p.price_output_per_1m,     6) AS gross_rev_output_tokens,
        ROUND((u.total_cache_read_tokens  / 1000000.0) * p.price_cache_read_per_1m, 6) AS gross_rev_cache_read_tokens,
        ROUND((u.total_cache_write_tokens / 1000000.0) * p.price_cache_write_per_1m,6) AS gross_rev_cache_write_tokens

    FROM daily_usage u
    LEFT JOIN model_pricing p
        ON u.model_variant = p.model_variant
),

-- =============================================================================
-- Apply savings plan and discount
-- =============================================================================
final_revenue AS (
    SELECT
        r.account_id,
        r.model_variant,
        r.inference_scope,
        r.source_region,
        r.revenue_date,
        r.gross_rev_input_tokens,
        r.gross_rev_output_tokens,
        r.gross_rev_cache_read_tokens,
        r.gross_rev_cache_write_tokens,

        -- Total gross for applying rates
        (r.gross_rev_input_tokens
         + r.gross_rev_output_tokens
         + r.gross_rev_cache_read_tokens
         + r.gross_rev_cache_write_tokens)         AS total_gross,

        a.savings_plan_rate,
        a.discount_rate,
        a.currency_code,
        a.billing_type

    FROM daily_revenue r
    LEFT JOIN account_attrs a
        ON r.account_id = a.account_id
)

-- =============================================================================
-- Final SELECT into the table
-- =============================================================================
SELECT
    account_id,
    'bedrock_core'                                              AS product_sku,
    model_variant,
    inference_scope,
    source_region                                               AS region,
    gross_rev_input_tokens,
    gross_rev_output_tokens,
    gross_rev_cache_read_tokens,
    gross_rev_cache_write_tokens,

    -- savings_plan: applied to Strategic/Enterprise accounts only
    ROUND(total_gross * savings_plan_rate, 6)                   AS savings_plan,

    -- discount_amount: segment-based
    ROUND(
        (total_gross - (total_gross * savings_plan_rate))
        * discount_rate, 6
    )                                                           AS discount_amount,

    currency_code,
    billing_type,
    revenue_date,
    revenue_date                                                AS snapshot_date,
    'derived:inference_user_token_usage_proprietary+open_source' AS source_file

FROM final_revenue
ORDER BY account_id, model_variant, source_region, revenue_date;


-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Row count and date range
SELECT
    COUNT(*)                        AS total_rows,
    COUNT(DISTINCT account_id)      AS distinct_accounts,
    COUNT(DISTINCT model_variant)   AS distinct_models,
    MIN(revenue_date)               AS earliest_date,
    MAX(revenue_date)               AS latest_date
FROM raw_bronze.revenue_account_daily;

-- Revenue summary by account
SELECT
    account_id,
    billing_type,
    currency_code,
    SUM(gross_rev_input_tokens
      + gross_rev_output_tokens
      + gross_rev_cache_read_tokens
      + gross_rev_cache_write_tokens)    AS total_gross_revenue,
    SUM(savings_plan)                    AS total_savings_plan,
    SUM(discount_amount)                 AS total_discount,
    SUM(gross_rev_input_tokens
      + gross_rev_output_tokens
      + gross_rev_cache_read_tokens
      + gross_rev_cache_write_tokens
      - savings_plan
      - discount_amount)                 AS total_net_revenue
FROM raw_bronze.revenue_account_daily
GROUP BY account_id, billing_type, currency_code
ORDER BY account_id;

-- Revenue by model
SELECT
    model_variant,
    SUM(gross_rev_input_tokens
      + gross_rev_output_tokens
      + gross_rev_cache_read_tokens
      + gross_rev_cache_write_tokens)    AS total_gross_revenue
FROM raw_bronze.revenue_account_daily
GROUP BY model_variant
ORDER BY total_gross_revenue DESC;
