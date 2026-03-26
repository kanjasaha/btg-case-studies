-- =============================================================================
-- Bronze Table: quota_customer_rate_limit_requests
-- =============================================================================
-- Grain: one row per customer rate limit request
-- Source: internal request management system
-- Schema: raw_bronze
-- =============================================================================

CREATE TABLE IF NOT EXISTS raw_bronze.quota_customer_rate_limit_requests (
    -- Identity
    account_id              VARCHAR(50)     NOT NULL,
    
    -- Request Details
    limit_type              VARCHAR(50)     NOT NULL,   -- e.g. upgrade, downgrade
    inference_scope         VARCHAR(50)     NOT NULL,   -- global, regional, multi-region
    model_variant           VARCHAR(100)    NOT NULL,
    source_region           VARCHAR(50)     NOT NULL,

    -- Requested Limits
    requests_per_minute     INTEGER,                    -- requested RPM
    tokens_per_minute       BIGINT,                     -- requested TPM
    tokens_per_day          BIGINT,                     -- requested TPD

    -- Request Lifecycle
    status                  VARCHAR(20)     NOT NULL    -- pending, approved, rejected, cancelled
                                CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
    created_by              VARCHAR(100)    NOT NULL,
    create_datetime         TIMESTAMP       NOT NULL,
    last_updated            TIMESTAMP       NOT NULL,

    -- Metadata
    loaded_at               TIMESTAMP       NOT NULL    DEFAULT NOW(),
    source_file             VARCHAR(255)
);

-- Indexes
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
