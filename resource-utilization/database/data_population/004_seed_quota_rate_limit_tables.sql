-- =============================================================================
-- Seed Data: quota_default_rate_limits & quota_customer_rate_limit_adjustments
-- =============================================================================
-- Date: 2026-02-25
-- Author: Data Engineering Team
-- Purpose: Populate rate limit tables using model configuration and region
--          availability as the source of truth.
--
-- Logic:
--   quota_default_rate_limits
--     → One row per active model_variant + source_region + inference_scope
--     → Limits derived from model capacity metrics in config_model_dimensions
--       (max_rps → requests_per_minute, tokens_per_second → tokens_per_minute/day)
--     → Only active regions from config_model_region_availability (is_active = TRUE)
--
--   quota_customer_rate_limit_adjustments
--     → One row per customer who has been granted a non-default limit
--     → Strategic (Enterprise) accounts seeded with higher limits
--     → One account seeded with a lower limit (risk/fraud scenario)
--     → Limits expressed as a multiplier over the default
--
-- Snapshot date: 2026-01-13 (aligns with seed data in 003_seed_bronze_tables.sql)
-- =============================================================================


-- =============================================================================
-- TABLE 1: quota_default_rate_limits
-- =============================================================================
-- Derived from:
--   config_model_dimensions   → capacity metrics (max_rps, tokens_per_second)
--   config_model_region_availability → active regions per model
--
-- Rate limit derivation logic:
--   requests_per_minute = max_rps * 60
--   tokens_per_minute   = ROUND(tokens_per_second / replicas * ideal_concurrency / 1000) * 1000
--   tokens_per_day      = tokens_per_minute * 60 * 24
--
-- These are conservative defaults — a fraction of total platform capacity
-- allocated per customer to ensure fair use across all accounts.
-- =============================================================================

INSERT INTO raw_bronze.quota_default_rate_limits (
    model_variant,
    inference_scope,
    source_region,
    requests_per_minute,
    tokens_per_minute,
    tokens_per_day,
    snapshot_date,
    source_file
)

-- Derived from config_model_dimensions + config_model_region_availability
-- Using active regions only (is_active = TRUE)

SELECT
    mra.model_variant,
    cmd.inference_scope,
    mra.source_region,

    -- requests_per_minute: max_rps * 60, capped at a per-customer default
    -- Conservative default: 10% of max_rps * 60 to allow fair multi-tenant sharing
    GREATEST(60, ROUND((cmd.max_rps * 60 * 0.10) / 10.0) * 10)     AS requests_per_minute,

    -- tokens_per_minute: derived from tokens_per_second scaled to per-customer share
    -- Assumes up to 100 concurrent customers sharing capacity (1% of total)
    GREATEST(10000, ROUND((cmd.tokens_per_second * 60 * 0.01) / 1000.0) * 1000)
                                                                      AS tokens_per_minute,

    -- tokens_per_day: tokens_per_minute * 60 * 24
    GREATEST(10000, ROUND((cmd.tokens_per_second * 60 * 0.01) / 1000.0) * 1000) * 60 * 24
                                                                      AS tokens_per_day,

    '2026-01-13'::DATE                                                AS snapshot_date,
    'derived:config_model_dimensions+config_model_region_availability' AS source_file

FROM raw_bronze.config_model_region_availability mra
JOIN raw_bronze.config_model_dimensions cmd
    ON mra.model_variant = cmd.model_variant

WHERE mra.is_active = TRUE

-- Use latest snapshot for each table to avoid duplicates from historical loads
  AND mra.snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM raw_bronze.config_model_region_availability
        WHERE model_variant = mra.model_variant
          AND source_region = mra.source_region
  )
  AND cmd.snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM raw_bronze.config_model_dimensions
        WHERE model_variant = cmd.model_variant
  )

ORDER BY mra.model_variant, mra.source_region;


-- =============================================================================
-- TABLE 2: quota_customer_rate_limit_adjustments
-- =============================================================================
-- Seeded for customers who have been granted non-default limits.
-- Source accounts from customer_details (003_seed_bronze_tables.sql):
--
--   ACC001 Acme AI Corp       Enterprise / Strategic  → 5x default (high volume FinTech)
--   ACC002 DataStream Inc     Enterprise / Strategic  → 3x default (SaaS platform)
--   ACC005 GlobalBank Ltd     Enterprise / Strategic  → 5x default (regulated, high volume)
--   ACC007 AsiaPay Systems    Enterprise / Strategic  → 3x default (APAC FinTech)
--   ACC010 CloudNative Co     Enterprise / Strategic  → 3x default (SaaS)
--   ACC009 RetailBoost Ltd    SMB / inactive          → 0.5x default (risk reduction)
--
-- Limits are expressed relative to quota_default_rate_limits values.
-- Only models and regions actively used by each account
-- (based on inference_user_token_usage_proprietary seed data).
-- =============================================================================

INSERT INTO raw_bronze.quota_customer_rate_limit_adjustments (
    account_id,
    model_variant,
    inference_scope,
    source_region,
    requests_per_minute,
    tokens_per_minute,
    tokens_per_day,
    adjustment_reason,
    ticket_link,
    approved_by,
    effective_date,
    expiry_date,
    snapshot_date,
    source_file
)
VALUES

-- ---------------------------------------------------------------------------
-- ACC001: Acme AI Corp — Enterprise Strategic FinTech
-- Models used: claude-sonnet-4, claude-3.5-sonnet | Region: us-east-1
-- Adjustment: 5x default limits
-- ---------------------------------------------------------------------------
(
    'ACC001',
    'claude-sonnet-4_200k_20250514',
    'global',
    'us-east-1',
    18000,          -- 5x default RPM
    36000000,       -- 5x default TPM
    51840000000,    -- 5x default TPD
    'Enterprise Strategic account with high-volume FinTech workloads requiring sustained throughput above default tier',
    'https://tickets.internal/QUOTA-1001',
    'CS-Enterprise-Team',
    '2025-06-01',
    NULL,
    '2026-01-13',
    'manual:cs-enterprise-team'
),
(
    'ACC001',
    'claude-3.5-sonnet_200k_20241022',
    'global',
    'us-east-1',
    16500,
    33000000,
    47520000000,
    'Enterprise Strategic account with high-volume FinTech workloads requiring sustained throughput above default tier',
    'https://tickets.internal/QUOTA-1002',
    'CS-Enterprise-Team',
    '2025-06-01',
    NULL,
    '2026-01-13',
    'manual:cs-enterprise-team'
),

-- ---------------------------------------------------------------------------
-- ACC002: DataStream Inc — Enterprise Strategic SaaS
-- Models used: gpt-4o | Region: us-west-2
-- Adjustment: 3x default limits
-- ---------------------------------------------------------------------------
(
    'ACC002',
    'gpt-4o_128k_20240513',
    'global',
    'us-west-2',
    10800,          -- 3x default RPM
    21600000,       -- 3x default TPM
    31104000000,    -- 3x default TPD
    'SaaS platform embedding model into customer-facing product with predictable high-volume batch processing needs',
    'https://tickets.internal/QUOTA-1003',
    'CS-Enterprise-Team',
    '2025-07-15',
    NULL,
    '2026-01-13',
    'manual:cs-enterprise-team'
),

-- ---------------------------------------------------------------------------
-- ACC005: GlobalBank Ltd — Enterprise Strategic FinTech (UK)
-- Models used: claude-3-opus, claude-sonnet-4 | Region: eu-west-1
-- Adjustment: 5x default limits (regulated industry SLA requirements)
-- ---------------------------------------------------------------------------
(
    'ACC005',
    'claude-3-opus_200k_20240229',
    'multi-region',
    'eu-west-1',
    10500,          -- 5x default RPM
    22500000,       -- 5x default TPM
    32400000000,    -- 5x default TPD
    'Regulated financial institution with SLA-backed processing requirements and data residency constraints in EU',
    'https://tickets.internal/QUOTA-1004',
    'CS-Enterprise-Team',
    '2025-05-12',
    NULL,
    '2026-01-13',
    'manual:cs-enterprise-team'
),
(
    'ACC005',
    'claude-sonnet-4_200k_20250514',
    'global',
    'eu-west-1',
    18000,
    36000000,
    51840000000,
    'Regulated financial institution with SLA-backed processing requirements and data residency constraints in EU',
    'https://tickets.internal/QUOTA-1005',
    'CS-Enterprise-Team',
    '2025-08-01',
    NULL,
    '2026-01-13',
    'manual:cs-enterprise-team'
),

-- ---------------------------------------------------------------------------
-- ACC007: AsiaPay Systems — Enterprise Strategic FinTech (APAC)
-- Models used: claude-sonnet-4 | Region: ap-northeast-1
-- Adjustment: 3x default limits
-- ---------------------------------------------------------------------------
(
    'ACC007',
    'claude-sonnet-4_200k_20250514',
    'global',
    'ap-northeast-1',
    10800,          -- 3x default RPM
    21600000,       -- 3x default TPM
    31104000000,    -- 3x default TPD
    'APAC FinTech with peak transaction processing demands during Asian market hours',
    'https://tickets.internal/QUOTA-1006',
    'CS-Enterprise-Team',
    '2025-09-01',
    NULL,
    '2026-01-13',
    'manual:cs-enterprise-team'
),

-- ---------------------------------------------------------------------------
-- ACC010: CloudNative Co — Enterprise Strategic SaaS
-- Models used: claude-3.5-sonnet | Region: us-west-2
-- Adjustment: 3x default limits
-- ---------------------------------------------------------------------------
(
    'ACC010',
    'claude-3.5-sonnet_200k_20241022',
    'global',
    'us-west-2',
    10800,
    21600000,
    31104000000,
    'Cloud-native SaaS platform with multi-tenant architecture driving sustained inference volume across customer base',
    'https://tickets.internal/QUOTA-1007',
    'CS-Enterprise-Team',
    '2025-10-01',
    NULL,
    '2026-01-13',
    'manual:cs-enterprise-team'
),

-- ---------------------------------------------------------------------------
-- ACC009: RetailBoost Ltd — SMB / Inactive (risk reduction)
-- Models used: gpt-4o, claude-3.5-sonnet | Region: eu-west-1
-- Adjustment: 0.5x default limits (downward adjustment due to account risk)
-- is_active = FALSE in customer_details; limits reduced pending review
-- ---------------------------------------------------------------------------
(
    'ACC009',
    'gpt-4o_128k_20240513',
    'global',
    'eu-west-1',
    1800,           -- 0.5x default RPM
    3600000,        -- 0.5x default TPM
    5184000000,     -- 0.5x default TPD
    'Account flagged inactive with unresolved billing issues; limits reduced pending account review and reactivation',
    'https://tickets.internal/QUOTA-1008',
    'Risk-and-Trust-Team',
    '2025-06-15',
    '2026-03-01',   -- expiry: limits reinstated if account reactivates
    '2026-01-13',
    'manual:risk-and-trust-team'
),
(
    'ACC009',
    'claude-3.5-sonnet_200k_20241022',
    'global',
    'eu-west-1',
    1650,
    3300000,
    4752000000,
    'Account flagged inactive with unresolved billing issues; limits reduced pending account review and reactivation',
    'https://tickets.internal/QUOTA-1009',
    'Risk-and-Trust-Team',
    '2025-06-15',
    '2026-03-01',
    '2026-01-13',
    'manual:risk-and-trust-team'
);


-- =============================================================================
-- VERIFICATION
-- =============================================================================

SELECT
    'quota_default_rate_limits'             AS table_name,
    COUNT(*)                                AS row_count,
    COUNT(DISTINCT model_variant)           AS distinct_models,
    COUNT(DISTINCT source_region)           AS distinct_regions,
    COUNT(DISTINCT inference_scope)         AS distinct_scopes
FROM raw_bronze.quota_default_rate_limits

UNION ALL

SELECT
    'quota_customer_rate_limit_adjustments' AS table_name,
    COUNT(*)                                AS row_count,
    COUNT(DISTINCT model_variant)           AS distinct_models,
    COUNT(DISTINCT source_region)           AS distinct_regions,
    COUNT(DISTINCT inference_scope)         AS distinct_scopes
FROM raw_bronze.quota_customer_rate_limit_adjustments;


-- Preview default limits by model and region
SELECT
    model_variant,
    inference_scope,
    source_region,
    requests_per_minute,
    tokens_per_minute,
    tokens_per_day,
    snapshot_date
FROM raw_bronze.quota_default_rate_limits
ORDER BY model_variant, source_region;


-- Preview customer adjustments with direction (upgrade vs reduction)
SELECT
    c.account_id,
    c.model_variant,
    c.source_region,
    c.requests_per_minute,
    c.tokens_per_minute,
    CASE
        WHEN d.requests_per_minute IS NULL THEN 'no default found'
        WHEN c.requests_per_minute > d.requests_per_minute THEN 'upgrade'
        WHEN c.requests_per_minute < d.requests_per_minute THEN 'reduction'
        ELSE 'same as default'
    END                                     AS adjustment_direction,
    ROUND(c.requests_per_minute::NUMERIC / NULLIF(d.requests_per_minute, 0), 1)
                                            AS rpm_multiplier_vs_default,
    c.effective_date,
    c.expiry_date,
    c.approved_by
FROM raw_bronze.quota_customer_rate_limit_adjustments c
LEFT JOIN raw_bronze.quota_default_rate_limits d
    ON  c.model_variant   = d.model_variant
    AND c.source_region   = d.source_region
    AND c.inference_scope = d.inference_scope
ORDER BY account_id, model_variant;
