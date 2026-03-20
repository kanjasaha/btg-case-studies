-- ============================================================
-- 002_create_bronze_tables.sql
-- Creates all 10 raw landing tables in raw_bronze schema.
-- Append-only: never UPDATE or DELETE rows in bronze.
-- Safe to run multiple times — uses IF NOT EXISTS throughout.
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


-- ── Verification ──────────────────────────────────────────────
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname = 'raw_bronze'
ORDER BY tablename;