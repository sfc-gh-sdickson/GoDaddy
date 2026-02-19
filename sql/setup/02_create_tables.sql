-- ============================================================================
-- GoDaddy Intelligence Agent - Table Definitions
-- ============================================================================
-- Purpose: Create all necessary tables for the GoDaddy business model
-- Based on verified Early-Warning template structure
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- CUSTOMERS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CUSTOMERS (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    state VARCHAR(50),
    city VARCHAR(100),
    signup_date DATE NOT NULL,
    customer_status VARCHAR(20) DEFAULT 'ACTIVE',
    customer_segment VARCHAR(30),
    lifetime_value NUMBER(12,2) DEFAULT 0.00,
    risk_score NUMBER(5,2),
    is_business_customer BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- DOMAINS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE DOMAINS (
    domain_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    domain_name VARCHAR(255) NOT NULL,
    domain_extension VARCHAR(20),
    registration_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    renewal_status VARCHAR(30) DEFAULT 'ACTIVE',
    auto_renew_enabled BOOLEAN DEFAULT TRUE,
    registration_price NUMBER(10,2),
    renewal_price NUMBER(10,2),
    privacy_protection BOOLEAN DEFAULT FALSE,
    nameservers VARCHAR(500),
    domain_status VARCHAR(30) DEFAULT 'ACTIVE',
    transfer_locked BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- HOSTING_PLANS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE HOSTING_PLANS (
    hosting_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    domain_id VARCHAR(30),
    plan_type VARCHAR(50) NOT NULL,
    plan_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    billing_cycle VARCHAR(20),
    monthly_price NUMBER(10,2),
    disk_space_gb NUMBER(10,2),
    bandwidth_gb NUMBER(10,2),
    email_accounts_limit NUMBER(10,0),
    databases_limit NUMBER(10,0),
    ssl_included BOOLEAN DEFAULT FALSE,
    hosting_status VARCHAR(30) DEFAULT 'ACTIVE',
    uptime_percentage NUMBER(5,2) DEFAULT 99.99,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (domain_id) REFERENCES DOMAINS(domain_id)
);

-- ============================================================================
-- TRANSACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE TRANSACTIONS (
    transaction_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    transaction_date TIMESTAMP_NTZ NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    product_type VARCHAR(50),
    product_id VARCHAR(30),
    amount NUMBER(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    payment_method VARCHAR(30),
    payment_status VARCHAR(30) DEFAULT 'COMPLETED',
    discount_amount NUMBER(10,2) DEFAULT 0.00,
    tax_amount NUMBER(10,2) DEFAULT 0.00,
    total_amount NUMBER(12,2) NOT NULL,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- SUPPORT_TICKETS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_TICKETS (
    ticket_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    subject VARCHAR(500) NOT NULL,
    issue_type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    ticket_status VARCHAR(30) DEFAULT 'OPEN',
    channel VARCHAR(30),
    assigned_agent_id VARCHAR(20),
    created_date TIMESTAMP_NTZ NOT NULL,
    first_response_date TIMESTAMP_NTZ,
    resolved_date TIMESTAMP_NTZ,
    closed_date TIMESTAMP_NTZ,
    resolution_time_hours NUMBER(10,2),
    satisfaction_rating NUMBER(3,0),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- WEBSITE_BUILDER_SUBSCRIPTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE WEBSITE_BUILDER_SUBSCRIPTIONS (
    subscription_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    domain_id VARCHAR(30),
    builder_type VARCHAR(50) NOT NULL,
    template_name VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE,
    monthly_price NUMBER(10,2),
    features_enabled VARCHAR(500),
    storage_used_gb NUMBER(10,2),
    page_views_monthly NUMBER(12,0),
    subscription_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (domain_id) REFERENCES DOMAINS(domain_id)
);

-- ============================================================================
-- EMAIL_SERVICES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE EMAIL_SERVICES (
    email_service_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    domain_id VARCHAR(30) NOT NULL,
    service_type VARCHAR(50) NOT NULL,
    mailbox_count NUMBER(10,0),
    storage_per_mailbox_gb NUMBER(10,2),
    start_date DATE NOT NULL,
    end_date DATE,
    monthly_price NUMBER(10,2),
    service_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (domain_id) REFERENCES DOMAINS(domain_id)
);

-- ============================================================================
-- SSL_CERTIFICATES TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SSL_CERTIFICATES (
    ssl_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    domain_id VARCHAR(30) NOT NULL,
    certificate_type VARCHAR(50) NOT NULL,
    issue_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    annual_price NUMBER(10,2),
    cert_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (domain_id) REFERENCES DOMAINS(domain_id)
);

-- ============================================================================
-- MARKETING_CAMPAIGNS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE MARKETING_CAMPAIGNS (
    campaign_id VARCHAR(30) PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    campaign_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    target_audience VARCHAR(100),
    budget NUMBER(12,2),
    channel VARCHAR(50),
    campaign_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- CUSTOMER_CAMPAIGN_INTERACTIONS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE CUSTOMER_CAMPAIGN_INTERACTIONS (
    interaction_id VARCHAR(30) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    campaign_id VARCHAR(30) NOT NULL,
    interaction_date TIMESTAMP_NTZ NOT NULL,
    interaction_type VARCHAR(50) NOT NULL,
    conversion_flag BOOLEAN DEFAULT FALSE,
    revenue_generated NUMBER(12,2) DEFAULT 0.00,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (campaign_id) REFERENCES MARKETING_CAMPAIGNS(campaign_id)
);

-- ============================================================================
-- SUPPORT_AGENTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_AGENTS (
    agent_id VARCHAR(20) PRIMARY KEY,
    agent_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL,
    department VARCHAR(50),
    specialization VARCHAR(100),
    hire_date DATE,
    average_satisfaction_rating NUMBER(3,2),
    total_tickets_resolved NUMBER(10,0) DEFAULT 0,
    agent_status VARCHAR(30) DEFAULT 'ACTIVE',
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- PRODUCTS TABLE
-- ============================================================================
CREATE OR REPLACE TABLE PRODUCTS (
    product_id VARCHAR(30) PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    product_subcategory VARCHAR(50),
    base_price NUMBER(10,2),
    recurring_price NUMBER(10,2),
    billing_frequency VARCHAR(20),
    product_description VARCHAR(1000),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    updated_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Display confirmation
-- ============================================================================
SELECT 'All tables created successfully' AS status;
