-- ============================================================
-- 999_teardown.sql
-- Tears down everything created by 000_setup_all.sql.
-- THREE LEVELS — run only what you need:
--
--   LEVEL 1: TRUNCATE all tables   — wipes all data, keeps structure
--   LEVEL 2: DROP all tables       — removes tables and indexes
--   LEVEL 3: DROP schemas and roles — removes everything
--
-- WARNING: These operations are IRREVERSIBLE.
-- Run each section deliberately — do not run the whole file at once.
-- ============================================================


-- ============================================================
-- LEVEL 1: TRUNCATE ALL TABLES
-- Wipes all data from every bronze table.
-- Keeps table structure, indexes, and constraints intact.
-- Use this to reset data without rebuilding the schema.
-- ============================================================

/*

TRUNCATE TABLE raw_bronze.config_model_dimensions                  RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.config_model_region_availability         RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.customer_details                         RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.inference_user_token_usage_open_source   RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.inference_user_token_usage_proprietary   RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.resource_accelerator_inventory           RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.resource_model_utilization               RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.resource_model_instance_allocation       RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.quota_default_rate_limits                RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.quota_customer_rate_limit_adjustments    RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.revenue_account_daily                    RESTART IDENTITY CASCADE;
TRUNCATE TABLE raw_bronze.quota_customer_rate_limit_requests       RESTART IDENTITY CASCADE;

*/


-- ============================================================
-- LEVEL 2: DROP ALL TABLES
-- Removes all tables and their indexes from raw_bronze.
-- CASCADE drops any dependent views or foreign key constraints.
-- Use this when you want to rebuild the schema from scratch.
-- ============================================================

/*

DROP TABLE IF EXISTS raw_bronze.config_model_dimensions                  CASCADE;
DROP TABLE IF EXISTS raw_bronze.config_model_region_availability         CASCADE;
DROP TABLE IF EXISTS raw_bronze.customer_details                         CASCADE;
DROP TABLE IF EXISTS raw_bronze.inference_user_token_usage_open_source   CASCADE;
DROP TABLE IF EXISTS raw_bronze.inference_user_token_usage_proprietary   CASCADE;
DROP TABLE IF EXISTS raw_bronze.resource_accelerator_inventory           CASCADE;
DROP TABLE IF EXISTS raw_bronze.resource_model_utilization               CASCADE;
DROP TABLE IF EXISTS raw_bronze.resource_model_instance_allocation       CASCADE;
DROP TABLE IF EXISTS raw_bronze.quota_default_rate_limits                CASCADE;
DROP TABLE IF EXISTS raw_bronze.quota_customer_rate_limit_adjustments    CASCADE;
DROP TABLE IF EXISTS raw_bronze.revenue_account_daily                    CASCADE;
DROP TABLE IF EXISTS raw_bronze.quota_customer_rate_limit_requests       CASCADE;

*/


-- ============================================================
-- LEVEL 3: DROP SCHEMAS AND ROLES
-- Removes all schemas created by 001_setup_database.sql.
-- CASCADE drops all tables, views, and objects inside each schema.
-- Run LEVEL 2 first, or use CASCADE to drop everything together.
-- ============================================================

/*

-- Drop all schemas (CASCADE removes all objects inside)
DROP SCHEMA IF EXISTS raw_bronze        CASCADE;
DROP SCHEMA IF EXISTS seeds             CASCADE;
DROP SCHEMA IF EXISTS staging_silver    CASCADE;
DROP SCHEMA IF EXISTS staging_silver_ds CASCADE;
DROP SCHEMA IF EXISTS mart_gold         CASCADE;

-- Drop all roles
DROP ROLE IF EXISTS data_engineer;
DROP ROLE IF EXISTS analytics_engineer;
DROP ROLE IF EXISTS data_scientist;
DROP ROLE IF EXISTS business_user;
DROP ROLE IF EXISTS partner_dw_engineer;

*/


-- ============================================================
-- VERIFICATION
-- Run after any level to confirm what remains.
-- ============================================================

-- Check remaining schemas
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('raw_bronze','seeds','staging_silver','staging_silver_ds','mart_gold')
ORDER BY schema_name;

-- Check remaining tables
SELECT schemaname, tablename
FROM pg_tables
WHERE schemaname = 'raw_bronze'
ORDER BY tablename;

-- Check remaining roles
SELECT rolname
FROM pg_roles
WHERE rolname IN ('data_engineer','analytics_engineer','data_scientist','business_user','partner_dw_engineer')
ORDER BY rolname;
