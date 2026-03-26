-- ============================================================
-- 000_populate_all.sql
-- Combined data population script for the full bronze layer.
-- Lives in: database/data_population/
--
-- Run order matters — execute in this sequence:
--   PART 1 (003): customer_details, resource tables,
--                 token usage open source & proprietary
--   PART 2 (004): quota_default_rate_limits,
--                 quota_customer_rate_limit_adjustments
--                 (depends on config tables loaded by Airflow DAG)
--   PART 3 (005): revenue_account_daily
--                 (depends on token usage tables from Part 1)
--   PART 4 (006): quota_customer_rate_limit_requests
--
-- Prerequisites:
--   - 000_setup_all.sql must have been run first
--   - Airflow DAG load_config_bronze must have been triggered
--     (loads config_model_dimensions and config_model_region_availability)
--   - Date range: 2026-01-13 to 2026-02-26
--   - Accounts: ACC001 - ACC010
-- ============================================================


-- ============================================================
-- PART 1: Core Bronze Seed Data
-- Source: 003_seed_bronze_tables.sql
-- Tables: customer_details, resource_accelerator_inventory,
--         resource_model_instance_allocation, resource_model_utilization,
--         inference_user_token_usage_open_source,
--         inference_user_token_usage_proprietary
-- ============================================================

-- =============================================================================
-- Bronze Layer Seed Data - January 2026 (7 days: Jan 13-19)
-- =============================================================================
-- Date range: 2026-01-13 to 2026-01-19
-- Customers: ACC001 - ACC010
-- Data Integrity:
--   - model_variant references config_model_dimensions.model_variant
--   - region references config_model_region_availability.source_region
--   - instance_type references config_model_dimensions.accelerator_type
--   - account_id references customer_details.account_id
--   - inference_scope references config_model_dimensions.inference_scope
-- =============================================================================

-- =============================================================================
-- TABLE 1: customer_details
-- =============================================================================

INSERT INTO raw_bronze.customer_details (
    account_id, company_id, company_name, account_name,
    account_size, segment, vertical,
    account_owner, account_email,
    city, country,
    is_active, cs_score, is_fraud,
    date_created, date_updated, data_source
) VALUES
    ('ACC001', 'COMP001', 'Acme AI Corp',        'Acme AI Corp - Main',      'Enterprise',  'Strategic',  'FinTech',    'Alice Johnson', 'alice@acme.com',       'New York',      'US', TRUE,  87.50, FALSE, '2024-01-15', '2025-12-01', 'salesforce'),
    ('ACC002', 'COMP002', 'DataStream Inc',       'DataStream - Enterprise',  'Enterprise',  'Strategic',  'SaaS',       'Bob Smith',     'bob@datastream.com',   'San Francisco', 'US', TRUE,  92.00, FALSE, '2024-02-20', '2025-11-15', 'salesforce'),
    ('ACC003', 'COMP003', 'HealthAI Solutions',   'HealthAI - Commercial',    'Mid-Market',  'Commercial', 'HealthTech', 'Carol White',   'carol@healthai.com',   'Boston',        'US', TRUE,  78.25, FALSE, '2024-03-10', '2025-10-20', 'hubspot'),
    ('ACC004', 'COMP004', 'Nexus Analytics',      'Nexus - SMB',              'SMB',         'Commercial', 'Analytics',  'David Lee',     'david@nexus.com',      'Austin',        'US', TRUE,  65.00, FALSE, '2024-04-05', '2025-09-30', 'hubspot'),
    ('ACC005', 'COMP005', 'GlobalBank Ltd',       'GlobalBank - Enterprise',  'Enterprise',  'Strategic',  'FinTech',    'Emma Brown',    'emma@globalbank.com',  'London',        'UK', TRUE,  95.75, FALSE, '2024-05-12', '2025-12-10', 'salesforce'),
    ('ACC006', 'COMP006', 'TechVision GmbH',      'TechVision - Mid',         'Mid-Market',  'Commercial', 'SaaS',       'Franz Mueller', 'franz@techvision.de',  'Berlin',        'DE', TRUE,  71.50, FALSE, '2024-06-18', '2025-08-25', 'salesforce'),
    ('ACC007', 'COMP007', 'AsiaPay Systems',      'AsiaPay - Enterprise',     'Enterprise',  'Strategic',  'FinTech',    'Grace Kim',     'grace@asiapay.com',    'Singapore',     'SG', TRUE,  88.00, FALSE, '2024-07-22', '2025-11-05', 'salesforce'),
    ('ACC008', 'COMP008', 'MediCore AI',          'MediCore - Commercial',    'Mid-Market',  'Commercial', 'HealthTech', 'Henry Park',    'henry@medicore.com',   'Toronto',       'CA', TRUE,  74.25, FALSE, '2024-08-30', '2025-07-15', 'hubspot'),
    ('ACC009', 'COMP009', 'RetailBoost Ltd',      'RetailBoost - SMB',        'SMB',         'Commercial', 'Retail',     'Isabel Santos', 'isabel@retail.com',    'Madrid',        'ES', FALSE, 45.00, FALSE, '2024-09-14', '2025-06-01', 'hubspot'),
    ('ACC010', 'COMP010', 'CloudNative Co',       'CloudNative - Enterprise', 'Enterprise',  'Strategic',  'SaaS',       'James Wilson',  'james@cloudnative.com','Seattle',       'US', TRUE,  91.00, FALSE, '2024-10-01', '2025-12-15', 'salesforce')
ON CONFLICT (account_id, company_id) DO NOTHING;

-- =============================================================================
-- TABLE 2: resource_accelerator_inventory (daily snapshots Jan 13-19)
-- =============================================================================

INSERT INTO raw_bronze.resource_accelerator_inventory (
    odcr, total_instance, idle_instance, warmpool_instance, used_instance,
    instance_type, platform, region,
    service_account_id, consumer_account_id, consumer_account_name,
    event_timestamp
) VALUES
-- Jan 13
('ODCR-US-E1-001', 100, 5,  15, 80, 'A100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC001', 'Acme AI Corp',       '2026-01-13 08:00:00'),
('ODCR-US-W2-001', 80,  4,  16, 60, 'A100',  'AWS', 'us-west-2',      'svc-acc-002', 'ACC001', 'Acme AI Corp',       '2026-01-13 08:00:00'),
('ODCR-EU-W1-001', 60,  3,  12, 45, 'A100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC006', 'TechVision GmbH',    '2026-01-13 08:00:00'),
('ODCR-US-E1-002', 50,  2,  8,  40, 'H100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC002', 'DataStream Inc',     '2026-01-13 08:00:00'),
('ODCR-EU-W1-002', 20,  1,  3,  16, 'H100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC005', 'GlobalBank Ltd',     '2026-01-13 08:00:00'),
('ODCR-AP-NE1-001',40,  2,  8,  30, 'A10',   'AWS', 'ap-northeast-1', 'svc-acc-004', 'ACC007', 'AsiaPay Systems',    '2026-01-13 08:00:00'),
('ODCR-CA-C1-001', 20,  1,  4,  15, 'A10',   'AWS', 'ca-central-1',   'svc-acc-005', 'ACC008', 'MediCore AI',        '2026-01-13 08:00:00'),
-- Jan 14
('ODCR-US-E1-001', 100, 4,  14, 82, 'A100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC001', 'Acme AI Corp',       '2026-01-14 08:00:00'),
('ODCR-US-W2-001', 80,  3,  15, 62, 'A100',  'AWS', 'us-west-2',      'svc-acc-002', 'ACC001', 'Acme AI Corp',       '2026-01-14 08:00:00'),
('ODCR-EU-W1-001', 60,  2,  11, 47, 'A100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC006', 'TechVision GmbH',    '2026-01-14 08:00:00'),
('ODCR-US-E1-002', 50,  2,  7,  41, 'H100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC002', 'DataStream Inc',     '2026-01-14 08:00:00'),
('ODCR-EU-W1-002', 20,  1,  2,  17, 'H100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC005', 'GlobalBank Ltd',     '2026-01-14 08:00:00'),
('ODCR-AP-NE1-001',40,  2,  7,  31, 'A10',   'AWS', 'ap-northeast-1', 'svc-acc-004', 'ACC007', 'AsiaPay Systems',    '2026-01-14 08:00:00'),
('ODCR-CA-C1-001', 20,  1,  3,  16, 'A10',   'AWS', 'ca-central-1',   'svc-acc-005', 'ACC008', 'MediCore AI',        '2026-01-14 08:00:00'),
-- Jan 15
('ODCR-US-E1-001', 100, 3,  13, 84, 'A100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC001', 'Acme AI Corp',       '2026-01-15 08:00:00'),
('ODCR-US-W2-001', 80,  3,  14, 63, 'A100',  'AWS', 'us-west-2',      'svc-acc-002', 'ACC001', 'Acme AI Corp',       '2026-01-15 08:00:00'),
('ODCR-EU-W1-001', 60,  2,  10, 48, 'A100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC006', 'TechVision GmbH',    '2026-01-15 08:00:00'),
('ODCR-US-E1-002', 50,  1,  7,  42, 'H100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC002', 'DataStream Inc',     '2026-01-15 08:00:00'),
('ODCR-EU-W1-002', 20,  0,  2,  18, 'H100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC005', 'GlobalBank Ltd',     '2026-01-15 08:00:00'),
('ODCR-AP-NE1-001',40,  1,  7,  32, 'A10',   'AWS', 'ap-northeast-1', 'svc-acc-004', 'ACC007', 'AsiaPay Systems',    '2026-01-15 08:00:00'),
('ODCR-CA-C1-001', 20,  0,  3,  17, 'A10',   'AWS', 'ca-central-1',   'svc-acc-005', 'ACC008', 'MediCore AI',        '2026-01-15 08:00:00'),
-- Jan 16
('ODCR-US-E1-001', 100, 5,  16, 79, 'A100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC001', 'Acme AI Corp',       '2026-01-16 08:00:00'),
('ODCR-US-W2-001', 80,  4,  16, 60, 'A100',  'AWS', 'us-west-2',      'svc-acc-002', 'ACC001', 'Acme AI Corp',       '2026-01-16 08:00:00'),
('ODCR-EU-W1-001', 60,  3,  12, 45, 'A100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC006', 'TechVision GmbH',    '2026-01-16 08:00:00'),
('ODCR-US-E1-002', 50,  2,  8,  40, 'H100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC002', 'DataStream Inc',     '2026-01-16 08:00:00'),
('ODCR-EU-W1-002', 20,  1,  3,  16, 'H100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC005', 'GlobalBank Ltd',     '2026-01-16 08:00:00'),
('ODCR-AP-NE1-001',40,  2,  8,  30, 'A10',   'AWS', 'ap-northeast-1', 'svc-acc-004', 'ACC007', 'AsiaPay Systems',    '2026-01-16 08:00:00'),
('ODCR-CA-C1-001', 20,  1,  4,  15, 'A10',   'AWS', 'ca-central-1',   'svc-acc-005', 'ACC008', 'MediCore AI',        '2026-01-16 08:00:00'),
-- Jan 17
('ODCR-US-E1-001', 100, 6,  17, 77, 'A100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC001', 'Acme AI Corp',       '2026-01-17 08:00:00'),
('ODCR-US-W2-001', 80,  5,  18, 57, 'A100',  'AWS', 'us-west-2',      'svc-acc-002', 'ACC001', 'Acme AI Corp',       '2026-01-17 08:00:00'),
('ODCR-EU-W1-001', 60,  4,  14, 42, 'A100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC006', 'TechVision GmbH',    '2026-01-17 08:00:00'),
('ODCR-US-E1-002', 50,  3,  9,  38, 'H100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC002', 'DataStream Inc',     '2026-01-17 08:00:00'),
('ODCR-EU-W1-002', 20,  2,  4,  14, 'H100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC005', 'GlobalBank Ltd',     '2026-01-17 08:00:00'),
('ODCR-AP-NE1-001',40,  3,  9,  28, 'A10',   'AWS', 'ap-northeast-1', 'svc-acc-004', 'ACC007', 'AsiaPay Systems',    '2026-01-17 08:00:00'),
('ODCR-CA-C1-001', 20,  2,  5,  13, 'A10',   'AWS', 'ca-central-1',   'svc-acc-005', 'ACC008', 'MediCore AI',        '2026-01-17 08:00:00'),
-- Jan 18
('ODCR-US-E1-001', 100, 7,  18, 75, 'A100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC001', 'Acme AI Corp',       '2026-01-18 08:00:00'),
('ODCR-US-W2-001', 80,  5,  17, 58, 'A100',  'AWS', 'us-west-2',      'svc-acc-002', 'ACC001', 'Acme AI Corp',       '2026-01-18 08:00:00'),
('ODCR-EU-W1-001', 60,  3,  13, 44, 'A100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC006', 'TechVision GmbH',    '2026-01-18 08:00:00'),
('ODCR-US-E1-002', 50,  2,  8,  40, 'H100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC002', 'DataStream Inc',     '2026-01-18 08:00:00'),
('ODCR-EU-W1-002', 20,  1,  3,  16, 'H100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC005', 'GlobalBank Ltd',     '2026-01-18 08:00:00'),
('ODCR-AP-NE1-001',40,  2,  8,  30, 'A10',   'AWS', 'ap-northeast-1', 'svc-acc-004', 'ACC007', 'AsiaPay Systems',    '2026-01-18 08:00:00'),
('ODCR-CA-C1-001', 20,  1,  4,  15, 'A10',   'AWS', 'ca-central-1',   'svc-acc-005', 'ACC008', 'MediCore AI',        '2026-01-18 08:00:00'),
-- Jan 19
('ODCR-US-E1-001', 100, 4,  14, 82, 'A100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC001', 'Acme AI Corp',       '2026-01-19 08:00:00'),
('ODCR-US-W2-001', 80,  3,  15, 62, 'A100',  'AWS', 'us-west-2',      'svc-acc-002', 'ACC001', 'Acme AI Corp',       '2026-01-19 08:00:00'),
('ODCR-EU-W1-001', 60,  2,  11, 47, 'A100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC006', 'TechVision GmbH',    '2026-01-19 08:00:00'),
('ODCR-US-E1-002', 50,  1,  7,  42, 'H100',  'AWS', 'us-east-1',      'svc-acc-001', 'ACC002', 'DataStream Inc',     '2026-01-19 08:00:00'),
('ODCR-EU-W1-002', 20,  0,  2,  18, 'H100',  'AWS', 'eu-west-1',      'svc-acc-003', 'ACC005', 'GlobalBank Ltd',     '2026-01-19 08:00:00'),
('ODCR-AP-NE1-001',40,  1,  7,  32, 'A10',   'AWS', 'ap-northeast-1', 'svc-acc-004', 'ACC007', 'AsiaPay Systems',    '2026-01-19 08:00:00'),
('ODCR-CA-C1-001', 20,  0,  3,  17, 'A10',   'AWS', 'ca-central-1',   'svc-acc-005', 'ACC008', 'MediCore AI',        '2026-01-19 08:00:00');

-- =============================================================================
-- TABLE 3: resource_model_instance_allocation (daily snapshots Jan 13-19)
-- =============================================================================

INSERT INTO raw_bronze.resource_model_instance_allocation (
    model_variant, region, instance_type, used_instances, warmpool_instances, event_timestamp
) VALUES
-- Jan 13
('gpt-4o_128k_20240513',            'us-east-1',      'A100', 20, 5,  '2026-01-13 08:00:00'),
('gpt-4o_128k_20240513',            'us-west-2',      'A100', 15, 3,  '2026-01-13 08:00:00'),
('gpt-4o_128k_20240513',            'eu-west-1',      'A100', 12, 4,  '2026-01-13 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'us-east-1',      'H100', 10, 2,  '2026-01-13 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'eu-west-1',      'H100', 6,  1,  '2026-01-13 08:00:00'),
('claude-3-haiku_200k_20240307',    'us-east-1',      'A10',  15, 4,  '2026-01-13 08:00:00'),
('claude-3-haiku_200k_20240307',    'ap-northeast-1', 'A10',  8,  2,  '2026-01-13 08:00:00'),
('llama-3.1_70b_20240723',          'us-east-1',      'A100', 10, 3,  '2026-01-13 08:00:00'),
('llama-3.1_70b_20240723',          'eu-west-1',      'A100', 6,  2,  '2026-01-13 08:00:00'),
('claude-sonnet-4_200k_20250514',   'us-east-1',      'H100', 10, 3,  '2026-01-13 08:00:00'),
-- Jan 14
('gpt-4o_128k_20240513',            'us-east-1',      'A100', 22, 4,  '2026-01-14 08:00:00'),
('gpt-4o_128k_20240513',            'us-west-2',      'A100', 16, 3,  '2026-01-14 08:00:00'),
('gpt-4o_128k_20240513',            'eu-west-1',      'A100', 13, 3,  '2026-01-14 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'us-east-1',      'H100', 11, 2,  '2026-01-14 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'eu-west-1',      'H100', 7,  1,  '2026-01-14 08:00:00'),
('claude-3-haiku_200k_20240307',    'us-east-1',      'A10',  16, 3,  '2026-01-14 08:00:00'),
('claude-3-haiku_200k_20240307',    'ap-northeast-1', 'A10',  9,  2,  '2026-01-14 08:00:00'),
('llama-3.1_70b_20240723',          'us-east-1',      'A100', 11, 2,  '2026-01-14 08:00:00'),
('llama-3.1_70b_20240723',          'eu-west-1',      'A100', 7,  1,  '2026-01-14 08:00:00'),
('claude-sonnet-4_200k_20250514',   'us-east-1',      'H100', 11, 2,  '2026-01-14 08:00:00'),
-- Jan 15
('gpt-4o_128k_20240513',            'us-east-1',      'A100', 24, 3,  '2026-01-15 08:00:00'),
('gpt-4o_128k_20240513',            'us-west-2',      'A100', 17, 2,  '2026-01-15 08:00:00'),
('gpt-4o_128k_20240513',            'eu-west-1',      'A100', 14, 3,  '2026-01-15 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'us-east-1',      'H100', 12, 1,  '2026-01-15 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'eu-west-1',      'H100', 8,  1,  '2026-01-15 08:00:00'),
('claude-3-haiku_200k_20240307',    'us-east-1',      'A10',  17, 3,  '2026-01-15 08:00:00'),
('claude-3-haiku_200k_20240307',    'ap-northeast-1', 'A10',  10, 1,  '2026-01-15 08:00:00'),
('llama-3.1_70b_20240723',          'us-east-1',      'A100', 12, 2,  '2026-01-15 08:00:00'),
('llama-3.1_70b_20240723',          'eu-west-1',      'A100', 8,  1,  '2026-01-15 08:00:00'),
('claude-sonnet-4_200k_20250514',   'us-east-1',      'H100', 13, 2,  '2026-01-15 08:00:00'),
-- Jan 16
('gpt-4o_128k_20240513',            'us-east-1',      'A100', 20, 5,  '2026-01-16 08:00:00'),
('gpt-4o_128k_20240513',            'us-west-2',      'A100', 15, 4,  '2026-01-16 08:00:00'),
('gpt-4o_128k_20240513',            'eu-west-1',      'A100', 12, 4,  '2026-01-16 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'us-east-1',      'H100', 10, 2,  '2026-01-16 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'eu-west-1',      'H100', 6,  2,  '2026-01-16 08:00:00'),
('claude-3-haiku_200k_20240307',    'us-east-1',      'A10',  15, 4,  '2026-01-16 08:00:00'),
('claude-3-haiku_200k_20240307',    'ap-northeast-1', 'A10',  8,  2,  '2026-01-16 08:00:00'),
('llama-3.1_70b_20240723',          'us-east-1',      'A100', 10, 3,  '2026-01-16 08:00:00'),
('llama-3.1_70b_20240723',          'eu-west-1',      'A100', 6,  2,  '2026-01-16 08:00:00'),
('claude-sonnet-4_200k_20250514',   'us-east-1',      'H100', 10, 3,  '2026-01-16 08:00:00'),
-- Jan 17
('gpt-4o_128k_20240513',            'us-east-1',      'A100', 18, 6,  '2026-01-17 08:00:00'),
('gpt-4o_128k_20240513',            'us-west-2',      'A100', 13, 5,  '2026-01-17 08:00:00'),
('gpt-4o_128k_20240513',            'eu-west-1',      'A100', 10, 5,  '2026-01-17 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'us-east-1',      'H100', 9,  3,  '2026-01-17 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'eu-west-1',      'H100', 5,  2,  '2026-01-17 08:00:00'),
('claude-3-haiku_200k_20240307',    'us-east-1',      'A10',  13, 5,  '2026-01-17 08:00:00'),
('claude-3-haiku_200k_20240307',    'ap-northeast-1', 'A10',  7,  3,  '2026-01-17 08:00:00'),
('llama-3.1_70b_20240723',          'us-east-1',      'A100', 8,  4,  '2026-01-17 08:00:00'),
('llama-3.1_70b_20240723',          'eu-west-1',      'A100', 5,  3,  '2026-01-17 08:00:00'),
('claude-sonnet-4_200k_20250514',   'us-east-1',      'H100', 8,  4,  '2026-01-17 08:00:00'),
-- Jan 18
('gpt-4o_128k_20240513',            'us-east-1',      'A100', 19, 5,  '2026-01-18 08:00:00'),
('gpt-4o_128k_20240513',            'us-west-2',      'A100', 14, 4,  '2026-01-18 08:00:00'),
('gpt-4o_128k_20240513',            'eu-west-1',      'A100', 11, 4,  '2026-01-18 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'us-east-1',      'H100', 10, 2,  '2026-01-18 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'eu-west-1',      'H100', 6,  2,  '2026-01-18 08:00:00'),
('claude-3-haiku_200k_20240307',    'us-east-1',      'A10',  14, 4,  '2026-01-18 08:00:00'),
('claude-3-haiku_200k_20240307',    'ap-northeast-1', 'A10',  8,  2,  '2026-01-18 08:00:00'),
('llama-3.1_70b_20240723',          'us-east-1',      'A100', 9,  3,  '2026-01-18 08:00:00'),
('llama-3.1_70b_20240723',          'eu-west-1',      'A100', 6,  2,  '2026-01-18 08:00:00'),
('claude-sonnet-4_200k_20250514',   'us-east-1',      'H100', 9,  3,  '2026-01-18 08:00:00'),
-- Jan 19
('gpt-4o_128k_20240513',            'us-east-1',      'A100', 21, 4,  '2026-01-19 08:00:00'),
('gpt-4o_128k_20240513',            'us-west-2',      'A100', 16, 3,  '2026-01-19 08:00:00'),
('gpt-4o_128k_20240513',            'eu-west-1',      'A100', 13, 3,  '2026-01-19 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'us-east-1',      'H100', 11, 2,  '2026-01-19 08:00:00'),
('claude-3.5-sonnet_200k_20241022', 'eu-west-1',      'H100', 7,  1,  '2026-01-19 08:00:00'),
('claude-3-haiku_200k_20240307',    'us-east-1',      'A10',  16, 3,  '2026-01-19 08:00:00'),
('claude-3-haiku_200k_20240307',    'ap-northeast-1', 'A10',  9,  2,  '2026-01-19 08:00:00'),
('llama-3.1_70b_20240723',          'us-east-1',      'A100', 11, 2,  '2026-01-19 08:00:00'),
('llama-3.1_70b_20240723',          'eu-west-1',      'A100', 7,  1,  '2026-01-19 08:00:00'),
('claude-sonnet-4_200k_20250514',   'us-east-1',      'H100', 11, 2,  '2026-01-19 08:00:00');

-- =============================================================================
-- TABLE 4: resource_model_utilization (pod level, daily snapshots Jan 13-19)
-- =============================================================================

INSERT INTO raw_bronze.resource_model_utilization (
    pod_id, pod_name, model_variant, instance_id,
    instance_role, pod_max_concurrency, actual_concurrency, util_ratio,
    region, status, event_timestamp
) VALUES
-- Jan 13
('POD-GPT4O-USE1-001','gpt4o-use1-sampler-01',   'gpt-4o_128k_20240513',            'i-0a1b2c001','sampler',    20,16,0.8000,'us-east-1','ready','2026-01-13 08:00:00'),
('POD-GPT4O-USE1-002','gpt4o-use1-sampler-02',   'gpt-4o_128k_20240513',            'i-0a1b2c002','sampler',    20,14,0.7000,'us-east-1','ready','2026-01-13 08:00:00'),
('POD-GPT4O-USE1-003','gpt4o-use1-classifier-01','gpt-4o_128k_20240513',            'i-0a1b2c003','classifier', 50,30,0.6000,'us-east-1','ready','2026-01-13 08:00:00'),
('POD-SON35-USE1-001','son35-use1-sampler-01',   'claude-3.5-sonnet_200k_20241022', 'i-0a1b2c004','sampler',    15,12,0.8000,'us-east-1','ready','2026-01-13 08:00:00'),
('POD-SON35-USE1-002','son35-use1-classifier-01','claude-3.5-sonnet_200k_20241022', 'i-0a1b2c005','classifier', 40,22,0.5500,'us-east-1','ready','2026-01-13 08:00:00'),
('POD-HAI3-USE1-001', 'haiku3-use1-sampler-01',  'claude-3-haiku_200k_20240307',    'i-0a1b2c006','sampler',    25,20,0.8000,'us-east-1','ready','2026-01-13 08:00:00'),
('POD-LLM70-USE1-001','llama70-use1-sampler-01', 'llama-3.1_70b_20240723',          'i-0a1b2c007','sampler',    20,15,0.7500,'us-east-1','ready','2026-01-13 08:00:00'),
('POD-SON4-USE1-001', 'son4-use1-sampler-01',    'claude-sonnet-4_200k_20250514',   'i-0a1b2c008','sampler',    15,13,0.8667,'us-east-1','ready','2026-01-13 08:00:00'),
-- Jan 14
('POD-GPT4O-USE1-001','gpt4o-use1-sampler-01',   'gpt-4o_128k_20240513',            'i-0a1b2c001','sampler',    20,17,0.8500,'us-east-1','ready','2026-01-14 08:00:00'),
('POD-GPT4O-USE1-002','gpt4o-use1-sampler-02',   'gpt-4o_128k_20240513',            'i-0a1b2c002','sampler',    20,15,0.7500,'us-east-1','ready','2026-01-14 08:00:00'),
('POD-GPT4O-USE1-003','gpt4o-use1-classifier-01','gpt-4o_128k_20240513',            'i-0a1b2c003','classifier', 50,33,0.6600,'us-east-1','ready','2026-01-14 08:00:00'),
('POD-SON35-USE1-001','son35-use1-sampler-01',   'claude-3.5-sonnet_200k_20241022', 'i-0a1b2c004','sampler',    15,13,0.8667,'us-east-1','ready','2026-01-14 08:00:00'),
('POD-SON35-USE1-002','son35-use1-classifier-01','claude-3.5-sonnet_200k_20241022', 'i-0a1b2c005','classifier', 40,24,0.6000,'us-east-1','ready','2026-01-14 08:00:00'),
('POD-HAI3-USE1-001', 'haiku3-use1-sampler-01',  'claude-3-haiku_200k_20240307',    'i-0a1b2c006','sampler',    25,21,0.8400,'us-east-1','ready','2026-01-14 08:00:00'),
('POD-LLM70-USE1-001','llama70-use1-sampler-01', 'llama-3.1_70b_20240723',          'i-0a1b2c007','sampler',    20,16,0.8000,'us-east-1','ready','2026-01-14 08:00:00'),
('POD-SON4-USE1-001', 'son4-use1-sampler-01',    'claude-sonnet-4_200k_20250514',   'i-0a1b2c008','sampler',    15,14,0.9333,'us-east-1','ready','2026-01-14 08:00:00'),
-- Jan 15
('POD-GPT4O-USE1-001','gpt4o-use1-sampler-01',   'gpt-4o_128k_20240513',            'i-0a1b2c001','sampler',    20,18,0.9000,'us-east-1','ready','2026-01-15 08:00:00'),
('POD-GPT4O-USE1-002','gpt4o-use1-sampler-02',   'gpt-4o_128k_20240513',            'i-0a1b2c002','sampler',    20,16,0.8000,'us-east-1','ready','2026-01-15 08:00:00'),
('POD-GPT4O-USE1-003','gpt4o-use1-classifier-01','gpt-4o_128k_20240513',            'i-0a1b2c003','classifier', 50,36,0.7200,'us-east-1','ready','2026-01-15 08:00:00'),
('POD-SON35-USE1-001','son35-use1-sampler-01',   'claude-3.5-sonnet_200k_20241022', 'i-0a1b2c004','sampler',    15,14,0.9333,'us-east-1','ready','2026-01-15 08:00:00'),
('POD-SON35-USE1-002','son35-use1-classifier-01','claude-3.5-sonnet_200k_20241022', 'i-0a1b2c005','classifier', 40,27,0.6750,'us-east-1','ready','2026-01-15 08:00:00'),
('POD-HAI3-USE1-001', 'haiku3-use1-sampler-01',  'claude-3-haiku_200k_20240307',    'i-0a1b2c006','sampler',    25,22,0.8800,'us-east-1','ready','2026-01-15 08:00:00'),
('POD-LLM70-USE1-001','llama70-use1-sampler-01', 'llama-3.1_70b_20240723',          'i-0a1b2c007','sampler',    20,17,0.8500,'us-east-1','ready','2026-01-15 08:00:00'),
('POD-SON4-USE1-001', 'son4-use1-sampler-01',    'claude-sonnet-4_200k_20250514',   'i-0a1b2c008','sampler',    15,14,0.9333,'us-east-1','ready','2026-01-15 08:00:00'),
-- Jan 16
('POD-GPT4O-USE1-001','gpt4o-use1-sampler-01',   'gpt-4o_128k_20240513',            'i-0a1b2c001','sampler',    20,15,0.7500,'us-east-1','ready','2026-01-16 08:00:00'),
('POD-GPT4O-USE1-002','gpt4o-use1-sampler-02',   'gpt-4o_128k_20240513',            'i-0a1b2c002','sampler',    20,13,0.6500,'us-east-1','ready','2026-01-16 08:00:00'),
('POD-GPT4O-USE1-003','gpt4o-use1-classifier-01','gpt-4o_128k_20240513',            'i-0a1b2c003','classifier', 50,28,0.5600,'us-east-1','ready','2026-01-16 08:00:00'),
('POD-SON35-USE1-001','son35-use1-sampler-01',   'claude-3.5-sonnet_200k_20241022', 'i-0a1b2c004','sampler',    15,11,0.7333,'us-east-1','ready','2026-01-16 08:00:00'),
('POD-SON35-USE1-002','son35-use1-classifier-01','claude-3.5-sonnet_200k_20241022', 'i-0a1b2c005','classifier', 40,20,0.5000,'us-east-1','ready','2026-01-16 08:00:00'),
('POD-HAI3-USE1-001', 'haiku3-use1-sampler-01',  'claude-3-haiku_200k_20240307',    'i-0a1b2c006','sampler',    25,18,0.7200,'us-east-1','ready','2026-01-16 08:00:00'),
('POD-LLM70-USE1-001','llama70-use1-sampler-01', 'llama-3.1_70b_20240723',          'i-0a1b2c007','sampler',    20,13,0.6500,'us-east-1','ready','2026-01-16 08:00:00'),
('POD-SON4-USE1-001', 'son4-use1-sampler-01',    'claude-sonnet-4_200k_20250514',   'i-0a1b2c008','sampler',    15,11,0.7333,'us-east-1','ready','2026-01-16 08:00:00'),
-- Jan 17
('POD-GPT4O-USE1-001','gpt4o-use1-sampler-01',   'gpt-4o_128k_20240513',            'i-0a1b2c001','sampler',    20,14,0.7000,'us-east-1','ready','2026-01-17 08:00:00'),
('POD-GPT4O-USE1-002','gpt4o-use1-sampler-02',   'gpt-4o_128k_20240513',            'i-0a1b2c002','sampler',    20,12,0.6000,'us-east-1','ready','2026-01-17 08:00:00'),
('POD-GPT4O-USE1-003','gpt4o-use1-classifier-01','gpt-4o_128k_20240513',            'i-0a1b2c003','classifier', 50,26,0.5200,'us-east-1','ready','2026-01-17 08:00:00'),
('POD-SON35-USE1-001','son35-use1-sampler-01',   'claude-3.5-sonnet_200k_20241022', 'i-0a1b2c004','sampler',    15,10,0.6667,'us-east-1','ready','2026-01-17 08:00:00'),
('POD-SON35-USE1-002','son35-use1-classifier-01','claude-3.5-sonnet_200k_20241022', 'i-0a1b2c005','classifier', 40,18,0.4500,'us-east-1','ready','2026-01-17 08:00:00'),
('POD-HAI3-USE1-001', 'haiku3-use1-sampler-01',  'claude-3-haiku_200k_20240307',    'i-0a1b2c006','sampler',    25,17,0.6800,'us-east-1','ready','2026-01-17 08:00:00'),
('POD-LLM70-USE1-001','llama70-use1-sampler-01', 'llama-3.1_70b_20240723',          'i-0a1b2c007','sampler',    20,12,0.6000,'us-east-1','ready','2026-01-17 08:00:00'),
('POD-SON4-USE1-001', 'son4-use1-sampler-01',    'claude-sonnet-4_200k_20250514',   'i-0a1b2c008','sampler',    15,10,0.6667,'us-east-1','ready','2026-01-17 08:00:00'),
-- Jan 18
('POD-GPT4O-USE1-001','gpt4o-use1-sampler-01',   'gpt-4o_128k_20240513',            'i-0a1b2c001','sampler',    20,16,0.8000,'us-east-1','ready','2026-01-18 08:00:00'),
('POD-GPT4O-USE1-002','gpt4o-use1-sampler-02',   'gpt-4o_128k_20240513',            'i-0a1b2c002','sampler',    20,14,0.7000,'us-east-1','ready','2026-01-18 08:00:00'),
('POD-GPT4O-USE1-003','gpt4o-use1-classifier-01','gpt-4o_128k_20240513',            'i-0a1b2c003','classifier', 50,30,0.6000,'us-east-1','ready','2026-01-18 08:00:00'),
('POD-SON35-USE1-001','son35-use1-sampler-01',   'claude-3.5-sonnet_200k_20241022', 'i-0a1b2c004','sampler',    15,12,0.8000,'us-east-1','ready','2026-01-18 08:00:00'),
('POD-SON35-USE1-002','son35-use1-classifier-01','claude-3.5-sonnet_200k_20241022', 'i-0a1b2c005','classifier', 40,22,0.5500,'us-east-1','ready','2026-01-18 08:00:00'),
('POD-HAI3-USE1-001', 'haiku3-use1-sampler-01',  'claude-3-haiku_200k_20240307',    'i-0a1b2c006','sampler',    25,20,0.8000,'us-east-1','ready','2026-01-18 08:00:00'),
('POD-LLM70-USE1-001','llama70-use1-sampler-01', 'llama-3.1_70b_20240723',          'i-0a1b2c007','sampler',    20,15,0.7500,'us-east-1','ready','2026-01-18 08:00:00'),
('POD-SON4-USE1-001', 'son4-use1-sampler-01',    'claude-sonnet-4_200k_20250514',   'i-0a1b2c008','sampler',    15,13,0.8667,'us-east-1','ready','2026-01-18 08:00:00'),
-- Jan 19
('POD-GPT4O-USE1-001','gpt4o-use1-sampler-01',   'gpt-4o_128k_20240513',            'i-0a1b2c001','sampler',    20,17,0.8500,'us-east-1','ready','2026-01-19 08:00:00'),
('POD-GPT4O-USE1-002','gpt4o-use1-sampler-02',   'gpt-4o_128k_20240513',            'i-0a1b2c002','sampler',    20,15,0.7500,'us-east-1','ready','2026-01-19 08:00:00'),
('POD-GPT4O-USE1-003','gpt4o-use1-classifier-01','gpt-4o_128k_20240513',            'i-0a1b2c003','classifier', 50,32,0.6400,'us-east-1','ready','2026-01-19 08:00:00'),
('POD-SON35-USE1-001','son35-use1-sampler-01',   'claude-3.5-sonnet_200k_20241022', 'i-0a1b2c004','sampler',    15,13,0.8667,'us-east-1','ready','2026-01-19 08:00:00'),
('POD-SON35-USE1-002','son35-use1-classifier-01','claude-3.5-sonnet_200k_20241022', 'i-0a1b2c005','classifier', 40,24,0.6000,'us-east-1','ready','2026-01-19 08:00:00'),
('POD-HAI3-USE1-001', 'haiku3-use1-sampler-01',  'claude-3-haiku_200k_20240307',    'i-0a1b2c006','sampler',    25,21,0.8400,'us-east-1','ready','2026-01-19 08:00:00'),
('POD-LLM70-USE1-001','llama70-use1-sampler-01', 'llama-3.1_70b_20240723',          'i-0a1b2c007','sampler',    20,16,0.8000,'us-east-1','ready','2026-01-19 08:00:00'),
('POD-SON4-USE1-001', 'son4-use1-sampler-01',    'claude-sonnet-4_200k_20250514',   'i-0a1b2c008','sampler',    15,14,0.9333,'us-east-1','ready','2026-01-19 08:00:00');

-- =============================================================================
-- TABLE 5: inference_user_token_usage_open_source (Jan 13-19, 10 requests/day)
-- =============================================================================

INSERT INTO raw_bronze.inference_user_token_usage_open_source (
    request_id, account_id, api_name, model_variant,
    input_token, output_token, cache_read_token, cache_write_token,
    source_region, inference_region, traffic_type,
    latency_ms, error_code, inference_scope,
    event_timestamp, local_timestamp
) VALUES
-- Jan 13
('REQ-OS-20260113-001','ACC001','chat/completions','llama-3.1_70b_20240723',     1200,450, 0,  0,  'us-east-1','us-east-1','regional',    320,NULL, 'regional',   '2026-01-13 08:01:00','2026-01-13 03:01:00'),
('REQ-OS-20260113-002','ACC002','chat/completions','llama-3.1_70b_20240723',     800, 300,200, 0,  'us-west-2','us-west-2','regional',    280,NULL, 'regional',   '2026-01-13 09:15:00','2026-01-13 01:15:00'),
('REQ-OS-20260113-003','ACC003','chat/completions','mixtral-8x7b_32k_20231211',  2000,600,0,  400,'eu-west-1','eu-west-1','global',      410,NULL, 'global',     '2026-01-13 10:30:00','2026-01-13 11:30:00'),
('REQ-OS-20260113-004','ACC004','chat/completions','llama-3.1_405b_20240723',    3000,900,0,  0,  'us-east-1','us-west-2','multi-region',850,NULL, 'regional',   '2026-01-13 11:45:00','2026-01-13 06:45:00'),
('REQ-OS-20260113-005','ACC005','chat/completions','mistral-large_128k_20240724',1500,500,300, 0, 'eu-west-1','eu-west-1','multi-region',390,NULL, 'multi-region','2026-01-13 12:00:00','2026-01-13 13:00:00'),
('REQ-OS-20260113-006','ACC006','chat/completions','mixtral-8x7b_32k_20231211',  950,280, 0,  0,  'eu-west-1','eu-west-1','global',      300,NULL, 'global',     '2026-01-13 13:20:00','2026-01-13 14:20:00'),
('REQ-OS-20260113-007','ACC007','chat/completions','llama-3.1_70b_20240723',     1100,420,0,  0,  'us-east-1','us-east-1','regional',    310,NULL, 'regional',   '2026-01-13 14:35:00','2026-01-13 22:35:00'),
('REQ-OS-20260113-008','ACC008','chat/completions','mistral_7b_32k_20240522',    600,200, 0,  0,  'us-east-1','us-east-1','regional',    180,NULL, 'global',     '2026-01-13 15:50:00','2026-01-13 10:50:00'),
('REQ-OS-20260113-009','ACC009','chat/completions','llama-3.1_70b_20240723',     900,320, 0,  0,  'eu-west-1','eu-west-1','regional',    290,NULL, 'regional',   '2026-01-13 16:10:00','2026-01-13 17:10:00'),
('REQ-OS-20260113-010','ACC010','chat/completions','mixtral-8x7b_32k_20231211',  750,250, 150,0,  'us-west-2','us-west-2','global',      260,NULL, 'global',     '2026-01-13 17:25:00','2026-01-13 09:25:00'),
-- Jan 14
('REQ-OS-20260114-001','ACC001','chat/completions','llama-3.1_405b_20240723',    4000,1200,0, 800,'us-west-2','us-west-2','regional',    920,NULL, 'regional',   '2026-01-14 08:05:00','2026-01-14 00:05:00'),
('REQ-OS-20260114-002','ACC002','embeddings',      'mistral_7b_32k_20240522',    500,128, 0,  0,  'us-east-1','us-east-1','regional',    120,NULL, 'global',     '2026-01-14 09:20:00','2026-01-14 04:20:00'),
('REQ-OS-20260114-003','ACC003','chat/completions','llama-3.1_70b_20240723',     1800,550,0,  300,'eu-west-1','us-east-1','multi-region',680,NULL, 'regional',   '2026-01-14 10:35:00','2026-01-14 11:35:00'),
('REQ-OS-20260114-004','ACC004','chat/completions','mixtral-8x7b_32k_20231211',  1300,400,0,  0,  'us-east-1','us-east-1','global',      350,'E429','global',    '2026-01-14 11:50:00','2026-01-14 06:50:00'),
('REQ-OS-20260114-005','ACC005','chat/completions','mistral-large_128k_20240724',2200,700,400, 0, 'us-west-2','eu-west-1','multi-region',750,NULL, 'multi-region','2026-01-14 13:05:00','2026-01-14 13:05:00'),
('REQ-OS-20260114-006','ACC006','chat/completions','llama-3.1_70b_20240723',     1500,480,0,  0,  'eu-west-1','eu-west-1','global',      420,NULL, 'global',     '2026-01-14 14:20:00','2026-01-14 15:20:00'),
('REQ-OS-20260114-007','ACC007','chat/completions','mixtral-8x7b_32k_20231211',  800,280, 0,  0,  'us-east-1','us-east-1','global',      270,NULL, 'global',     '2026-01-14 15:35:00','2026-01-14 23:35:00'),
('REQ-OS-20260114-008','ACC008','chat/completions','mistral_7b_32k_20240522',    700,220, 0,  0,  'us-east-1','us-east-1','regional',    190,NULL, 'global',     '2026-01-14 16:50:00','2026-01-14 11:50:00'),
('REQ-OS-20260114-009','ACC009','chat/completions','llama-3.1_70b_20240723',     1000,350,0,  0,  'eu-west-1','eu-west-1','regional',    310,NULL, 'regional',   '2026-01-14 17:05:00','2026-01-14 18:05:00'),
('REQ-OS-20260114-010','ACC010','chat/completions','llama-3.1_405b_20240723',    2500,800,0,  500,'us-west-2','us-west-2','regional',    780,NULL, 'regional',   '2026-01-14 18:20:00','2026-01-14 10:20:00'),
-- Jan 15
('REQ-OS-20260115-001','ACC001','chat/completions','mixtral-8x7b_32k_20231211',  1100,400,200, 0, 'us-east-1','us-east-1','global',      340,NULL, 'global',     '2026-01-15 08:10:00','2026-01-15 03:10:00'),
('REQ-OS-20260115-002','ACC002','chat/completions','llama-3.1_70b_20240723',     950,350, 0,  0,  'us-west-2','us-west-2','regional',    295,NULL, 'regional',   '2026-01-15 09:25:00','2026-01-15 01:25:00'),
('REQ-OS-20260115-003','ACC003','chat/completions','mistral-large_128k_20240724',1800,580,350, 0, 'eu-west-1','eu-west-1','multi-region',410,NULL, 'multi-region','2026-01-15 10:40:00','2026-01-15 11:40:00'),
('REQ-OS-20260115-004','ACC004','chat/completions','llama-3.1_405b_20240723',    3500,1050,0, 700,'us-east-1','us-east-1','regional',    900,NULL, 'regional',   '2026-01-15 11:55:00','2026-01-15 06:55:00'),
('REQ-OS-20260115-005','ACC005','chat/completions','mixtral-8x7b_32k_20231211',  1200,420,0,  0,  'eu-west-1','eu-west-1','global',      360,NULL, 'global',     '2026-01-15 13:10:00','2026-01-15 14:10:00'),
('REQ-OS-20260115-006','ACC006','embeddings',      'mistral_7b_32k_20240522',    400,128, 0,  0,  'eu-west-1','eu-west-1','global',      110,NULL, 'global',     '2026-01-15 14:25:00','2026-01-15 15:25:00'),
('REQ-OS-20260115-007','ACC007','chat/completions','llama-3.1_70b_20240723',     1300,460,0,  0,  'us-east-1','us-east-1','regional',    330,NULL, 'regional',   '2026-01-15 15:40:00','2026-01-15 23:40:00'),
('REQ-OS-20260115-008','ACC008','chat/completions','mixtral-8x7b_32k_20231211',  850,290, 0,  0,  'us-east-1','us-east-1','global',      280,'E503','global',    '2026-01-15 16:55:00','2026-01-15 11:55:00'),
('REQ-OS-20260115-009','ACC009','chat/completions','mistral-large_128k_20240724',1100,390,220, 0, 'eu-west-1','eu-west-1','multi-region',420,NULL, 'multi-region','2026-01-15 17:10:00','2026-01-15 18:10:00'),
('REQ-OS-20260115-010','ACC010','chat/completions','llama-3.1_70b_20240723',     880,320, 0,  0,  'us-west-2','us-west-2','regional',    275,NULL, 'regional',   '2026-01-15 18:25:00','2026-01-15 10:25:00'),
-- Jan 16
('REQ-OS-20260116-001','ACC001','chat/completions','llama-3.1_70b_20240723',     1400,500,0,  0,  'us-east-1','us-east-1','regional',    345,NULL, 'regional',   '2026-01-16 08:15:00','2026-01-16 03:15:00'),
('REQ-OS-20260116-002','ACC002','chat/completions','mixtral-8x7b_32k_20231211',  900,310, 180,0,  'us-west-2','us-west-2','global',      295,NULL, 'global',     '2026-01-16 09:30:00','2026-01-16 01:30:00'),
('REQ-OS-20260116-003','ACC003','chat/completions','llama-3.1_405b_20240723',    2800,850,0,  560,'eu-west-1','us-east-1','multi-region',860,NULL, 'regional',   '2026-01-16 10:45:00','2026-01-16 11:45:00'),
('REQ-OS-20260116-004','ACC004','chat/completions','mistral_7b_32k_20240522',    650,210, 0,  0,  'us-east-1','us-east-1','regional',    185,NULL, 'global',     '2026-01-16 12:00:00','2026-01-16 07:00:00'),
('REQ-OS-20260116-005','ACC005','chat/completions','mistral-large_128k_20240724',1700,560,340, 0, 'eu-west-1','eu-west-1','multi-region',405,NULL, 'multi-region','2026-01-16 13:15:00','2026-01-16 14:15:00'),
('REQ-OS-20260116-006','ACC006','chat/completions','llama-3.1_70b_20240723',     1200,430,0,  0,  'eu-west-1','eu-west-1','global',      335,NULL, 'global',     '2026-01-16 14:30:00','2026-01-16 15:30:00'),
('REQ-OS-20260116-007','ACC007','chat/completions','mixtral-8x7b_32k_20231211',  980,340, 0,  0,  'us-east-1','us-east-1','global',      315,NULL, 'global',     '2026-01-16 15:45:00','2026-01-16 23:45:00'),
('REQ-OS-20260116-008','ACC008','chat/completions','llama-3.1_70b_20240723',     1050,380,0,  0,  'us-east-1','us-east-1','regional',    300,NULL, 'regional',   '2026-01-16 17:00:00','2026-01-16 12:00:00'),
('REQ-OS-20260116-009','ACC009','chat/completions','mistral-large_128k_20240724',950,330, 190,0,  'eu-west-1','eu-west-1','multi-region',395,NULL, 'multi-region','2026-01-16 18:15:00','2026-01-16 19:15:00'),
('REQ-OS-20260116-010','ACC010','chat/completions','llama-3.1_405b_20240723',    3200,960,0,  640,'us-west-2','us-west-2','regional',    870,NULL, 'regional',   '2026-01-16 19:30:00','2026-01-16 11:30:00'),
-- Jan 17
('REQ-OS-20260117-001','ACC001','chat/completions','mixtral-8x7b_32k_20231211',  1050,380,210, 0, 'us-east-1','us-east-1','global',      325,NULL, 'global',     '2026-01-17 08:20:00','2026-01-17 03:20:00'),
('REQ-OS-20260117-002','ACC002','chat/completions','llama-3.1_70b_20240723',     870,310, 0,  0,  'us-west-2','us-west-2','regional',    270,NULL, 'regional',   '2026-01-17 09:35:00','2026-01-17 01:35:00'),
('REQ-OS-20260117-003','ACC003','chat/completions','mistral-large_128k_20240724',1650,530,330, 0, 'eu-west-1','eu-west-1','multi-region',395,NULL, 'multi-region','2026-01-17 10:50:00','2026-01-17 11:50:00'),
('REQ-OS-20260117-004','ACC004','embeddings',      'mistral_7b_32k_20240522',    450,128, 0,  0,  'us-east-1','us-east-1','regional',    115,NULL, 'global',     '2026-01-17 12:05:00','2026-01-17 07:05:00'),
('REQ-OS-20260117-005','ACC005','chat/completions','mixtral-8x7b_32k_20231211',  1150,410,0,  0,  'eu-west-1','eu-west-1','global',      345,NULL, 'global',     '2026-01-17 13:20:00','2026-01-17 14:20:00'),
('REQ-OS-20260117-006','ACC006','chat/completions','llama-3.1_405b_20240723',    2600,780,0,  520,'eu-west-1','us-east-1','multi-region',840,NULL, 'regional',   '2026-01-17 14:35:00','2026-01-17 15:35:00'),
('REQ-OS-20260117-007','ACC007','chat/completions','llama-3.1_70b_20240723',     1250,440,0,  0,  'us-east-1','us-east-1','regional',    320,NULL, 'regional',   '2026-01-17 15:50:00','2026-01-17 23:50:00'),
('REQ-OS-20260117-008','ACC008','chat/completions','mixtral-8x7b_32k_20231211',  820,275, 0,  0,  'us-east-1','us-east-1','global',      265,NULL, 'global',     '2026-01-17 17:05:00','2026-01-17 12:05:00'),
('REQ-OS-20260117-009','ACC009','chat/completions','mistral-large_128k_20240724',1050,370,210, 0, 'eu-west-1','eu-west-1','multi-region',410,NULL, 'multi-region','2026-01-17 18:20:00','2026-01-17 19:20:00'),
('REQ-OS-20260117-010','ACC010','chat/completions','llama-3.1_70b_20240723',     920,335, 0,  0,  'us-west-2','us-west-2','regional',    285,NULL, 'regional',   '2026-01-17 19:35:00','2026-01-17 11:35:00'),
-- Jan 18
('REQ-OS-20260118-001','ACC001','chat/completions','llama-3.1_70b_20240723',     1350,485,0,  0,  'us-east-1','us-east-1','regional',    335,NULL, 'regional',   '2026-01-18 08:25:00','2026-01-18 03:25:00'),
('REQ-OS-20260118-002','ACC002','chat/completions','mixtral-8x7b_32k_20231211',  920,325, 185,0,  'us-west-2','us-west-2','global',      300,NULL, 'global',     '2026-01-18 09:40:00','2026-01-18 01:40:00'),
('REQ-OS-20260118-003','ACC003','chat/completions','llama-3.1_405b_20240723',    2900,870,0,  580,'eu-west-1','us-east-1','multi-region',875,NULL, 'regional',   '2026-01-18 10:55:00','2026-01-18 11:55:00'),
('REQ-OS-20260118-004','ACC004','chat/completions','mistral_7b_32k_20240522',    670,215, 0,  0,  'us-east-1','us-east-1','regional',    188,NULL, 'global',     '2026-01-18 12:10:00','2026-01-18 07:10:00'),
('REQ-OS-20260118-005','ACC005','chat/completions','mistral-large_128k_20240724',1750,570,350, 0, 'eu-west-1','eu-west-1','multi-region',415,NULL, 'multi-region','2026-01-18 13:25:00','2026-01-18 14:25:00'),
('REQ-OS-20260118-006','ACC006','chat/completions','llama-3.1_70b_20240723',     1180,425,0,  0,  'eu-west-1','eu-west-1','global',      330,NULL, 'global',     '2026-01-18 14:40:00','2026-01-18 15:40:00'),
('REQ-OS-20260118-007','ACC007','chat/completions','mixtral-8x7b_32k_20231211',  1000,350,0,  0,  'us-east-1','us-east-1','global',      320,'E429','global',    '2026-01-18 15:55:00','2026-01-18 23:55:00'),
('REQ-OS-20260118-008','ACC008','chat/completions','llama-3.1_70b_20240723',     1080,390,0,  0,  'us-east-1','us-east-1','regional',    305,NULL, 'regional',   '2026-01-18 17:10:00','2026-01-18 12:10:00'),
('REQ-OS-20260118-009','ACC009','chat/completions','mistral-large_128k_20240724',970,340, 195,0,  'eu-west-1','eu-west-1','multi-region',400,NULL, 'multi-region','2026-01-18 18:25:00','2026-01-18 19:25:00'),
('REQ-OS-20260118-010','ACC010','chat/completions','llama-3.1_405b_20240723',    3100,930,0,  620,'us-west-2','us-west-2','regional',    865,NULL, 'regional',   '2026-01-18 19:40:00','2026-01-18 11:40:00'),
-- Jan 19
('REQ-OS-20260119-001','ACC001','chat/completions','mixtral-8x7b_32k_20231211',  1080,390,215, 0, 'us-east-1','us-east-1','global',      330,NULL, 'global',     '2026-01-19 08:30:00','2026-01-19 03:30:00'),
('REQ-OS-20260119-002','ACC002','chat/completions','llama-3.1_70b_20240723',     890,320, 0,  0,  'us-west-2','us-west-2','regional',    278,NULL, 'regional',   '2026-01-19 09:45:00','2026-01-19 01:45:00'),
('REQ-OS-20260119-003','ACC003','chat/completions','mistral-large_128k_20240724',1700,545,340, 0, 'eu-west-1','eu-west-1','multi-region',400,NULL, 'multi-region','2026-01-19 11:00:00','2026-01-19 12:00:00'),
('REQ-OS-20260119-004','ACC004','chat/completions','llama-3.1_405b_20240723',    3300,990,0,  660,'us-east-1','us-east-1','regional',    890,NULL, 'regional',   '2026-01-19 12:15:00','2026-01-19 07:15:00'),
('REQ-OS-20260119-005','ACC005','chat/completions','mixtral-8x7b_32k_20231211',  1180,420,0,  0,  'eu-west-1','eu-west-1','global',      355,NULL, 'global',     '2026-01-19 13:30:00','2026-01-19 14:30:00'),
('REQ-OS-20260119-006','ACC006','embeddings',      'mistral_7b_32k_20240522',    420,128, 0,  0,  'eu-west-1','eu-west-1','global',      112,NULL, 'global',     '2026-01-19 14:45:00','2026-01-19 15:45:00'),
('REQ-OS-20260119-007','ACC007','chat/completions','llama-3.1_70b_20240723',     1280,450,0,  0,  'us-east-1','us-east-1','regional',    325,NULL, 'regional',   '2026-01-19 16:00:00','2026-01-20 00:00:00'),
('REQ-OS-20260119-008','ACC008','chat/completions','mixtral-8x7b_32k_20231211',  840,285, 0,  0,  'us-east-1','us-east-1','global',      270,NULL, 'global',     '2026-01-19 17:15:00','2026-01-19 12:15:00'),
('REQ-OS-20260119-009','ACC009','chat/completions','mistral-large_128k_20240724',1080,380,215, 0, 'eu-west-1','eu-west-1','multi-region',415,NULL, 'multi-region','2026-01-19 18:30:00','2026-01-19 19:30:00'),
('REQ-OS-20260119-010','ACC010','chat/completions','llama-3.1_70b_20240723',     940,340, 0,  0,  'us-west-2','us-west-2','regional',    290,NULL, 'regional',   '2026-01-19 19:45:00','2026-01-19 11:45:00');

-- =============================================================================
-- TABLE 6: inference_user_token_usage_proprietary (Jan 13-19, 10 requests/day)
-- =============================================================================

INSERT INTO raw_bronze.inference_user_token_usage_proprietary (
    request_id, account_id, api_name, model_variant,
    input_token, output_token, cache_read_token, cache_write_token,
    source_region, inference_region, traffic_type,
    latency_ms, error_code, inference_scope,
    event_timestamp, local_timestamp
) VALUES
-- Jan 13
('REQ-PR-20260113-001','ACC001','chat/completions','claude-3.5-sonnet_200k_20241022', 2500,800, 500,0,   'us-east-1',     'us-east-1',     'global',      450,NULL, 'global',      '2026-01-13 08:05:00','2026-01-13 03:05:00'),
('REQ-PR-20260113-002','ACC002','chat/completions','gpt-4o_128k_20240513',            1800,600, 0,  300, 'us-west-2',     'us-west-2',     'global',      380,NULL, 'global',      '2026-01-13 09:20:00','2026-01-13 01:20:00'),
('REQ-PR-20260113-003','ACC003','chat/completions','claude-3-haiku_200k_20240307',    800,250,  200,0,   'eu-west-1',     'eu-west-1',     'global',      180,NULL, 'global',      '2026-01-13 10:35:00','2026-01-13 11:35:00'),
('REQ-PR-20260113-004','ACC004','chat/completions','gpt-4-turbo_128k_20240409',       3200,950, 0,  600, 'us-east-1',     'us-east-1',     'global',      620,NULL, 'global',      '2026-01-13 11:50:00','2026-01-13 06:50:00'),
('REQ-PR-20260113-005','ACC005','chat/completions','claude-3-opus_200k_20240229',     4000,1200,800,0,   'eu-west-1',     'eu-west-1',     'multi-region',890,NULL, 'multi-region','2026-01-13 13:05:00','2026-01-13 14:05:00'),
('REQ-PR-20260113-006','ACC006','chat/completions','gemini-1.5-pro_1m_20240214',      5000,1500,0,  1000,'eu-west-1',    'us-east-1',     'global',      720,NULL, 'global',      '2026-01-13 14:20:00','2026-01-13 15:20:00'),
('REQ-PR-20260113-007','ACC007','chat/completions','claude-sonnet-4_200k_20250514',   2200,700, 400,0,   'ap-northeast-1','ap-northeast-1','global',      410,NULL, 'global',      '2026-01-13 15:35:00','2026-01-13 23:35:00'),
('REQ-PR-20260113-008','ACC008','chat/completions','claude-3-haiku_200k_20240307',    600,200,  0,  0,   'ca-central-1',  'us-east-1',     'multi-region',220,NULL, 'global',      '2026-01-13 16:50:00','2026-01-13 11:50:00'),
('REQ-PR-20260113-009','ACC009','chat/completions','claude-3-haiku_200k_20240307',    700,230,  0,  0,   'eu-west-1',     'eu-west-1',     'global',      170,'E503','global',     '2026-01-13 18:05:00','2026-01-13 19:05:00'),
('REQ-PR-20260113-010','ACC010','chat/completions','gpt-4o_128k_20240513',            1500,500, 0,  250, 'us-west-2',     'us-west-2',     'global',      340,NULL, 'global',      '2026-01-13 19:20:00','2026-01-13 11:20:00'),
-- Jan 14
('REQ-PR-20260114-001','ACC001','chat/completions','claude-sonnet-4_200k_20250514',   3000,900, 600,0,   'us-east-1',     'us-east-1',     'global',      530,NULL, 'global',      '2026-01-14 08:10:00','2026-01-14 03:10:00'),
('REQ-PR-20260114-002','ACC002','embeddings',      'claude-3-haiku_200k_20240307',    1000,256, 0,  0,   'us-east-1',     'us-east-1',     'global',      150,NULL, 'global',      '2026-01-14 09:25:00','2026-01-14 04:25:00'),
('REQ-PR-20260114-003','ACC003','chat/completions','gemini-1.5-flash_1m_20240214',    1200,400, 0,  200, 'us-east-1',     'us-east-1',     'global',      260,NULL, 'global',      '2026-01-14 10:40:00','2026-01-14 11:40:00'),
('REQ-PR-20260114-004','ACC004','chat/completions','gpt-4o_128k_20240513',            1600,530, 0,  270, 'us-east-1',     'us-east-1',     'global',      355,NULL, 'global',      '2026-01-14 11:55:00','2026-01-14 06:55:00'),
('REQ-PR-20260114-005','ACC005','chat/completions','claude-3.5-sonnet_200k_20241022', 2800,850, 500,0,   'eu-west-1',     'eu-west-1',     'multi-region',480,NULL, 'multi-region','2026-01-14 13:10:00','2026-01-14 14:10:00'),
('REQ-PR-20260114-006','ACC006','chat/completions','claude-3-haiku_200k_20240307',    750,240,  150,0,   'eu-west-1',     'eu-west-1',     'global',      175,NULL, 'global',      '2026-01-14 14:25:00','2026-01-14 15:25:00'),
('REQ-PR-20260114-007','ACC007','chat/completions','claude-sonnet-4_200k_20250514',   1800,600, 300,0,   'ap-southeast-1','ap-southeast-1','global',      390,NULL, 'global',      '2026-01-14 15:40:00','2026-01-14 23:40:00'),
('REQ-PR-20260114-008','ACC008','chat/completions','claude-3-haiku_200k_20240307',    620,205,  0,  0,   'ca-central-1',  'us-east-1',     'multi-region',225,NULL, 'global',      '2026-01-14 16:55:00','2026-01-14 11:55:00'),
('REQ-PR-20260114-009','ACC009','chat/completions','gpt-4o_128k_20240513',            1400,465, 0,  230, 'eu-west-1',     'eu-west-1',     'global',      345,NULL, 'global',      '2026-01-14 18:10:00','2026-01-14 19:10:00'),
('REQ-PR-20260114-010','ACC010','chat/completions','claude-3.5-sonnet_200k_20241022', 2600,820, 520,0,   'us-west-2',     'us-west-2',     'global',      465,NULL, 'global',      '2026-01-14 19:25:00','2026-01-14 11:25:00'),
-- Jan 15
('REQ-PR-20260115-001','ACC001','chat/completions','claude-3.5-sonnet_200k_20241022', 2650,830, 530,0,   'us-east-1',     'us-east-1',     'global',      460,NULL, 'global',      '2026-01-15 08:15:00','2026-01-15 03:15:00'),
('REQ-PR-20260115-002','ACC002','chat/completions','gpt-4o_128k_20240513',            1850,615, 0,  310, 'us-west-2',     'us-west-2',     'global',      385,NULL, 'global',      '2026-01-15 09:30:00','2026-01-15 01:30:00'),
('REQ-PR-20260115-003','ACC003','chat/completions','claude-3-opus_200k_20240229',     4200,1250,850,0,   'eu-west-1',     'eu-west-1',     'multi-region',910,NULL, 'multi-region','2026-01-15 10:45:00','2026-01-15 11:45:00'),
('REQ-PR-20260115-004','ACC004','chat/completions','gpt-4-turbo_128k_20240409',       3400,1000,0,  680, 'us-east-1',     'us-east-1',     'global',      640,NULL, 'global',      '2026-01-15 12:00:00','2026-01-15 07:00:00'),
('REQ-PR-20260115-005','ACC005','chat/completions','claude-sonnet-4_200k_20250514',   2900,920, 580,0,   'eu-west-1',     'eu-west-1',     'global',      520,NULL, 'global',      '2026-01-15 13:15:00','2026-01-15 14:15:00'),
('REQ-PR-20260115-006','ACC006','chat/completions','gemini-1.5-pro_1m_20240214',      5200,1560,0,  1040,'eu-west-1',    'us-east-1',     'global',      735,NULL, 'global',      '2026-01-15 14:30:00','2026-01-15 15:30:00'),
('REQ-PR-20260115-007','ACC007','chat/completions','claude-sonnet-4_200k_20250514',   2300,720, 460,0,   'ap-northeast-1','ap-northeast-1','global',      420,NULL, 'global',      '2026-01-15 15:45:00','2026-01-15 23:45:00'),
('REQ-PR-20260115-008','ACC008','chat/completions','claude-3-haiku_200k_20240307',    640,210,  0,  0,   'ca-central-1',  'us-east-1',     'multi-region',228,NULL, 'global',      '2026-01-15 17:00:00','2026-01-15 12:00:00'),
('REQ-PR-20260115-009','ACC009','chat/completions','gpt-4o_128k_20240513',            1450,480, 0,  240, 'eu-west-1',     'eu-west-1',     'global',      350,NULL, 'global',      '2026-01-15 18:15:00','2026-01-15 19:15:00'),
('REQ-PR-20260115-010','ACC010','chat/completions','claude-3.5-sonnet_200k_20241022', 2700,840, 540,0,   'us-west-2',     'us-west-2',     'global',      472,NULL, 'global',      '2026-01-15 19:30:00','2026-01-15 11:30:00'),
-- Jan 16
('REQ-PR-20260116-001','ACC001','chat/completions','claude-sonnet-4_200k_20250514',   2900,890, 580,0,   'us-east-1',     'us-east-1',     'global',      515,NULL, 'global',      '2026-01-16 08:20:00','2026-01-16 03:20:00'),
('REQ-PR-20260116-002','ACC002','chat/completions','gpt-4o_128k_20240513',            1700,565, 0,  285, 'us-west-2',     'us-west-2',     'global',      370,NULL, 'global',      '2026-01-16 09:35:00','2026-01-16 01:35:00'),
('REQ-PR-20260116-003','ACC003','chat/completions','claude-3-haiku_200k_20240307',    820,255,  205,0,   'eu-west-1',     'eu-west-1',     'global',      183,NULL, 'global',      '2026-01-16 10:50:00','2026-01-16 11:50:00'),
('REQ-PR-20260116-004','ACC004','chat/completions','gpt-4-turbo_128k_20240409',       3100,920, 0,  620, 'us-east-1',     'us-east-1',     'global',      610,NULL, 'global',      '2026-01-16 12:05:00','2026-01-16 07:05:00'),
('REQ-PR-20260116-005','ACC005','chat/completions','claude-3-opus_200k_20240229',     3900,1170,780,0,   'eu-west-1',     'eu-west-1',     'multi-region',875,NULL, 'multi-region','2026-01-16 13:20:00','2026-01-16 14:20:00'),
('REQ-PR-20260116-006','ACC006','chat/completions','gemini-1.5-flash_1m_20240214',    1150,385, 0,  190, 'eu-west-1',     'us-east-1',     'global',      252,NULL, 'global',      '2026-01-16 14:35:00','2026-01-16 15:35:00'),
('REQ-PR-20260116-007','ACC007','chat/completions','claude-sonnet-4_200k_20250514',   2100,665, 420,0,   'ap-northeast-1','ap-northeast-1','global',      400,NULL, 'global',      '2026-01-16 15:50:00','2026-01-16 23:50:00'),
('REQ-PR-20260116-008','ACC008','chat/completions','claude-3-haiku_200k_20240307',    590,195,  0,  0,   'ca-central-1',  'us-east-1',     'multi-region',215,NULL, 'global',      '2026-01-16 17:05:00','2026-01-16 12:05:00'),
('REQ-PR-20260116-009','ACC009','chat/completions','claude-3.5-sonnet_200k_20241022', 2450,775, 490,0,   'eu-west-1',     'eu-west-1',     'global',      455,NULL, 'global',      '2026-01-16 18:20:00','2026-01-16 19:20:00'),
('REQ-PR-20260116-010','ACC010','chat/completions','gpt-4o_128k_20240513',            1550,515, 0,  260, 'us-west-2',     'us-west-2',     'global',      348,NULL, 'global',      '2026-01-16 19:35:00','2026-01-16 11:35:00'),
-- Jan 17
('REQ-PR-20260117-001','ACC001','chat/completions','claude-3.5-sonnet_200k_20241022', 2400,770, 480,0,   'us-east-1',     'us-east-1',     'global',      443,NULL, 'global',      '2026-01-17 08:25:00','2026-01-17 03:25:00'),
('REQ-PR-20260117-002','ACC002','chat/completions','gpt-4o_128k_20240513',            1650,550, 0,  275, 'us-west-2',     'us-west-2',     'global',      362,NULL, 'global',      '2026-01-17 09:40:00','2026-01-17 01:40:00'),
('REQ-PR-20260117-003','ACC003','chat/completions','claude-3-haiku_200k_20240307',    780,245,  195,0,   'eu-west-1',     'eu-west-1',     'global',      178,NULL, 'global',      '2026-01-17 10:55:00','2026-01-17 11:55:00'),
('REQ-PR-20260117-004','ACC004','chat/completions','gpt-4-turbo_128k_20240409',       2950,880, 0,  590, 'us-east-1',     'us-east-1',     'global',      595,NULL, 'global',      '2026-01-17 12:10:00','2026-01-17 07:10:00'),
('REQ-PR-20260117-005','ACC005','chat/completions','claude-3-opus_200k_20240229',     3800,1140,760,0,   'eu-west-1',     'eu-west-1',     'multi-region',862,NULL, 'multi-region','2026-01-17 13:25:00','2026-01-17 14:25:00'),
('REQ-PR-20260117-006','ACC006','chat/completions','gemini-1.5-pro_1m_20240214',      4800,1440,0,  960, 'eu-west-1',     'us-east-1',     'global',      708,NULL, 'global',      '2026-01-17 14:40:00','2026-01-17 15:40:00'),
('REQ-PR-20260117-007','ACC007','chat/completions','claude-sonnet-4_200k_20250514',   2000,635, 400,0,   'ap-northeast-1','ap-northeast-1','global',      392,NULL, 'global',      '2026-01-17 15:55:00','2026-01-17 23:55:00'),
('REQ-PR-20260117-008','ACC008','chat/completions','claude-3-haiku_200k_20240307',    575,190,  0,  0,   'ca-central-1',  'us-east-1',     'multi-region',210,'E429','global',     '2026-01-17 17:10:00','2026-01-17 12:10:00'),
('REQ-PR-20260117-009','ACC009','chat/completions','gpt-4o_128k_20240513',            1380,460, 0,  230, 'eu-west-1',     'eu-west-1',     'global',      338,NULL, 'global',      '2026-01-17 18:25:00','2026-01-17 19:25:00'),
('REQ-PR-20260117-010','ACC010','chat/completions','claude-3.5-sonnet_200k_20241022', 2550,805, 510,0,   'us-west-2',     'us-west-2',     'global',      458,NULL, 'global',      '2026-01-17 19:40:00','2026-01-17 11:40:00'),
-- Jan 18
('REQ-PR-20260118-001','ACC001','chat/completions','claude-sonnet-4_200k_20250514',   3100,950, 620,0,   'us-east-1',     'us-east-1',     'global',      545,NULL, 'global',      '2026-01-18 08:30:00','2026-01-18 03:30:00'),
('REQ-PR-20260118-002','ACC002','chat/completions','gpt-4o_128k_20240513',            1750,580, 0,  290, 'us-west-2',     'us-west-2',     'global',      375,NULL, 'global',      '2026-01-18 09:45:00','2026-01-18 01:45:00'),
('REQ-PR-20260118-003','ACC003','chat/completions','claude-3-haiku_200k_20240307',    840,260,  210,0,   'eu-west-1',     'eu-west-1',     'global',      185,NULL, 'global',      '2026-01-18 11:00:00','2026-01-18 12:00:00'),
('REQ-PR-20260118-004','ACC004','chat/completions','gpt-4-turbo_128k_20240409',       3300,980, 0,  660, 'us-east-1',     'us-east-1',     'global',      630,NULL, 'global',      '2026-01-18 12:15:00','2026-01-18 07:15:00'),
('REQ-PR-20260118-005','ACC005','chat/completions','claude-3-opus_200k_20240229',     4100,1230,820,0,   'eu-west-1',     'eu-west-1',     'multi-region',898,NULL, 'multi-region','2026-01-18 13:30:00','2026-01-18 14:30:00'),
('REQ-PR-20260118-006','ACC006','chat/completions','gemini-1.5-flash_1m_20240214',    1200,400, 0,  200, 'eu-west-1',     'us-east-1',     'global',      258,NULL, 'global',      '2026-01-18 14:45:00','2026-01-18 15:45:00'),
('REQ-PR-20260118-007','ACC007','chat/completions','claude-sonnet-4_200k_20250514',   2250,710, 450,0,   'ap-southeast-1','ap-southeast-1','global',      415,NULL, 'global',      '2026-01-18 16:00:00','2026-01-19 00:00:00'),
('REQ-PR-20260118-008','ACC008','chat/completions','claude-3-haiku_200k_20240307',    610,200,  0,  0,   'ca-central-1',  'us-east-1',     'multi-region',220,NULL, 'global',      '2026-01-18 17:15:00','2026-01-18 12:15:00'),
('REQ-PR-20260118-009','ACC009','chat/completions','claude-3.5-sonnet_200k_20241022', 2500,790, 500,0,   'eu-west-1',     'eu-west-1',     'global',      462,NULL, 'global',      '2026-01-18 18:30:00','2026-01-18 19:30:00'),
('REQ-PR-20260118-010','ACC010','chat/completions','gpt-4o_128k_20240513',            1600,530, 0,  265, 'us-west-2',     'us-west-2',     'global',      352,NULL, 'global',      '2026-01-18 19:45:00','2026-01-18 11:45:00'),
-- Jan 19
('REQ-PR-20260119-001','ACC001','chat/completions','claude-3.5-sonnet_200k_20241022', 2580,815, 516,0,   'us-east-1',     'us-east-1',     'global',      467,NULL, 'global',      '2026-01-19 08:35:00','2026-01-19 03:35:00'),
('REQ-PR-20260119-002','ACC002','chat/completions','gpt-4o_128k_20240513',            1820,605, 0,  305, 'us-west-2',     'us-west-2',     'global',      382,NULL, 'global',      '2026-01-19 09:50:00','2026-01-19 01:50:00'),
('REQ-PR-20260119-003','ACC003','chat/completions','claude-3-opus_200k_20240229',     4050,1215,810,0,   'eu-west-1',     'eu-west-1',     'multi-region',905,NULL, 'multi-region','2026-01-19 11:05:00','2026-01-19 12:05:00'),
('REQ-PR-20260119-004','ACC004','chat/completions','gpt-4-turbo_128k_20240409',       3150,940, 0,  630, 'us-east-1',     'us-east-1',     'global',      618,NULL, 'global',      '2026-01-19 12:20:00','2026-01-19 07:20:00'),
('REQ-PR-20260119-005','ACC005','chat/completions','claude-sonnet-4_200k_20250514',   2950,935, 590,0,   'eu-west-1',     'eu-west-1',     'global',      528,NULL, 'global',      '2026-01-19 13:35:00','2026-01-19 14:35:00'),
('REQ-PR-20260119-006','ACC006','chat/completions','gemini-1.5-pro_1m_20240214',      5100,1530,0,  1020,'eu-west-1',    'us-east-1',     'global',      728,NULL, 'global',      '2026-01-19 14:50:00','2026-01-19 15:50:00'),
('REQ-PR-20260119-007','ACC007','chat/completions','claude-sonnet-4_200k_20250514',   2150,680, 430,0,   'ap-northeast-1','ap-northeast-1','global',      405,NULL, 'global',      '2026-01-19 16:05:00','2026-01-20 00:05:00'),
('REQ-PR-20260119-008','ACC008','chat/completions','claude-3-haiku_200k_20240307',    630,208,  0,  0,   'ca-central-1',  'us-east-1',     'multi-region',222,NULL, 'global',      '2026-01-19 17:20:00','2026-01-19 12:20:00'),
('REQ-PR-20260119-009','ACC009','chat/completions','gpt-4o_128k_20240513',            1420,473, 0,  235, 'eu-west-1',     'eu-west-1',     'global',      342,'E503','global',     '2026-01-19 18:35:00','2026-01-19 19:35:00'),
('REQ-PR-20260119-010','ACC010','chat/completions','claude-3.5-sonnet_200k_20241022', 2650,838, 530,0,   'us-west-2',     'us-west-2',     'global',      475,NULL, 'global',      '2026-01-19 19:50:00','2026-01-19 11:50:00');

-- =============================================================================
-- VERIFICATION
-- =============================================================================

SELECT 'customer_details'                        AS table_name, COUNT(*) AS row_count FROM raw_bronze.customer_details
UNION ALL
SELECT 'resource_accelerator_inventory',          COUNT(*) FROM raw_bronze.resource_accelerator_inventory
UNION ALL
SELECT 'resource_model_instance_allocation',      COUNT(*) FROM raw_bronze.resource_model_instance_allocation
UNION ALL
SELECT 'resource_model_utilization',              COUNT(*) FROM raw_bronze.resource_model_utilization
UNION ALL
SELECT 'inference_user_token_usage_open_source',  COUNT(*) FROM raw_bronze.inference_user_token_usage_open_source
UNION ALL
SELECT 'inference_user_token_usage_proprietary',  COUNT(*) FROM raw_bronze.inference_user_token_usage_proprietary
ORDER BY table_name;


-- ============================================================
-- PART 2: Quota and Rate Limit Seed Data
-- Source: 004_seed_quota_rate_limit_tables.sql
-- Tables: quota_default_rate_limits,
--         quota_customer_rate_limit_adjustments
-- Depends on: config_model_dimensions and
--             config_model_region_availability (loaded by Airflow DAG)
-- ============================================================

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


-- ============================================================
-- PART 3: Revenue Account Daily Seed Data
-- Source: 005_seed_revenue_account_daily.sql
-- Tables: revenue_account_daily
-- Depends on: inference_user_token_usage_proprietary and
--             inference_user_token_usage_open_source (Part 1)
-- ============================================================

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


-- ============================================================
-- PART 4: Customer Rate Limit Requests Seed Data
-- Source: 006_seed_quota_customer_rate_limit_requests.sql
-- Tables: quota_customer_rate_limit_requests
-- ============================================================

-- =============================================================================
-- Seed Data: quota_customer_rate_limit_requests
-- =============================================================================
-- Date range: 2026-01-13 to 2026-02-26
-- Customers: ACC001 - ACC010
-- Models: consistent with config_model_dimensions
-- Regions: consistent with config_model_region_availability
-- =============================================================================

INSERT INTO raw_bronze.quota_customer_rate_limit_requests (
    account_id,
    limit_type,
    inference_scope,
    model_variant,
    source_region,
    requests_per_minute,
    tokens_per_minute,
    tokens_per_day,
    status,
    created_by,
    create_datetime,
    last_updated,
    source_file
) VALUES

-- =============================================================================
-- ACC001 - Acme AI Corp (Enterprise/Strategic) - Heavy user, multiple requests
-- =============================================================================
('ACC001', 'upgrade', 'global',    'claude-3.5-sonnet_200k_20241022', 'us-east-1',      500,  1000000, 20000000, 'approved',  'alice@acme.com',        '2026-01-13 09:00:00', '2026-01-14 10:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC001', 'upgrade', 'regional',  'gpt-4o_128k_20240513',            'us-east-1',      300,  600000,  12000000, 'approved',  'alice@acme.com',        '2026-01-20 10:00:00', '2026-01-21 11:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC001', 'upgrade', 'global',    'claude-sonnet-4_200k_20250514',   'us-east-1',      1000, 2000000, 40000000, 'approved',  'alice@acme.com',        '2026-02-01 09:00:00', '2026-02-02 10:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC001', 'upgrade', 'regional',  'claude-3.5-sonnet_200k_20241022', 'us-west-2',      200,  400000,  8000000,  'pending',   'alice@acme.com',        '2026-02-20 09:00:00', '2026-02-20 09:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC002 - DataStream Inc (Enterprise/Strategic) - SaaS, high volume
-- =============================================================================
('ACC002', 'upgrade', 'global',    'claude-3.5-sonnet_200k_20241022', 'us-east-1',      800,  1600000, 32000000, 'approved',  'bob@datastream.com',   '2026-01-14 11:00:00', '2026-01-15 12:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC002', 'upgrade', 'regional',  'llama-3.1_70b_20240723',          'us-east-1',      400,  800000,  16000000, 'approved',  'bob@datastream.com',   '2026-01-25 10:00:00', '2026-01-26 11:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC002', 'upgrade', 'global',    'gpt-4o_128k_20240513',            'us-east-1',      600,  1200000, 24000000, 'rejected',  'bob@datastream.com',   '2026-02-05 09:00:00', '2026-02-06 10:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC002', 'upgrade', 'global',    'claude-sonnet-4_200k_20250514',   'us-east-1',      500,  1000000, 20000000, 'pending',   'bob@datastream.com',   '2026-02-22 10:00:00', '2026-02-22 10:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC003 - HealthAI Solutions (Mid-Market/Commercial) - HealthTech, moderate usage
-- =============================================================================
('ACC003', 'upgrade', 'regional',  'claude-3-haiku_200k_20240307',    'us-east-1',      200,  400000,  8000000,  'approved',  'carol@healthai.com',   '2026-01-15 14:00:00', '2026-01-16 09:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC003', 'upgrade', 'regional',  'claude-3.5-sonnet_200k_20241022', 'us-east-1',      150,  300000,  6000000,  'approved',  'carol@healthai.com',   '2026-02-03 10:00:00', '2026-02-04 11:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC003', 'downgrade','regional', 'gpt-4o_128k_20240513',            'us-east-1',      50,   100000,  2000000,  'approved',  'carol@healthai.com',   '2026-02-15 09:00:00', '2026-02-16 10:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC003', 'upgrade', 'regional',  'claude-sonnet-4_200k_20250514',   'us-east-1',      100,  200000,  4000000,  'pending',   'carol@healthai.com',   '2026-02-24 11:00:00', '2026-02-24 11:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC004 - Nexus Analytics (SMB/Commercial) - Small, cautious upgrades
-- =============================================================================
('ACC004', 'upgrade', 'regional',  'claude-3-haiku_200k_20240307',    'us-east-1',      100,  200000,  4000000,  'approved',  'david@nexus.com',      '2026-01-16 10:00:00', '2026-01-17 11:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC004', 'upgrade', 'regional',  'llama-3.1_70b_20240723',          'us-east-1',      50,   100000,  2000000,  'rejected',  'david@nexus.com',      '2026-02-08 09:00:00', '2026-02-09 10:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC004', 'upgrade', 'regional',  'claude-3-haiku_200k_20240307',    'us-east-1',      150,  300000,  6000000,  'pending',   'david@nexus.com',      '2026-02-25 14:00:00', '2026-02-25 14:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC005 - GlobalBank Ltd (Enterprise/Strategic) - FinTech, high compliance needs
-- =============================================================================
('ACC005', 'upgrade', 'regional',  'claude-3.5-sonnet_200k_20241022', 'eu-west-1',      600,  1200000, 24000000, 'approved',  'emma@globalbank.com',  '2026-01-13 13:00:00', '2026-01-14 14:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC005', 'upgrade', 'regional',  'gpt-4o_128k_20240513',            'eu-west-1',      400,  800000,  16000000, 'approved',  'emma@globalbank.com',  '2026-01-22 10:00:00', '2026-01-23 11:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC005', 'upgrade', 'global',    'claude-sonnet-4_200k_20250514',   'eu-west-1',      800,  1600000, 32000000, 'approved',  'emma@globalbank.com',  '2026-02-02 09:00:00', '2026-02-03 10:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC005', 'upgrade', 'regional',  'claude-3.5-sonnet_200k_20241022', 'eu-central-1',   300,  600000,  12000000, 'pending',   'emma@globalbank.com',  '2026-02-21 10:00:00', '2026-02-21 10:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC006 - TechVision GmbH (Mid-Market/Commercial) - Europe based
-- =============================================================================
('ACC006', 'upgrade', 'regional',  'gpt-4o_128k_20240513',            'eu-west-1',      250,  500000,  10000000, 'approved',  'franz@techvision.de',  '2026-01-17 10:00:00', '2026-01-18 11:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC006', 'upgrade', 'regional',  'claude-3.5-sonnet_200k_20241022', 'eu-west-1',      200,  400000,  8000000,  'approved',  'franz@techvision.de',  '2026-02-06 09:00:00', '2026-02-07 10:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC006', 'upgrade', 'regional',  'claude-sonnet-4_200k_20250514',   'eu-central-1',   150,  300000,  6000000,  'cancelled', 'franz@techvision.de',  '2026-02-14 10:00:00', '2026-02-15 09:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC006', 'upgrade', 'regional',  'llama-3.1_70b_20240723',          'eu-west-1',      100,  200000,  4000000,  'pending',   'franz@techvision.de',  '2026-02-23 14:00:00', '2026-02-23 14:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC007 - AsiaPay Systems (Enterprise/Strategic) - APAC FinTech
-- =============================================================================
('ACC007', 'upgrade', 'regional',  'claude-3.5-sonnet_200k_20241022', 'ap-northeast-1', 500,  1000000, 20000000, 'approved',  'grace@asiapay.com',    '2026-01-14 06:00:00', '2026-01-15 07:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC007', 'upgrade', 'regional',  'claude-3-haiku_200k_20240307',    'ap-northeast-1', 300,  600000,  12000000, 'approved',  'grace@asiapay.com',    '2026-01-24 06:00:00', '2026-01-25 07:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC007', 'upgrade', 'global',    'claude-sonnet-4_200k_20250514',   'ap-northeast-1', 700,  1400000, 28000000, 'approved',  'grace@asiapay.com',    '2026-02-04 06:00:00', '2026-02-05 07:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC007', 'upgrade', 'regional',  'gpt-4o_128k_20240513',            'ap-southeast-1', 200,  400000,  8000000,  'pending',   'grace@asiapay.com',    '2026-02-22 06:00:00', '2026-02-22 06:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC008 - MediCore AI (Mid-Market/Commercial) - HealthTech Canada
-- =============================================================================
('ACC008', 'upgrade', 'regional',  'claude-3-haiku_200k_20240307',    'ca-central-1',   150,  300000,  6000000,  'approved',  'henry@medicore.com',   '2026-01-18 15:00:00', '2026-01-19 10:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC008', 'upgrade', 'regional',  'claude-3.5-sonnet_200k_20241022', 'ca-central-1',   100,  200000,  4000000,  'approved',  'henry@medicore.com',   '2026-02-07 10:00:00', '2026-02-08 11:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC008', 'downgrade','regional', 'gpt-4o_128k_20240513',            'ca-central-1',   25,   50000,   1000000,  'approved',  'henry@medicore.com',   '2026-02-16 10:00:00', '2026-02-17 11:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC008', 'upgrade', 'regional',  'claude-sonnet-4_200k_20250514',   'ca-central-1',   75,   150000,  3000000,  'pending',   'henry@medicore.com',   '2026-02-25 10:00:00', '2026-02-25 10:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC009 - RetailBoost Ltd (SMB/Commercial) - Inactive, few requests
-- =============================================================================
('ACC009', 'upgrade', 'regional',  'claude-3-haiku_200k_20240307',    'eu-west-1',      50,   100000,  2000000,  'rejected',  'isabel@retail.com',    '2026-01-19 11:00:00', '2026-01-20 10:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC009', 'upgrade', 'regional',  'llama-3.1_70b_20240723',          'eu-west-1',      30,   60000,   1200000,  'cancelled', 'isabel@retail.com',    '2026-02-10 10:00:00', '2026-02-11 09:00:00', 'rate_limit_requests_feb2026.csv'),

-- =============================================================================
-- ACC010 - CloudNative Co (Enterprise/Strategic) - SaaS Seattle
-- =============================================================================
('ACC010', 'upgrade', 'global',    'claude-3.5-sonnet_200k_20241022', 'us-west-2',      700,  1400000, 28000000, 'approved',  'james@cloudnative.com','2026-01-13 16:00:00', '2026-01-14 17:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC010', 'upgrade', 'regional',  'gpt-4o_128k_20240513',            'us-west-2',      400,  800000,  16000000, 'approved',  'james@cloudnative.com','2026-01-21 10:00:00', '2026-01-22 11:00:00', 'rate_limit_requests_jan2026.csv'),
('ACC010', 'upgrade', 'global',    'claude-sonnet-4_200k_20250514',   'us-west-2',      900,  1800000, 36000000, 'approved',  'james@cloudnative.com','2026-02-01 10:00:00', '2026-02-02 11:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC010', 'upgrade', 'regional',  'llama-3.1_70b_20240723',          'us-west-2',      300,  600000,  12000000, 'pending',   'james@cloudnative.com','2026-02-24 10:00:00', '2026-02-24 10:00:00', 'rate_limit_requests_feb2026.csv'),
('ACC010', 'downgrade','global',   'claude-3.5-sonnet_200k_20241022', 'us-west-2',      200,  400000,  8000000,  'cancelled', 'james@cloudnative.com','2026-02-18 09:00:00', '2026-02-19 10:00:00', 'rate_limit_requests_feb2026.csv');
