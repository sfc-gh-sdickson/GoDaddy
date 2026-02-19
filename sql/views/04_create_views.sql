-- ============================================================================
-- GoDaddy Intelligence Agent - Analytical Views
-- ============================================================================
-- Purpose: Create curated analytical views for business intelligence
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- Customer 360 View
-- ============================================================================
CREATE OR REPLACE VIEW V_CUSTOMER_360 AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.phone,
    c.country,
    c.state,
    c.city,
    c.signup_date,
    c.customer_status,
    c.customer_segment,
    c.lifetime_value,
    c.risk_score,
    c.is_business_customer,
    COUNT(DISTINCT d.domain_id) AS total_domains,
    COUNT(DISTINCT h.hosting_id) AS total_hosting_plans,
    COUNT(DISTINCT w.subscription_id) AS total_website_builders,
    COUNT(DISTINCT e.email_service_id) AS total_email_services,
    COUNT(DISTINCT s.ssl_id) AS total_ssl_certificates,
    COUNT(DISTINCT t.transaction_id) AS total_transactions,
    SUM(t.total_amount) AS total_revenue,
    COUNT(DISTINCT st.ticket_id) AS total_support_tickets,
    AVG(st.satisfaction_rating) AS avg_satisfaction_rating,
    c.created_at,
    c.updated_at
FROM RAW.CUSTOMERS c
LEFT JOIN RAW.DOMAINS d ON c.customer_id = d.customer_id
LEFT JOIN RAW.HOSTING_PLANS h ON c.customer_id = h.customer_id
LEFT JOIN RAW.WEBSITE_BUILDER_SUBSCRIPTIONS w ON c.customer_id = w.customer_id
LEFT JOIN RAW.EMAIL_SERVICES e ON c.customer_id = e.customer_id
LEFT JOIN RAW.SSL_CERTIFICATES s ON c.customer_id = s.customer_id
LEFT JOIN RAW.TRANSACTIONS t ON c.customer_id = t.customer_id
LEFT JOIN RAW.SUPPORT_TICKETS st ON c.customer_id = st.customer_id
GROUP BY
    c.customer_id, c.customer_name, c.email, c.phone, c.country, c.state, c.city,
    c.signup_date, c.customer_status, c.customer_segment, c.lifetime_value,
    c.risk_score, c.is_business_customer, c.created_at, c.updated_at;

-- ============================================================================
-- Domain Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_DOMAIN_ANALYTICS AS
SELECT
    d.domain_id,
    d.customer_id,
    c.customer_name,
    c.customer_segment,
    d.domain_name || d.domain_extension AS full_domain_name,
    d.domain_extension,
    d.registration_date,
    d.expiration_date,
    DATEDIFF('day', CURRENT_DATE(), d.expiration_date) AS days_until_expiration,
    d.renewal_status,
    d.auto_renew_enabled,
    d.registration_price,
    d.renewal_price,
    d.privacy_protection,
    d.domain_status,
    d.transfer_locked,
    COUNT(DISTINCT h.hosting_id) AS hosting_plans_count,
    COUNT(DISTINCT w.subscription_id) AS website_builder_count,
    COUNT(DISTINCT e.email_service_id) AS email_services_count,
    COUNT(DISTINCT s.ssl_id) AS ssl_certificates_count,
    d.created_at,
    d.updated_at
FROM RAW.DOMAINS d
JOIN RAW.CUSTOMERS c ON d.customer_id = c.customer_id
LEFT JOIN RAW.HOSTING_PLANS h ON d.domain_id = h.domain_id
LEFT JOIN RAW.WEBSITE_BUILDER_SUBSCRIPTIONS w ON d.domain_id = w.domain_id
LEFT JOIN RAW.EMAIL_SERVICES e ON d.domain_id = e.domain_id
LEFT JOIN RAW.SSL_CERTIFICATES s ON d.domain_id = s.domain_id
GROUP BY
    d.domain_id, d.customer_id, c.customer_name, c.customer_segment,
    d.domain_name, d.domain_extension, d.registration_date, d.expiration_date,
    d.renewal_status, d.auto_renew_enabled, d.registration_price, d.renewal_price,
    d.privacy_protection, d.domain_status, d.transfer_locked, d.created_at, d.updated_at;

-- ============================================================================
-- Hosting Performance View
-- ============================================================================
CREATE OR REPLACE VIEW V_HOSTING_PERFORMANCE AS
SELECT
    h.hosting_id,
    h.customer_id,
    c.customer_name,
    h.domain_id,
    d.domain_name || d.domain_extension AS full_domain_name,
    h.plan_type,
    h.plan_name,
    h.start_date,
    h.end_date,
    h.billing_cycle,
    h.monthly_price,
    h.disk_space_gb,
    h.bandwidth_gb,
    h.email_accounts_limit,
    h.databases_limit,
    h.ssl_included,
    h.hosting_status,
    h.uptime_percentage,
    CASE
        WHEN h.uptime_percentage >= 99.95 THEN 'EXCELLENT'
        WHEN h.uptime_percentage >= 99.50 THEN 'GOOD'
        WHEN h.uptime_percentage >= 98.00 THEN 'FAIR'
        ELSE 'POOR'
    END AS uptime_rating,
    h.created_at,
    h.updated_at
FROM RAW.HOSTING_PLANS h
JOIN RAW.CUSTOMERS c ON h.customer_id = c.customer_id
LEFT JOIN RAW.DOMAINS d ON h.domain_id = d.domain_id;

-- ============================================================================
-- Revenue Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_REVENUE_ANALYTICS AS
SELECT
    t.transaction_id,
    t.customer_id,
    c.customer_name,
    c.customer_segment,
    t.transaction_date,
    DATE_TRUNC('MONTH', t.transaction_date) AS transaction_month,
    DATE_TRUNC('QUARTER', t.transaction_date) AS transaction_quarter,
    DATE_TRUNC('YEAR', t.transaction_date) AS transaction_year,
    DAYOFWEEK(t.transaction_date) AS day_of_week,
    HOUR(t.transaction_date) AS hour_of_day,
    t.transaction_type,
    t.product_type,
    t.product_id,
    p.product_name,
    p.product_category,
    t.amount,
    t.currency,
    t.payment_method,
    t.payment_status,
    t.discount_amount,
    t.tax_amount,
    t.total_amount,
    CASE
        WHEN t.discount_amount > 0 THEN (t.discount_amount / t.amount * 100)
        ELSE 0
    END AS discount_percentage,
    t.created_at
FROM RAW.TRANSACTIONS t
JOIN RAW.CUSTOMERS c ON t.customer_id = c.customer_id
LEFT JOIN RAW.PRODUCTS p ON t.product_id = p.product_id;

-- ============================================================================
-- Support Analytics View
-- ============================================================================
CREATE OR REPLACE VIEW V_SUPPORT_ANALYTICS AS
SELECT
    st.ticket_id,
    st.customer_id,
    c.customer_name,
    c.customer_segment,
    st.subject,
    st.issue_type,
    st.priority,
    st.ticket_status,
    st.channel,
    st.assigned_agent_id,
    sa.agent_name,
    sa.department,
    sa.specialization,
    st.created_date,
    st.first_response_date,
    st.resolved_date,
    st.closed_date,
    st.resolution_time_hours,
    CASE
        WHEN st.resolution_time_hours <= 4 THEN 'FAST'
        WHEN st.resolution_time_hours <= 24 THEN 'MODERATE'
        WHEN st.resolution_time_hours <= 72 THEN 'SLOW'
        ELSE 'VERY_SLOW'
    END AS resolution_speed,
    st.satisfaction_rating,
    CASE
        WHEN st.satisfaction_rating >= 4 THEN 'SATISFIED'
        WHEN st.satisfaction_rating >= 3 THEN 'NEUTRAL'
        ELSE 'DISSATISFIED'
    END AS satisfaction_category,
    DATEDIFF('hour', st.created_date, st.first_response_date) AS first_response_time_hours,
    st.created_at,
    st.updated_at
FROM RAW.SUPPORT_TICKETS st
JOIN RAW.CUSTOMERS c ON st.customer_id = c.customer_id
LEFT JOIN RAW.SUPPORT_AGENTS sa ON st.assigned_agent_id = sa.agent_id;

-- ============================================================================
-- Marketing Campaign Performance View
-- ============================================================================
CREATE OR REPLACE VIEW V_CAMPAIGN_PERFORMANCE AS
SELECT
    mc.campaign_id,
    mc.campaign_name,
    mc.campaign_type,
    mc.start_date,
    mc.end_date,
    mc.target_audience,
    mc.budget,
    mc.channel,
    mc.campaign_status,
    COUNT(DISTINCT cci.interaction_id) AS total_interactions,
    COUNT(DISTINCT cci.customer_id) AS unique_customers,
    SUM(CASE WHEN cci.conversion_flag = TRUE THEN 1 ELSE 0 END) AS total_conversions,
    (SUM(CASE WHEN cci.conversion_flag = TRUE THEN 1 ELSE 0 END)::FLOAT / 
     NULLIF(COUNT(DISTINCT cci.interaction_id), 0) * 100) AS conversion_rate,
    SUM(cci.revenue_generated) AS total_revenue,
    (SUM(cci.revenue_generated) / NULLIF(mc.budget, 0)) AS roi,
    mc.created_at
FROM RAW.MARKETING_CAMPAIGNS mc
LEFT JOIN RAW.CUSTOMER_CAMPAIGN_INTERACTIONS cci ON mc.campaign_id = cci.campaign_id
GROUP BY
    mc.campaign_id, mc.campaign_name, mc.campaign_type, mc.start_date, mc.end_date,
    mc.target_audience, mc.budget, mc.channel, mc.campaign_status, mc.created_at;

-- ============================================================================
-- Product Performance View
-- ============================================================================
CREATE OR REPLACE VIEW V_PRODUCT_PERFORMANCE AS
SELECT
    p.product_id,
    p.product_name,
    p.product_category,
    p.product_subcategory,
    p.base_price,
    p.recurring_price,
    p.billing_frequency,
    p.is_active,
    COUNT(DISTINCT t.transaction_id) AS total_sales,
    SUM(t.total_amount) AS total_revenue,
    AVG(t.total_amount) AS avg_transaction_value,
    COUNT(DISTINCT t.customer_id) AS unique_customers,
    p.created_at,
    p.updated_at
FROM RAW.PRODUCTS p
LEFT JOIN RAW.TRANSACTIONS t ON p.product_id = t.product_id
GROUP BY
    p.product_id, p.product_name, p.product_category, p.product_subcategory,
    p.base_price, p.recurring_price, p.billing_frequency, p.is_active,
    p.created_at, p.updated_at;

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All analytical views created successfully' AS status;

SELECT 
    table_name AS view_name,
    comment AS description
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS'
  AND table_name LIKE 'V_%'
ORDER BY table_name;

