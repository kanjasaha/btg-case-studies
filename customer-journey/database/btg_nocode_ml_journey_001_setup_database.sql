-- =============================================================================
-- 001_setup_database.sql
-- Database: btg_nocode_ml_journey
-- =============================================================================
-- Date: 2026-03-23
-- Author: Data Engineering Team
-- Purpose: Creates schemas, roles, and schema-level grants only.
-- Table-level grants are handled by dbt post-hooks.
-- Safe to run multiple times — uses IF NOT EXISTS throughout.
-- =============================================================================

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

-- partner_dw_engineer: seeds and staging_silver only
-- table-level SELECT granted via post-hook on specific models only
GRANT USAGE ON SCHEMA seeds          TO partner_dw_engineer;
GRANT USAGE ON SCHEMA staging_silver TO partner_dw_engineer;

-- ── Verification ──────────────────────────────────────────────
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('raw_bronze','seeds','staging_silver','staging_silver_ds','mart_gold')
ORDER BY schema_name;
