-- =============================================================================
-- 003_create_revenue_account_daily.sql
-- Database: btg_nocode_ml_journey
-- =============================================================================
-- Date: 2026-03-23
-- Author: Data Engineering Team
-- Purpose: Append-only daily revenue table at account + ml_product_sku + region grain
-- Source: Billing system / revenue recognition pipeline
-- =============================================================================

-- =============================================================================
-- TABLE: revenue_account_daily
-- =============================================================================
-- Grain: account_id + ml_product_sku + region + revenue_date
--
-- Revenue components:
--   gross_revenue    → total gross revenue before adjustments
--   savings_plan     → savings plan credits applied (negative impact on net)
--   discount_amount  → discounts applied (negative impact on net)
--
-- Net revenue is derived in the silver layer:
--   net_revenue = gross_revenue - savings_plan - discount_amount
-- =============================================================================

CREATE TABLE IF NOT EXISTS raw_bronze.revenue_account_daily (

    -- Customer Reference
    account_id              VARCHAR(50)     NOT NULL,

    -- Product Reference
    ml_product_sku          VARCHAR(200)    NOT NULL,   -- ML service product catalog ID

    -- Region
    region                  VARCHAR(50)     NOT NULL,

    -- Revenue
    revenue_date            DATE            NOT NULL,
    gross_revenue           NUMERIC(18,6)   NOT NULL DEFAULT 0,

    -- Revenue Adjustments (applied in silver to derive net)
    savings_plan            NUMERIC(18,6)   NOT NULL DEFAULT 0,
    discount_amount         NUMERIC(18,6)   NOT NULL DEFAULT 0,

    -- Pricing Context
    currency_code           VARCHAR(3)      NOT NULL DEFAULT 'USD',  -- ISO 4217
    billing_type            VARCHAR(50)     NOT NULL,                -- subscription | usage | hybrid

    -- Metadata
    snapshot_date           DATE            NOT NULL,

    -- Audit Columns
    loaded_at               TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    source_file             VARCHAR(500)

);

-- =============================================================================
-- Indexes
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_account_id
    ON raw_bronze.revenue_account_daily (account_id);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_ml_product_sku
    ON raw_bronze.revenue_account_daily (ml_product_sku);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_region
    ON raw_bronze.revenue_account_daily (region);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_revenue_date
    ON raw_bronze.revenue_account_daily (revenue_date DESC);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_snapshot_date
    ON raw_bronze.revenue_account_daily (snapshot_date DESC);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_billing_type
    ON raw_bronze.revenue_account_daily (billing_type);

CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_currency_code
    ON raw_bronze.revenue_account_daily (currency_code);

-- Composite index for the most common query pattern:
-- revenue by account + ml_product_sku + date range
CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_account_sku_date
    ON raw_bronze.revenue_account_daily (account_id, ml_product_sku, revenue_date DESC);

-- =============================================================================
-- Table and Column Comments
-- =============================================================================

COMMENT ON TABLE raw_bronze.revenue_account_daily IS
'Daily revenue at account + ml_product_sku + region grain.
savings_plan and discount_amount are stored as positive values and subtracted in silver.
Net revenue is derived in the silver layer: gross_revenue - savings_plan - discount_amount.
Append-only. Snapshot history preserved via snapshot_date.
account_id references customer_details.account_id (FK enforced in silver layer).
ml_product_sku references ml_service_catalog.ml_product_sku (FK enforced in silver layer).';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.ml_product_sku IS
'ML service product catalog ID — uniquely identifies the ML service and pricing configuration.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_revenue IS
'Total gross revenue before any adjustments. Net revenue derived in silver.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.savings_plan IS
'Savings plan credits applied to this account on this date. Subtracted in silver to derive net revenue.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.discount_amount IS
'Discounts applied (negotiated, promotional, or volume-based). Subtracted in silver to derive net revenue.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.currency_code IS
'ISO 4217 currency code (e.g. USD, GBP, EUR). Required for multi-currency aggregation in silver.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.billing_type IS
'Billing model: subscription | usage | hybrid.';

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
    ml_product_sku,
    region,
    revenue_date,
    SUM(gross_revenue)                   AS total_gross_revenue,
    SUM(savings_plan)                    AS total_savings_plan,
    SUM(discount_amount)                 AS total_discount,
    SUM(gross_revenue
      - savings_plan
      - discount_amount)                 AS net_revenue
FROM raw_bronze.revenue_account_daily
GROUP BY account_id, ml_product_sku, region, revenue_date;

Querying Latest Snapshot:
SELECT * FROM raw_bronze.revenue_account_daily
WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM raw_bronze.revenue_account_daily);

Multi-Currency Aggregation (Silver Layer):
- Always convert to a base currency (USD) before aggregating across accounts
- Use currency_code to join to an exchange rate table in silver
*/
