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
