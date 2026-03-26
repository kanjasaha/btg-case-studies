-- ============================================================
-- 000_setup_all.sql
-- Combined database setup script.
-- Merges: 001_setup_database.sql
--         002_create_bronze_tables.sql
--         003_create_revenue_account_daily.sql
--         004_create_quota_customer_rate_limit_requests.sql
--
-- Safe to run multiple times — uses IF NOT EXISTS throughout.
-- Run order matters: schemas and roles must exist before tables.
-- ============================================================


-- ============================================================
-- PART 1: Schemas, Roles, and Grants
-- Source: 001_setup_database.sql
-- ============================================================

-- ── Schemas ──────────────────────────────────────────────────
CREATE SCHEMA IF NOT EXISTS raw_bronze;        -- raw data, never modified
CREATE SCHEMA IF NOT EXISTS seeds;             -- dbt-managed static lookup tables
CREATE SCHEMA IF NOT EXISTS staging_silver;    -- dbt transformation models
CREATE SCHEMA IF NOT EXISTS staging_silver_ds; -- data science model outputs
CREATE SCHEMA IF NOT EXISTS mart_gold;         -- business-ready metrics

-- ── Roles ────────────────────────────────────────────────────
-- The DO block handles IF NOT EXISTS — PostgreSQL does not support
-- CREATE ROLE IF NOT EXISTS natively.
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'data_engineer') THEN
    CREATE ROLE data_engineer;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analytics_engineer') THEN
    CREATE ROLE analytics_engineer;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'data_scientist') THEN
    CREATE ROLE data_scientist;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'business_user') THEN
    CREATE ROLE business_user;
  END IF;
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'partner_dw_engineer') THEN
    CREATE ROLE partner_dw_engineer;
  END IF;
END
$$;

-- ── Schema-level grants ───────────────────────────────────────

-- mds_user: GRANT ALL so dbt can create tables in every schema
GRANT ALL ON SCHEMA raw_bronze        TO mds_user;
GRANT ALL ON SCHEMA seeds             TO mds_user;
GRANT ALL ON SCHEMA staging_silver    TO mds_user;
GRANT ALL ON SCHEMA staging_silver_ds TO mds_user;
GRANT ALL ON SCHEMA mart_gold         TO mds_user;

-- data_engineer: full schema access everywhere
GRANT ALL ON SCHEMA raw_bronze        TO data_engineer;
GRANT ALL ON SCHEMA seeds             TO data_engineer;
GRANT ALL ON SCHEMA staging_silver    TO data_engineer;
GRANT ALL ON SCHEMA staging_silver_ds TO data_engineer;
GRANT ALL ON SCHEMA mart_gold         TO data_engineer;

-- analytics_engineer: read bronze/seeds, full access to silver and gold
GRANT USAGE ON SCHEMA raw_bronze        TO analytics_engineer;
GRANT USAGE ON SCHEMA seeds             TO analytics_engineer;
GRANT ALL   ON SCHEMA staging_silver    TO analytics_engineer;
GRANT ALL   ON SCHEMA staging_silver_ds TO analytics_engineer;
GRANT ALL   ON SCHEMA mart_gold         TO analytics_engineer;

-- data_scientist: read everywhere, write only to staging_silver_ds
GRANT USAGE ON SCHEMA raw_bronze        TO data_scientist;
GRANT USAGE ON SCHEMA seeds             TO data_scientist;
GRANT USAGE ON SCHEMA staging_silver    TO data_scientist;
GRANT ALL   ON SCHEMA staging_silver_ds TO data_scientist;
GRANT USAGE ON SCHEMA mart_gold         TO data_scientist;

-- business_user: gold schema only, read-only
GRANT USAGE ON SCHEMA mart_gold TO business_user;

-- partner_dw_engineer: seeds and staging_silver usage only
GRANT USAGE ON SCHEMA seeds          TO partner_dw_engineer;
GRANT USAGE ON SCHEMA staging_silver TO partner_dw_engineer;


-- ============================================================
-- PART 2: Bronze Tables (original 10)
-- Source: 002_create_bronze_tables.sql
-- ============================================================

-- ── TABLE 1: Model Configuration ─────────────────────────────
-- Technical specs of each AI model: replicas, memory, accelerator type.
-- Source: database/config/model_configuration.json (loaded by Airflow DAG)
CREATE TABLE IF NOT EXISTS raw_bronze.config_model_dimensions (
    publisher_name           VARCHAR(100)   NOT NULL,
    model_display_name       VARCHAR(200)   NOT NULL,
    model_resource_name      VARCHAR(200)   NOT NULL,
    model_family             VARCHAR(100)   NOT NULL,
    model_variant            VARCHAR(200)   NOT NULL,
    model_version            VARCHAR(100)   NOT NULL,
    model_task               VARCHAR(100)   NOT NULL,
    inference_scope          VARCHAR(50)    NOT NULL,
    is_open_source           BOOLEAN        NOT NULL,
    replicas                 INTEGER        NOT NULL,
    max_concurrency          INTEGER        NOT NULL,
    ideal_concurrency        INTEGER        NOT NULL,
    max_rps                  INTEGER        NOT NULL,
    accelerator_type         VARCHAR(100)   NOT NULL,
    accelerators_per_replica INTEGER        NOT NULL,
    memory_gb                INTEGER        NOT NULL,
    endpoint                 TEXT           NOT NULL,
    tokens_per_second        BIGINT         NOT NULL,
    avg_tokens_per_request   INTEGER        NOT NULL,
    avg_latency_seconds      DECIMAL(10,4)  NOT NULL,
    snapshot_date            DATE           NOT NULL,
    loaded_at                TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    source_file              VARCHAR(500)   DEFAULT 'model_configuration.json',
    CONSTRAINT config_model_dim_unique UNIQUE (model_variant, snapshot_date)
);
CREATE INDEX IF NOT EXISTS idx_config_dim_variant  ON raw_bronze.config_model_dimensions(model_variant);
CREATE INDEX IF NOT EXISTS idx_config_dim_snapshot ON raw_bronze.config_model_dimensions(snapshot_date DESC);
COMMENT ON TABLE raw_bronze.config_model_dimensions IS 'Raw model config. Append-only. Source: model_configuration.json';


-- ── TABLE 2: Model Region Availability ───────────────────────
-- Which models are deployed in which regions.
-- Source: database/config/model_region_availability.json (loaded by Airflow DAG)
-- Note: routing_strategy and inference_region from the JSON are derived in silver.
CREATE TABLE IF NOT EXISTS raw_bronze.config_model_region_availability (
    model_variant  VARCHAR(200)  NOT NULL,
    source_region  VARCHAR(50)   NOT NULL,
    deployed_at    TIMESTAMP     NOT NULL,
    is_active      BOOLEAN       NOT NULL,
    snapshot_date  DATE          NOT NULL,
    loaded_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    source_file    VARCHAR(500)  DEFAULT 'model_region_availability.json',
    CONSTRAINT config_region_unique UNIQUE (model_variant, source_region, snapshot_date)
);
CREATE INDEX IF NOT EXISTS idx_config_region_variant  ON raw_bronze.config_model_region_availability(model_variant);
CREATE INDEX IF NOT EXISTS idx_config_region_region   ON raw_bronze.config_model_region_availability(source_region);
CREATE INDEX IF NOT EXISTS idx_config_region_snapshot ON raw_bronze.config_model_region_availability(snapshot_date DESC);
COMMENT ON TABLE raw_bronze.config_model_region_availability IS 'Raw regional availability. Source: model_region_availability.json';


-- ── TABLE 3: Customer Details ─────────────────────────────────
-- Customer dimension data from CRM systems (Salesforce, HubSpot).
CREATE TABLE IF NOT EXISTS raw_bronze.customer_details (
    account_id    VARCHAR(50)   NOT NULL,
    company_id    VARCHAR(50)   NOT NULL,
    company_name  VARCHAR(255)  NOT NULL,
    account_name  VARCHAR(255)  NOT NULL,
    account_size  VARCHAR(50),
    segment       VARCHAR(100),
    vertical      VARCHAR(100),
    account_owner VARCHAR(255),
    account_email VARCHAR(255),
    city          VARCHAR(100),
    country       VARCHAR(100),
    is_active     BOOLEAN       DEFAULT TRUE,
    cs_score      NUMERIC(5,2),
    is_fraud      BOOLEAN       DEFAULT FALSE,
    date_created  TIMESTAMP     NOT NULL DEFAULT NOW(),
    date_updated  TIMESTAMP     NOT NULL DEFAULT NOW(),
    data_source   VARCHAR(100),
    loaded_at     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT customer_details_unique UNIQUE (account_id, company_id)
);
CREATE INDEX IF NOT EXISTS idx_customer_company  ON raw_bronze.customer_details(company_id);
CREATE INDEX IF NOT EXISTS idx_customer_active   ON raw_bronze.customer_details(is_active);
CREATE INDEX IF NOT EXISTS idx_customer_country  ON raw_bronze.customer_details(country);
CREATE INDEX IF NOT EXISTS idx_customer_segment  ON raw_bronze.customer_details(segment);
COMMENT ON TABLE raw_bronze.customer_details IS 'Raw customer dimension from CRM. One row per account.';


-- ── TABLE 4: Token Usage — Open Source Models ────────────────
-- Request-level event log. Each row = one inference request.
CREATE TABLE IF NOT EXISTS raw_bronze.inference_user_token_usage_open_source (
    request_id        VARCHAR(100)  NOT NULL,
    account_id        VARCHAR(50)   NOT NULL,
    api_name          VARCHAR(200)  NOT NULL,
    model_variant     VARCHAR(200)  NOT NULL,
    input_token       INTEGER       NOT NULL,
    output_token      INTEGER       NOT NULL,
    cache_read_token  INTEGER       NOT NULL DEFAULT 0,
    cache_write_token INTEGER       NOT NULL DEFAULT 0,
    source_region     VARCHAR(50)   NOT NULL,
    inference_region  VARCHAR(50)   NOT NULL,
    traffic_type      VARCHAR(50)   NOT NULL,
    latency_ms        INTEGER,
    error_code        VARCHAR(50),
    inference_scope   VARCHAR(50),
    event_timestamp   TIMESTAMP     NOT NULL,
    local_timestamp   TIMESTAMP,
    loaded_at         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_token_os_account   ON raw_bronze.inference_user_token_usage_open_source(account_id);
CREATE INDEX IF NOT EXISTS idx_token_os_model     ON raw_bronze.inference_user_token_usage_open_source(model_variant);
CREATE INDEX IF NOT EXISTS idx_token_os_timestamp ON raw_bronze.inference_user_token_usage_open_source(event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_token_os_region    ON raw_bronze.inference_user_token_usage_open_source(source_region);
COMMENT ON TABLE raw_bronze.inference_user_token_usage_open_source IS 'Raw inference events for open source models. Each row = one request.';


-- ── TABLE 5: Token Usage — Proprietary Models ────────────────
-- Same structure as open source — separate table for different business rules.
CREATE TABLE IF NOT EXISTS raw_bronze.inference_user_token_usage_proprietary (
    request_id        VARCHAR(100)  NOT NULL,
    account_id        VARCHAR(50)   NOT NULL,
    api_name          VARCHAR(200)  NOT NULL,
    model_variant     VARCHAR(200)  NOT NULL,
    input_token       INTEGER       NOT NULL,
    output_token      INTEGER       NOT NULL,
    cache_read_token  INTEGER       NOT NULL DEFAULT 0,
    cache_write_token INTEGER       NOT NULL DEFAULT 0,
    source_region     VARCHAR(50)   NOT NULL,
    inference_region  VARCHAR(50)   NOT NULL,
    traffic_type      VARCHAR(50)   NOT NULL,
    latency_ms        INTEGER,
    error_code        VARCHAR(50),
    inference_scope   VARCHAR(50),
    event_timestamp   TIMESTAMP     NOT NULL,
    local_timestamp   TIMESTAMP,
    loaded_at         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_token_prop_account   ON raw_bronze.inference_user_token_usage_proprietary(account_id);
CREATE INDEX IF NOT EXISTS idx_token_prop_model     ON raw_bronze.inference_user_token_usage_proprietary(model_variant);
CREATE INDEX IF NOT EXISTS idx_token_prop_timestamp ON raw_bronze.inference_user_token_usage_proprietary(event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_token_prop_region    ON raw_bronze.inference_user_token_usage_proprietary(source_region);
COMMENT ON TABLE raw_bronze.inference_user_token_usage_proprietary IS 'Raw inference events for proprietary models. Each row = one request.';


-- ── TABLE 6: GPU Accelerator Inventory ───────────────────────
-- GPU supply snapshots. Instance lifecycle: idle → warmpool → used
CREATE TABLE IF NOT EXISTS raw_bronze.resource_accelerator_inventory (
    odcr                  VARCHAR(100)  NOT NULL,
    total_instance        INTEGER       NOT NULL,
    idle_instance         INTEGER       NOT NULL,
    warmpool_instance     INTEGER       NOT NULL,
    used_instance         INTEGER       NOT NULL,
    instance_type         VARCHAR(100)  NOT NULL,
    platform              VARCHAR(100)  NOT NULL,
    region                VARCHAR(50)   NOT NULL,
    service_account_id    VARCHAR(100),
    consumer_account_id   VARCHAR(50),
    consumer_account_name VARCHAR(255),
    event_timestamp       TIMESTAMP     NOT NULL,
    loaded_at             TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_gpu_inv_region    ON raw_bronze.resource_accelerator_inventory(region);
CREATE INDEX IF NOT EXISTS idx_gpu_inv_type      ON raw_bronze.resource_accelerator_inventory(instance_type);
CREATE INDEX IF NOT EXISTS idx_gpu_inv_timestamp ON raw_bronze.resource_accelerator_inventory(event_timestamp DESC);
COMMENT ON TABLE raw_bronze.resource_accelerator_inventory IS 'GPU supply snapshots. idle → warmpool → used.';


-- ── TABLE 7: Model Utilization ────────────────────────────────
-- Pod-level utilization. util_ratio = actual_concurrency / pod_max_concurrency
CREATE TABLE IF NOT EXISTS raw_bronze.resource_model_utilization (
    pod_id              VARCHAR(200)   NOT NULL,
    pod_name            VARCHAR(200)   NOT NULL,
    model_variant       VARCHAR(200)   NOT NULL,
    instance_id         VARCHAR(100)   NOT NULL,
    instance_role       VARCHAR(50)    NOT NULL,   -- classifier or sampler
    pod_max_concurrency INTEGER        NOT NULL,
    actual_concurrency  INTEGER        NOT NULL,
    util_ratio          NUMERIC(5,4)   NOT NULL,   -- 0.0000 to 1.0000
    region              VARCHAR(50)    NOT NULL,
    status              VARCHAR(50)    NOT NULL,
    event_timestamp     TIMESTAMP      NOT NULL,
    loaded_at           TIMESTAMP      DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_model_util_variant   ON raw_bronze.resource_model_utilization(model_variant);
CREATE INDEX IF NOT EXISTS idx_model_util_region    ON raw_bronze.resource_model_utilization(region);
CREATE INDEX IF NOT EXISTS idx_model_util_timestamp ON raw_bronze.resource_model_utilization(event_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_model_util_role      ON raw_bronze.resource_model_utilization(instance_role);
COMMENT ON TABLE raw_bronze.resource_model_utilization IS 'Pod-level utilization. util_ratio = actual / max. instance_role: classifier or sampler.';


-- ── TABLE 8: Model Instance Allocation ───────────────────────
-- How many instances are allocated to each model vs sitting in warmpool.
CREATE TABLE IF NOT EXISTS raw_bronze.resource_model_instance_allocation (
    model_variant      VARCHAR(200)  NOT NULL,
    region             VARCHAR(50)   NOT NULL,
    instance_type      VARCHAR(100)  NOT NULL,
    used_instances     INTEGER       NOT NULL,   -- assigned to this model
    warmpool_instances INTEGER       NOT NULL,   -- ready but unassigned
    event_timestamp    TIMESTAMP     NOT NULL,
    loaded_at          TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_model_alloc_variant   ON raw_bronze.resource_model_instance_allocation(model_variant);
CREATE INDEX IF NOT EXISTS idx_model_alloc_region    ON raw_bronze.resource_model_instance_allocation(region);
CREATE INDEX IF NOT EXISTS idx_model_alloc_timestamp ON raw_bronze.resource_model_instance_allocation(event_timestamp DESC);
COMMENT ON TABLE raw_bronze.resource_model_instance_allocation IS 'Instance allocation per model. used = assigned, warmpool = ready but unassigned.';


-- ── TABLE 9: Default Rate Limits ──────────────────────────────
-- Default RPM/TPM/TPD limits per model, scope, and region.
-- Applies to customers without a custom adjustment.
CREATE TABLE IF NOT EXISTS raw_bronze.quota_default_rate_limits (
    model_variant       VARCHAR(200)  NOT NULL,
    inference_scope     VARCHAR(50)   NOT NULL,
    source_region       VARCHAR(50)   NOT NULL,
    requests_per_minute INTEGER       NOT NULL,
    tokens_per_minute   BIGINT        NOT NULL,
    tokens_per_day      BIGINT        NOT NULL,
    snapshot_date       DATE          NOT NULL,
    loaded_at           TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    source_file         VARCHAR(500)
);
CREATE INDEX IF NOT EXISTS idx_quota_default_model    ON raw_bronze.quota_default_rate_limits(model_variant);
CREATE INDEX IF NOT EXISTS idx_quota_default_scope    ON raw_bronze.quota_default_rate_limits(inference_scope);
CREATE INDEX IF NOT EXISTS idx_quota_default_region   ON raw_bronze.quota_default_rate_limits(source_region);
CREATE INDEX IF NOT EXISTS idx_quota_default_snapshot ON raw_bronze.quota_default_rate_limits(snapshot_date DESC);
COMMENT ON TABLE raw_bronze.quota_default_rate_limits IS 'Default rate limits per model/scope/region. Applies to customers without a custom adjustment.';


-- ── TABLE 10: Customer Rate Limit Adjustments ────────────────
-- Per-customer limit overrides — higher or lower than the default.
CREATE TABLE IF NOT EXISTS raw_bronze.quota_customer_rate_limit_adjustments (
    account_id          VARCHAR(50)   NOT NULL,
    model_variant       VARCHAR(200)  NOT NULL,
    inference_scope     VARCHAR(50)   NOT NULL,
    source_region       VARCHAR(50)   NOT NULL,
    requests_per_minute INTEGER       NOT NULL,
    tokens_per_minute   BIGINT        NOT NULL,
    tokens_per_day      BIGINT        NOT NULL,
    adjustment_reason   TEXT,
    ticket_link         VARCHAR(500),
    approved_by         VARCHAR(200),
    effective_date      DATE,
    expiry_date         DATE,          -- NULL = no expiry
    snapshot_date       DATE          NOT NULL,
    loaded_at           TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    source_file         VARCHAR(500)
);
CREATE INDEX IF NOT EXISTS idx_quota_adj_account  ON raw_bronze.quota_customer_rate_limit_adjustments(account_id);
CREATE INDEX IF NOT EXISTS idx_quota_adj_model    ON raw_bronze.quota_customer_rate_limit_adjustments(model_variant);
CREATE INDEX IF NOT EXISTS idx_quota_adj_region   ON raw_bronze.quota_customer_rate_limit_adjustments(source_region);
CREATE INDEX IF NOT EXISTS idx_quota_adj_snapshot ON raw_bronze.quota_customer_rate_limit_adjustments(snapshot_date DESC);
COMMENT ON TABLE raw_bronze.quota_customer_rate_limit_adjustments IS 'Per-customer rate limit overrides. NULL expiry_date = no expiry.';


-- ============================================================
-- PART 3: Revenue Account Daily Table
-- Source: 003_create_revenue_account_daily.sql
-- ============================================================

-- ── TABLE 11: Daily Account Revenue ──────────────────────────
-- Grain: account_id + product_sku + model_variant + inference_scope +
--        region + billing_type + currency_code + revenue_date
CREATE TABLE IF NOT EXISTS raw_bronze.revenue_account_daily (

    -- Customer Reference
    account_id                      VARCHAR(50)         NOT NULL,

    -- Product Reference
    product_sku                     VARCHAR(200)        NOT NULL,
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
    currency_code                   VARCHAR(3)          NOT NULL DEFAULT 'USD',
    billing_type                    VARCHAR(50)         NOT NULL,

    -- Date
    revenue_date                    DATE                NOT NULL,

    -- Metadata
    snapshot_date                   DATE                NOT NULL,

    -- Audit
    loaded_at                       TIMESTAMP           DEFAULT CURRENT_TIMESTAMP,
    source_file                     VARCHAR(500)

);

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
CREATE INDEX IF NOT EXISTS idx_rev_acct_daily_account_model_date
    ON raw_bronze.revenue_account_daily (account_id, model_variant, revenue_date DESC);

COMMENT ON TABLE raw_bronze.revenue_account_daily IS
'Daily revenue at account + product_sku + model_variant + inference_scope + region grain.
Gross revenue split by token type. Net revenue derived in silver: SUM(gross_rev_*) - savings_plan - discount_amount.
Append-only. Snapshot history preserved via snapshot_date.';

COMMENT ON COLUMN raw_bronze.revenue_account_daily.product_sku IS 'Product catalog ID linking to the pricing/product catalog.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.inference_scope IS 'Inference routing scope: global, regional, multi-region.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_input_tokens IS 'Gross revenue from input token consumption before adjustments.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_output_tokens IS 'Gross revenue from output token consumption before adjustments.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_cache_read_tokens IS 'Gross revenue from cache read token consumption before adjustments.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.gross_rev_cache_write_tokens IS 'Gross revenue from cache write token consumption before adjustments.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.savings_plan IS 'Savings plan credits applied. Subtracted in silver to derive net revenue.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.discount_amount IS 'Discounts applied. Subtracted in silver to derive net revenue.';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.currency_code IS 'ISO 4217 currency code (e.g. USD, GBP, EUR).';
COMMENT ON COLUMN raw_bronze.revenue_account_daily.billing_type IS 'Billing model: pay-as-you-go, savings-plan, committed-use.';


-- ============================================================
-- PART 4: Customer Rate Limit Requests Table
-- Source: 004_create_quota_customer_rate_limit_requests.sql
-- ============================================================

-- ── TABLE 12: Customer Rate Limit Requests ───────────────────
-- Grain: one row per customer rate limit request.
-- Approved requests flow into quota_customer_rate_limit_adjustments.
CREATE TABLE IF NOT EXISTS raw_bronze.quota_customer_rate_limit_requests (

    -- Identity
    account_id              VARCHAR(50)     NOT NULL,

    -- Request Details
    limit_type              VARCHAR(50)     NOT NULL,   -- upgrade, downgrade
    inference_scope         VARCHAR(50)     NOT NULL,   -- global, regional, multi-region
    model_variant           VARCHAR(100)    NOT NULL,
    source_region           VARCHAR(50)     NOT NULL,

    -- Requested Limits
    requests_per_minute     INTEGER,
    tokens_per_minute       BIGINT,
    tokens_per_day          BIGINT,

    -- Request Lifecycle
    status                  VARCHAR(20)     NOT NULL
                                CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    created_by              VARCHAR(100)    NOT NULL,
    create_datetime         TIMESTAMP       NOT NULL,
    last_updated            TIMESTAMP       NOT NULL,

    -- Metadata
    loaded_at               TIMESTAMP       NOT NULL    DEFAULT NOW(),
    source_file             VARCHAR(255)

);

CREATE INDEX IF NOT EXISTS idx_qlr_account_id
    ON raw_bronze.quota_customer_rate_limit_requests (account_id);
CREATE INDEX IF NOT EXISTS idx_qlr_model_variant
    ON raw_bronze.quota_customer_rate_limit_requests (model_variant);
CREATE INDEX IF NOT EXISTS idx_qlr_status
    ON raw_bronze.quota_customer_rate_limit_requests (status);
CREATE INDEX IF NOT EXISTS idx_qlr_create_datetime
    ON raw_bronze.quota_customer_rate_limit_requests (create_datetime);
CREATE INDEX IF NOT EXISTS idx_qlr_source_region
    ON raw_bronze.quota_customer_rate_limit_requests (source_region);

COMMENT ON TABLE raw_bronze.quota_customer_rate_limit_requests IS
'Customer requests to change rate limits. Approved requests flow into quota_customer_rate_limit_adjustments.';


-- ============================================================
-- VERIFICATION
-- ============================================================

SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname = 'raw_bronze'
ORDER BY tablename;

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('raw_bronze','seeds','staging_silver','staging_silver_ds','mart_gold')
ORDER BY schema_name;
