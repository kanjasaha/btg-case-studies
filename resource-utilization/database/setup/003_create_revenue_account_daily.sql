-- =============================================================================
-- Bronze Layer Table - Daily Account Revenue
-- =============================================================================
-- Date: 2026-02-25
-- Author: Data Engineering Team
-- Purpose: Append-only daily revenue table at account + model + region grain
-- Source: Billing system / revenue recognition pipeline
-- =============================================================================

-- =============================================================================
-- TABLE: revenue_account_daily
-- =============================================================================
-- Grain: account_id + product_sku + model_variant + inference_scope +
--        region + billing_type + currency_code + revenue_date
--
-- Revenue components:
--   gross_rev_input_tokens      → revenue from input token consumption
--   gross_rev_output_tokens     → revenue from output token consumption
--   gross_rev_cache_read_tokens → revenue from cache read token consumption
--   gross_rev_cache_write_tokens→ revenue from cache write token consumption
--   savings_plan                → savings plan credits applied (negative impact on net)
--   discount_amount             → discounts applied (negative impact on net)
--
-- Net revenue is derived in the silver layer:
--   net_revenue = SUM(gross_rev_*) - savings_plan - discount_amount
-- =============================================================================

CREATE TABLE IF NOT EXISTS raw_bronze.revenue_account_daily (

    -- Customer Reference
    account_id                      VARCHAR(50)         NOT NULL,

    -- Product Reference
    product_sku                     VARCHAR(200)        NOT NULL,   -- product catalog ID
    model_variant                   VARCHAR(200)        NOT NULL,
    inference_scope                 VARCHAR(50)         NOT NULL,   -- global, regional, multi-region

    -- Region
    region                          VARCHAR(50)         NOT NULL,

    -- Gross Revenue by Token Type
    gross_rev_input_tokens          NUMERIC(18, 6)      NOT NULL DEFAULT 0,
    gross_rev_output_tokens         NUMERIC(18, 6)      NOT NULL DEFAULT 0,
    gross_rev_cache_read_tokens     NUMERIC(18, 6)      NOT NULL DEFAULT 0,
    gross_rev_cache_write_tokens    NUMERIC(18, 6)      NOT NULL DEFAULT 0,

    -- Revenue Adjustments (applied in silver to derive net)
    savings_plan                    NUMERIC(18, 6)      NOT NULL DEFAULT 0,
    discount_amount                 NUMERIC(18, 6)      NOT NULL DEFAULT 0,

    -- Pricing Context
    currency_code                   VARCHAR(3)          NOT NULL DEFAULT 'USD',  -- ISO 4217
    billing_type                    VARCHAR(50)         NOT NULL,                -- pay-as-you-go, savings-plan, committed-use

    -- Date
    revenue_date                    DATE                NOT NULL,

    -- Metadata
    snapshot_date                   DATE                NOT NULL,

    -- Audit Columns
    loaded_at                       TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
    source_file                     VARCHAR(500)

);

-- =============================================================================
-- Indexes
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_account_id
    ON raw_bronze.revenue_account_daily (account_id);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_model_variant
    ON raw_bronze.revenue_account_daily (model_variant);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_product_sku
    ON raw_bronze.revenue_account_daily (product_sku);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_region
    ON raw_bronze.revenue_account_daily (region);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_revenue_date
    ON raw_bronze.revenue_account_daily (revenue_date DESC);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_snapshot_date
    ON raw_bronze.revenue_account_daily (snapshot_date DESC);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_inference_scope
    ON raw_bronze.revenue_account_daily (inference_scope);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_billing_type
    ON raw_bronze.revenue_account_daily (billing_type);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_currency_code
    ON raw_bronze.revenue_account_daily (currency_code);

-- Composite index for the most common query pattern:
-- revenue by account + model + date range
CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_account_model_date
    ON raw_bronze.revenue_account_daily (account_id, model_variant, revenue_date DESC);

-- =============================================================================
-- Table Comment
-- =============================================================================

COMMENT ON TABLE raw_bronze.revenue_account_daily IS
'Daily revenue at account + product_sku + model_variant + inference_scope + region grain.
Gross revenue is split by token type (input, output, cache_read, cache_write).
savings_plan and discount_amount are stored as positive values and subtracted in silver.
Net revenue is derived in the silver layer: SUM(gross_rev_*) - savings_plan - discount_amount.
Append-only. Snapshot history preserved via snapshot_date.
account_id references customer_details.account_id (FK enforced in silver layer).
model_variant references config_model_dimensions.model_variant (FK enforced in silver layer).';

-- =============================================================================
-- Column Comments
-- =============================================================================

COMMENT ON COLUMN raw_bronze.revenue_account_daily.product_sku IS
'Product catalog ID linking to the pricing/product catalog. Separate from model_variant.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.inference_scope IS
'Inference routing scope: global, regional, multi-region. Aligns with config_model_dimensions.inference_scope.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_input_tokens IS
'Gross revenue attributable to input token consumption before any adjustments.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_output_tokens IS
'Gross revenue attributable to output token consumption before any adjustments.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_cache_read_tokens IS
'Gross revenue attributable to cache read token consumption before any adjustments.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_cache_write_tokens IS
'Gross revenue attributable to cache write token consumption before any adjustments.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.savings_plan IS
'Savings plan credits applied to this account on this date. Subtracted in silver to derive net revenue.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.discount_amount IS
'Discounts applied (negotiated, promotional, or volume-based). Subtracted in silver to derive net revenue.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.currency_code IS
'ISO 4217 currency code (e.g. USD, GBP, EUR). Required for multi-currency aggregation in silver.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.billing_type IS
'Billing model: pay-as-you-go, savings-plan, committed-use.';

-- =============================================================================
-- VERIFICATION
-- =============================================================================

SELECT
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'raw_bronze'
  AND tablename = 'revenue_account_daily';

SELECT
    schemaname,
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'raw_bronze'
  AND tablename = 'revenue_account_daily'
ORDER BY indexname;

-- =============================================================================
-- USAGE NOTES
-- =============================================================================

/*
Append-Only Pattern:
- Never UPDATE or DELETE records
- Always INSERT new records with updated snapshot_date
- Preserves full revenue history for auditing

Net Revenue Derivation (Silver Layer):
SELECT
    account_id,
    model_variant,
    revenue_date,
    SUM(gross_rev_input_tokens
      + gross_rev_output_tokens
      + gross_rev_cache_read_tokens
      + gross_rev_cache_write_tokens)      AS total_gross_revenue,
    SUM(savings_plan)                      AS total_savings_plan,
    SUM(discount_amount)                   AS total_discount,
    SUM(gross_rev_input_tokens
      + gross_rev_output_tokens
      + gross_rev_cache_read_tokens
      + gross_rev_cache_write_tokens
      - savings_plan
      - discount_amount)                   AS net_revenue
FROM raw_bronze.revenue_account_daily
GROUP BY account_id, model_variant, revenue_date;

Querying Latest Snapshot:
SELECT * FROM raw_bronze.revenue_account_daily
WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM raw_bronze.revenue_account_daily);

Multi-Currency Aggregation (Silver Layer):
- Always convert to a base currency (USD) before aggregating across accounts
- Use currency_code to join to an exchange rate table in silver
*/
