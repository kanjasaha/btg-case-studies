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
