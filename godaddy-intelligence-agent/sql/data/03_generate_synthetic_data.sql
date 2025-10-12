-- ============================================================================
-- GoDaddy Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic sample data for GoDaddy business operations
-- Volume: ~100K customers, 150K domains, 200K hosting plans, 2M transactions
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- Step 1: Generate Support Agents
-- ============================================================================
INSERT INTO SUPPORT_AGENTS
SELECT
    'AGT' || LPAD(SEQ4(), 5, '0') AS agent_id,
    ARRAY_CONSTRUCT('John Smith', 'Sarah Johnson', 'Michael Chen', 'Emily Williams', 'David Martinez',
                    'Jessica Brown', 'Christopher Lee', 'Amanda Garcia', 'Matthew Rodriguez', 'Ashley Lopez')[UNIFORM(0, 9, RANDOM())] 
        || ' ' || ARRAY_CONSTRUCT('A', 'B', 'C', 'D', 'E')[UNIFORM(0, 4, RANDOM())] AS agent_name,
    'agent' || SEQ4() || '@godaddy.com' AS email,
    ARRAY_CONSTRUCT('DOMAINS', 'HOSTING', 'EMAIL', 'WEBSITE_BUILDER', 'TECHNICAL')[UNIFORM(0, 4, RANDOM())] AS department,
    ARRAY_CONSTRUCT('Domain Transfer', 'DNS Configuration', 'Email Setup', 'SSL Issues', 'Billing')[UNIFORM(0, 4, RANDOM())] AS specialization,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_DATE()) AS hire_date,
    (UNIFORM(35, 50, RANDOM()) / 10.0)::NUMBER(3,2) AS average_satisfaction_rating,
    UNIFORM(100, 5000, RANDOM()) AS total_tickets_resolved,
    'ACTIVE' AS agent_status,
    DATEADD('day', -1 * UNIFORM(30, 1825, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100));

-- ============================================================================
-- Step 2: Generate Products
-- ============================================================================
INSERT INTO PRODUCTS VALUES
-- Domains
('PROD001', '.com Domain Registration', 'DOMAIN', 'TLD', 11.99, 17.99, 'ANNUAL', '

Standard .com domain registration', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD002', '.net Domain Registration', 'DOMAIN', 'TLD', 12.99, 18.99, 'ANNUAL', 'Standard .net domain registration', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD003', '.org Domain Registration', 'DOMAIN', 'TLD', 9.99, 15.99, 'ANNUAL', 'Standard .org domain registration', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD004', '.io Domain Registration', 'DOMAIN', 'TLD', 39.99, 49.99, 'ANNUAL', 'Premium .io domain for tech startups', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD005', '.co Domain Registration', 'DOMAIN', 'TLD', 24.99, 32.99, 'ANNUAL', 'Standard .co domain registration', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Hosting
('PROD010', 'Economy Hosting', 'HOSTING', 'SHARED', NULL, 5.99, 'MONTHLY', '100 GB storage, 1 website, 10 email accounts', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD011', 'Deluxe Hosting', 'HOSTING', 'SHARED', NULL, 7.99, 'MONTHLY', 'Unlimited storage, unlimited websites, 25 email accounts', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD012', 'Ultimate Hosting', 'HOSTING', 'SHARED', NULL, 12.99, 'MONTHLY', 'Unlimited storage, unlimited websites, unlimited email, 2x processing power', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD013', 'VPS Hosting', 'HOSTING', 'VPS', NULL, 29.99, 'MONTHLY', '4 GB RAM, 100 GB storage, root access', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD014', 'Dedicated Server', 'HOSTING', 'DEDICATED', NULL, 149.99, 'MONTHLY', '16 GB RAM, 1 TB storage, full control', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Website Builder
('PROD020', 'Website Builder Basic', 'WEBSITE_BUILDER', 'BASIC', NULL, 9.99, 'MONTHLY', 'Basic website builder with templates', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD021', 'Website Builder Commerce', 'WEBSITE_BUILDER', 'ECOMMERCE', NULL, 24.99, 'MONTHLY', 'E-commerce enabled website builder', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- Email
('PROD030', 'Professional Email - Basic', 'EMAIL', 'PROFESSIONAL', NULL, 4.99, 'MONTHLY', '10 GB mailbox, webmail access', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD031', 'Professional Email - Premium', 'EMAIL', 'PROFESSIONAL', NULL, 8.99, 'MONTHLY', '50 GB mailbox, advanced security', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD032', 'Microsoft 365 Email', 'EMAIL', 'MICROSOFT365', NULL, 5.99, 'MONTHLY', 'Office 365 integration', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),

-- SSL
('PROD040', 'SSL Certificate - DV', 'SSL', 'DOMAIN_VALIDATED', NULL, 79.99, 'ANNUAL', 'Domain validated SSL', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD041', 'SSL Certificate - OV', 'SSL', 'ORG_VALIDATED', NULL, 299.99, 'ANNUAL', 'Organization validated SSL', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP()),
('PROD042', 'SSL Certificate - Wildcard', 'SSL', 'WILDCARD', NULL, 299.99, 'ANNUAL', 'Wildcard SSL for subdomains', TRUE, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 3: Generate Customers
-- ============================================================================
INSERT INTO CUSTOMERS
SELECT
    'CUST' || LPAD(SEQ4(), 10, '0') AS customer_id,
    ARRAY_CONSTRUCT('Tech', 'Global', 'Digital', 'Smart', 'Innovative', 'Creative', 'Dynamic', 'Premier', 'Elite', 'Pro')[UNIFORM(0, 9, RANDOM())]
        || ' ' ||
    ARRAY_CONSTRUCT('Solutions', 'Services', 'Group', 'Enterprises', 'Company', 'Consulting', 'Agency', 'Partners', 'Systems', 'Media')[UNIFORM(0, 9, RANDOM())] AS customer_name,
    'customer' || SEQ4() || '@' || ARRAY_CONSTRUCT('gmail', 'yahoo', 'outlook', 'company', 'business')[UNIFORM(0, 4, RANDOM())] || '.com' AS email,
    CONCAT('+1-', UNIFORM(200, 999, RANDOM()), '-', UNIFORM(100, 999, RANDOM()), '-', UNIFORM(1000, 9999, RANDOM())) AS phone,
    'USA' AS country,
    ARRAY_CONSTRUCT('CA', 'TX', 'FL', 'NY', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI', 'WA', 'AZ', 'MA', 'VA', 'CO')[UNIFORM(0, 14, RANDOM())] AS state,
    ARRAY_CONSTRUCT('Los Angeles', 'Houston', 'Miami', 'New York', 'Chicago', 'Philadelphia', 'Phoenix', 'Seattle', 'Boston', 'Denver')[UNIFORM(0, 9, RANDOM())] AS city,
    DATEADD('day', -1 * UNIFORM(1, 3650, RANDOM()), CURRENT_DATE()) AS signup_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN 'ACTIVE'
         WHEN UNIFORM(0, 100, RANDOM()) < 3 THEN 'SUSPENDED'
         ELSE 'CLOSED' END AS customer_status,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 25 THEN 'ENTERPRISE'
         WHEN UNIFORM(0, 100, RANDOM()) < 50 THEN 'SMALL_BUSINESS'
         ELSE 'INDIVIDUAL' END AS customer_segment,
    (UNIFORM(100, 10000, RANDOM()) / 1.0)::NUMBER(12,2) AS lifetime_value,
    (UNIFORM(10, 90, RANDOM()) / 1.0)::NUMBER(5,2) AS risk_score,
    UNIFORM(0, 100, RANDOM()) < 40 AS is_business_customer,
    DATEADD('day', -1 * UNIFORM(1, 3650, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM TABLE(GENERATOR(ROWCOUNT => 100000));

-- ============================================================================
-- Step 4: Generate Domains
-- ============================================================================
INSERT INTO DOMAINS
SELECT
    'DOM' || LPAD(SEQ4(), 10, '0') AS domain_id,
    c.customer_id,
    LOWER(REPLACE(SPLIT_PART(c.customer_name, ' ', 0), ',', '') || CASE WHEN UNIFORM(0, 3, RANDOM()) > 0 THEN UNIFORM(1, 999, RANDOM())::VARCHAR ELSE '' END) AS domain_name,
    ARRAY_CONSTRUCT('.com', '.net', '.org', '.io', '.co', '.ai', '.app', '.dev', '.online', '.store')[UNIFORM(0, 9, RANDOM())] AS domain_extension,
    c.signup_date AS registration_date,
    DATEADD('year', UNIFORM(1, 5, RANDOM()), c.signup_date) AS expiration_date,
    CASE WHEN DATEADD('year', UNIFORM(1, 5, RANDOM()), c.signup_date) > CURRENT_DATE() THEN 'ACTIVE'
         ELSE ARRAY_CONSTRUCT('EXPIRED', 'PENDING_RENEWAL', 'GRACE_PERIOD')[UNIFORM(0, 2, RANDOM())] END AS renewal_status,
    UNIFORM(0, 100, RANDOM()) < 70 AS auto_renew_enabled,
    (UNIFORM(999, 4999, RANDOM()) / 100.0)::NUMBER(10,2) AS registration_price,
    (UNIFORM(1299, 4999, RANDOM()) / 100.0)::NUMBER(10,2) AS renewal_price,
    UNIFORM(0, 100, RANDOM()) < 40 AS privacy_protection,
    'ns1.godaddy.com,ns2.godaddy.com' AS nameservers,
    'ACTIVE' AS domain_status,
    TRUE AS transfer_locked,
    c.created_at AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM CUSTOMERS c
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 2))
WHERE UNIFORM(0, 100, RANDOM()) < 75
LIMIT 150000;

-- ============================================================================
-- Step 5: Generate Hosting Plans
-- ============================================================================
INSERT INTO HOSTING_PLANS
SELECT
    'HOST' || LPAD(SEQ4(), 10, '0') AS hosting_id,
    d.customer_id,
    d.domain_id,
    ARRAY_CONSTRUCT('SHARED', 'VPS', 'DEDICATED', 'CLOUD')[UNIFORM(0, 3, RANDOM())] AS plan_type,
    ARRAY_CONSTRUCT('Economy', 'Deluxe', 'Ultimate', 'VPS', 'Dedicated')[UNIFORM(0, 4, RANDOM())] AS plan_name,
    d.registration_date AS start_date,
    DATEADD('year', 1, d.registration_date) AS end_date,
    ARRAY_CONSTRUCT('MONTHLY', 'ANNUAL', 'BIENNIAL')[UNIFORM(0, 2, RANDOM())] AS billing_cycle,
    (UNIFORM(599, 14999, RANDOM()) / 100.0)::NUMBER(10,2) AS monthly_price,
    CASE WHEN UNIFORM(0, 3, RANDOM()) = 0 THEN 100
         WHEN UNIFORM(0, 3, RANDOM()) = 1 THEN 250
         WHEN UNIFORM(0, 3, RANDOM()) = 2 THEN 500
         ELSE 1000 END AS disk_space_gb,
    CASE WHEN UNIFORM(0, 3, RANDOM()) = 0 THEN 1000
         WHEN UNIFORM(0, 3, RANDOM()) = 1 THEN 5000
         ELSE 10000 END AS bandwidth_gb,
    UNIFORM(10, 100, RANDOM()) AS email_accounts_limit,
    UNIFORM(10, 50, RANDOM()) AS databases_limit,
    UNIFORM(0, 100, RANDOM()) < 60 AS ssl_included,
    CASE WHEN d.expiration_date > CURRENT_DATE() THEN 'ACTIVE'
         ELSE ARRAY_CONSTRUCT('EXPIRED', 'SUSPENDED')[UNIFORM(0, 1, RANDOM())] END AS hosting_status,
    (UNIFORM(9900, 10000, RANDOM()) / 100.0)::NUMBER(5,2) AS uptime_percentage,
    d.created_at AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM DOMAINS d
WHERE UNIFORM(0, 100, RANDOM()) < 60
LIMIT 200000;

-- ============================================================================
-- Step 6: Generate Marketing Campaigns
-- ============================================================================
INSERT INTO MARKETING_CAMPAIGNS VALUES
('CAMP001', 'Summer Domain Sale', 'PROMOTION', '2024-06-01', '2024-08-31', 'NEW_CUSTOMERS', 50000, 'EMAIL', 'COMPLETED', CURRENT_TIMESTAMP()),
('CAMP002', 'Hosting Bundle Offer', 'BUNDLE', '2024-03-01', '2024-12-31', 'EXISTING_CUSTOMERS', 100000, 'WEBSITE', 'ACTIVE', CURRENT_TIMESTAMP()),
('CAMP003', 'Small Business Website Builder', 'PRODUCT_LAUNCH', '2024-01-15', '2024-12-31', 'SMALL_BUSINESS', 75000, 'SOCIAL_MEDIA', 'ACTIVE', CURRENT_TIMESTAMP()),
('CAMP004', 'SSL Certificate Awareness', 'EDUCATION', '2024-04-01', '2024-12-31', 'ALL_CUSTOMERS', 30000, 'BLOG', 'ACTIVE', CURRENT_TIMESTAMP()),
('CAMP005', 'Black Friday Special', 'SEASONAL', '2024-11-25', '2024-11-29', 'ALL_CUSTOMERS', 200000, 'MULTI_CHANNEL', 'ACTIVE', CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 7: Generate Customer Campaign Interactions
-- ============================================================================
INSERT INTO CUSTOMER_CAMPAIGN_INTERACTIONS
SELECT
    'INT' || LPAD(SEQ4(), 10, '0') AS interaction_id,
    c.customer_id,
    mc.campaign_id,
    DATEADD('day', UNIFORM(0, 180, RANDOM()), mc.start_date) AS interaction_date,
    ARRAY_CONSTRUCT('EMAIL_OPEN', 'CLICK', 'WEBSITE_VISIT', 'PURCHASE')[UNIFORM(0, 3, RANDOM())] AS interaction_type,
    UNIFORM(0, 100, RANDOM()) < 15 AS conversion_flag,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 15 THEN (UNIFORM(1000, 50000, RANDOM()) / 100.0)::NUMBER(12,2) ELSE 0.00 END AS revenue_generated,
    DATEADD('day', UNIFORM(0, 180, RANDOM()), mc.start_date) AS created_at
FROM CUSTOMERS c
CROSS JOIN MARKETING_CAMPAIGNS mc
WHERE UNIFORM(0, 100, RANDOM()) < 2
LIMIT 50000;

-- ============================================================================
-- Step 8: Generate Transactions
-- ============================================================================
INSERT INTO TRANSACTIONS
SELECT
    'TXN' || LPAD(SEQ4(), 12, '0') AS transaction_id,
    c.customer_id,
    DATEADD('day', -1 * UNIFORM(0, 1095, RANDOM()), CURRENT_TIMESTAMP()) AS transaction_date,
    ARRAY_CONSTRUCT('DOMAIN_REGISTRATION', 'DOMAIN_RENEWAL', 'HOSTING_PURCHASE', 'HOSTING_RENEWAL', 
                    'SSL_PURCHASE', 'EMAIL_SERVICE', 'WEBSITE_BUILDER', 'DOMAIN_TRANSFER')[UNIFORM(0, 7, RANDOM())] AS transaction_type,
    ARRAY_CONSTRUCT('DOMAIN', 'HOSTING', 'SSL', 'EMAIL', 'WEBSITE_BUILDER')[UNIFORM(0, 4, RANDOM())] AS product_type,
    'PROD' || LPAD(UNIFORM(1, 42, RANDOM()), 3, '0') AS product_id,
    (UNIFORM(599, 29999, RANDOM()) / 100.0)::NUMBER(12,2) AS amount,
    'USD' AS currency,
    ARRAY_CONSTRUCT('CREDIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'CRYPTO')[UNIFORM(0, 3, RANDOM())] AS payment_method,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 98 THEN 'COMPLETED'
         WHEN UNIFORM(0, 100, RANDOM()) < 1 THEN 'FAILED'
         ELSE 'REFUNDED' END AS payment_status,
    (UNIFORM(0, 2000, RANDOM()) / 100.0)::NUMBER(10,2) AS discount_amount,
    (UNIFORM(0, 1500, RANDOM()) / 100.0)::NUMBER(10,2) AS tax_amount,
    (UNIFORM(599, 29999, RANDOM()) / 100.0)::NUMBER(12,2) AS total_amount,
    DATEADD('day', -1 * UNIFORM(0, 1095, RANDOM()), CURRENT_TIMESTAMP()) AS created_at
FROM CUSTOMERS c
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 20))
WHERE UNIFORM(0, 100, RANDOM()) < 15
LIMIT 2000000;

-- ============================================================================
-- Step 9: Generate Support Tickets
-- ============================================================================
INSERT INTO SUPPORT_TICKETS
SELECT
    'TIX' || LPAD(SEQ4(), 10, '0') AS ticket_id,
    c.customer_id,
    ARRAY_CONSTRUCT('Domain Transfer Issue', 'Email Configuration Help', 'Website Down', 'DNS Problems', 
                    'Billing Question', 'SSL Installation', 'Password Reset', 'Hosting Upgrade',
                    'Domain Renewal', 'Technical Support')[UNIFORM(0, 9, RANDOM())] AS subject,
    ARRAY_CONSTRUCT('TECHNICAL', 'BILLING', 'ACCOUNT', 'DOMAIN', 'HOSTING', 'EMAIL', 'SSL')[UNIFORM(0, 6, RANDOM())] AS issue_type,
    ARRAY_CONSTRUCT('LOW', 'MEDIUM', 'HIGH', 'URGENT')[UNIFORM(0, 3, RANDOM())] AS priority,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN 'CLOSED'
         WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN 'IN_PROGRESS'
         ELSE 'OPEN' END AS ticket_status,
    ARRAY_CONSTRUCT('PHONE', 'EMAIL', 'CHAT', 'WEB_FORM')[UNIFORM(0, 3, RANDOM())] AS channel,
    'AGT' || LPAD(UNIFORM(1, 100, RANDOM()), 5, '0') AS assigned_agent_id,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_date,
    DATEADD('hour', UNIFORM(1, 4, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP())) AS first_response_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 
         THEN DATEADD('hour', UNIFORM(4, 48, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()))
         ELSE NULL END AS resolved_date,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 
         THEN DATEADD('hour', UNIFORM(4, 72, RANDOM()), DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()))
         ELSE NULL END AS closed_date,
    (UNIFORM(4, 48, RANDOM()) / 1.0)::NUMBER(10,2) AS resolution_time_hours,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 80 THEN UNIFORM(1, 5, RANDOM()) ELSE NULL END AS satisfaction_rating,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM CUSTOMERS c
CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 3))
WHERE UNIFORM(0, 100, RANDOM()) < 20
LIMIT 150000;

-- ============================================================================
-- Step 10: Generate Website Builder Subscriptions
-- ============================================================================
INSERT INTO WEBSITE_BUILDER_SUBSCRIPTIONS
SELECT
    'WBS' || LPAD(SEQ4(), 10, '0') AS subscription_id,
    d.customer_id,
    d.domain_id,
    ARRAY_CONSTRUCT('BASIC', 'COMMERCE', 'PREMIUM')[UNIFORM(0, 2, RANDOM())] AS builder_type,
    ARRAY_CONSTRUCT('Business Pro', 'E-commerce Starter', 'Portfolio Plus', 'Restaurant Theme', 'Tech Startup')[UNIFORM(0, 4, RANDOM())] AS template_name,
    d.registration_date AS start_date,
    DATEADD('year', 1, d.registration_date) AS end_date,
    (UNIFORM(999, 2999, RANDOM()) / 100.0)::NUMBER(10,2) AS monthly_price,
    'DRAG_DROP,MOBILE_RESPONSIVE,SEO_TOOLS' AS features_enabled,
    (UNIFORM(100, 5000, RANDOM()) / 100.0)::NUMBER(10,2) AS storage_used_gb,
    UNIFORM(100, 50000, RANDOM()) AS page_views_monthly,
    CASE WHEN d.expiration_date > CURRENT_DATE() THEN 'ACTIVE' ELSE 'EXPIRED' END AS subscription_status,
    d.created_at AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM DOMAINS d
WHERE UNIFORM(0, 100, RANDOM()) < 25
LIMIT 75000;

-- ============================================================================
-- Step 11: Generate Email Services
-- ============================================================================
INSERT INTO EMAIL_SERVICES
SELECT
    'EML' || LPAD(SEQ4(), 10, '0') AS email_service_id,
    d.customer_id,
    d.domain_id,
    ARRAY_CONSTRUCT('PROFESSIONAL', 'BUSINESS', 'MICROSOFT365')[UNIFORM(0, 2, RANDOM())] AS service_type,
    UNIFORM(1, 50, RANDOM()) AS mailbox_count,
    CASE WHEN UNIFORM(0, 2, RANDOM()) = 0 THEN 10
         WHEN UNIFORM(0, 2, RANDOM()) = 1 THEN 50
         ELSE 100 END AS storage_per_mailbox_gb,
    d.registration_date AS start_date,
    DATEADD('year', 1, d.registration_date) AS end_date,
    (UNIFORM(499, 1499, RANDOM()) / 100.0)::NUMBER(10,2) AS monthly_price,
    CASE WHEN d.expiration_date > CURRENT_DATE() THEN 'ACTIVE' ELSE 'EXPIRED' END AS service_status,
    d.created_at AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM DOMAINS d
WHERE UNIFORM(0, 100, RANDOM()) < 40
LIMIT 100000;

-- ============================================================================
-- Step 12: Generate SSL Certificates
-- ============================================================================
INSERT INTO SSL_CERTIFICATES
SELECT
    'SSL' || LPAD(SEQ4(), 10, '0') AS ssl_id,
    d.customer_id,
    d.domain_id,
    ARRAY_CONSTRUCT('DV', 'OV', 'EV', 'WILDCARD')[UNIFORM(0, 3, RANDOM())] AS certificate_type,
    d.registration_date AS issue_date,
    DATEADD('year', 1, d.registration_date) AS expiration_date,
    UNIFORM(0, 100, RANDOM()) < 80 AS auto_renew,
    (UNIFORM(7999, 29999, RANDOM()) / 100.0)::NUMBER(10,2) AS annual_price,
    CASE WHEN DATEADD('year', 1, d.registration_date) > CURRENT_DATE() THEN 'ACTIVE' ELSE 'EXPIRED' END AS cert_status,
    d.created_at AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM DOMAINS d
WHERE UNIFORM(0, 100, RANDOM()) < 35
LIMIT 80000;

-- ============================================================================
-- Display summary statistics
-- ============================================================================
SELECT 'Data generation completed successfully' AS status;

SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count FROM CUSTOMERS
UNION ALL
SELECT 'DOMAINS', COUNT(*) FROM DOMAINS
UNION ALL
SELECT 'HOSTING_PLANS', COUNT(*) FROM HOSTING_PLANS
UNION ALL
SELECT 'TRANSACTIONS', COUNT(*) FROM TRANSACTIONS
UNION ALL
SELECT 'SUPPORT_TICKETS', COUNT(*) FROM SUPPORT_TICKETS
UNION ALL
SELECT 'WEBSITE_BUILDER_SUBSCRIPTIONS', COUNT(*) FROM WEBSITE_BUILDER_SUBSCRIPTIONS
UNION ALL
SELECT 'EMAIL_SERVICES', COUNT(*) FROM EMAIL_SERVICES
UNION ALL
SELECT 'SSL_CERTIFICATES', COUNT(*) FROM SSL_CERTIFICATES
UNION ALL
SELECT 'SUPPORT_AGENTS', COUNT(*) FROM SUPPORT_AGENTS
UNION ALL
SELECT 'PRODUCTS', COUNT(*) FROM PRODUCTS
UNION ALL
SELECT 'MARKETING_CAMPAIGNS', COUNT(*) FROM MARKETING_CAMPAIGNS
UNION ALL
SELECT 'CUSTOMER_CAMPAIGN_INTERACTIONS', COUNT(*) FROM CUSTOMER_CAMPAIGN_INTERACTIONS
ORDER BY table_name;

