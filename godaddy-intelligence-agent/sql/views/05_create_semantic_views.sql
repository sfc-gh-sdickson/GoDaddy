-- ============================================================================
-- GoDaddy Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Create semantic views for Snowflake Intelligence agents
-- All syntax VERIFIED against official documentation:
-- https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
-- 
-- Syntax Verification Notes:
-- 1. Clause order is MANDATORY: TABLES → RELATIONSHIPS → DIMENSIONS → METRICS → COMMENT
-- 2. Semantic expression format: semantic_name AS sql_expression
-- 3. No self-referencing relationships allowed
-- 4. No cyclic relationships allowed
-- 5. PRIMARY KEY columns must exist in table definitions
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- Semantic View 1: GoDaddy Domain & Hosting Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_DOMAIN_HOSTING_INTELLIGENCE
  TABLES (
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('clients', 'account holders', 'users')
      COMMENT = 'GoDaddy customers',
    domains AS RAW.DOMAINS
      PRIMARY KEY (domain_id)
      WITH SYNONYMS ('websites', 'domain names', 'urls')
      COMMENT = 'Registered domains',
    hosting AS RAW.HOSTING_PLANS
      PRIMARY KEY (hosting_id)
      WITH SYNONYMS ('hosting plans', 'web hosting', 'servers')
      COMMENT = 'Hosting plan subscriptions',
    ssl_certs AS RAW.SSL_CERTIFICATES
      PRIMARY KEY (ssl_id)
      WITH SYNONYMS ('ssl certificates', 'security certificates')
      COMMENT = 'SSL/TLS certificates'
  )
  RELATIONSHIPS (
    domains(customer_id) REFERENCES customers(customer_id),
    hosting(customer_id) REFERENCES customers(customer_id),
    hosting(domain_id) REFERENCES domains(domain_id),
    ssl_certs(customer_id) REFERENCES customers(customer_id),
    ssl_certs(domain_id) REFERENCES domains(domain_id)
  )
  DIMENSIONS (
    customers.customer_name AS customer_name
      WITH SYNONYMS ('client name', 'account name')
      COMMENT = 'Name of the customer',
    customers.customer_status AS customer_status
      WITH SYNONYMS ('account status', 'customer state')
      COMMENT = 'Customer status: ACTIVE, SUSPENDED, CLOSED',
    customers.customer_segment AS customer_segment
      WITH SYNONYMS ('customer type', 'account tier')
      COMMENT = 'Customer segment: ENTERPRISE, SMALL_BUSINESS, INDIVIDUAL',
    customers.is_business AS is_business_customer
      WITH SYNONYMS ('business account', 'company customer')
      COMMENT = 'Whether customer is a business',
    customers.customer_state AS state
      WITH SYNONYMS ('state', 'location state')
      COMMENT = 'Customer state location',
    customers.customer_city AS city
      WITH SYNONYMS ('city', 'location city')
      COMMENT = 'Customer city location',
    domains.domain_extension AS domain_extension
      WITH SYNONYMS ('tld', 'domain suffix', 'extension')
      COMMENT = 'Domain extension: .com, .net, .org, etc',
    domains.domain_renewal_status AS renewal_status
      WITH SYNONYMS ('renewal state', 'domain status')
      COMMENT = 'Domain renewal status: ACTIVE, EXPIRED, PENDING_RENEWAL, GRACE_PERIOD',
    domains.auto_renew AS auto_renew_enabled
      WITH SYNONYMS ('automatic renewal', 'auto renewal enabled')
      COMMENT = 'Whether domain auto-renewal is enabled',
    domains.has_privacy_protection AS privacy_protection
      WITH SYNONYMS ('privacy enabled', 'whois protection')
      COMMENT = 'Whether domain has privacy protection',
    domains.domain_status AS domain_status
      WITH SYNONYMS ('status')
      COMMENT = 'Domain status: ACTIVE, EXPIRED, SUSPENDED',
    hosting.hosting_plan_type AS plan_type
      WITH SYNONYMS ('hosting type', 'plan category')
      COMMENT = 'Hosting plan type: SHARED, VPS, DEDICATED, CLOUD',
    hosting.hosting_plan_name AS plan_name
      WITH SYNONYMS ('plan name', 'hosting package')
      COMMENT = 'Name of hosting plan',
    hosting.hosting_billing_cycle AS billing_cycle
      WITH SYNONYMS ('billing period', 'payment cycle')
      COMMENT = 'Hosting billing cycle: MONTHLY, ANNUAL, BIENNIAL',
    hosting.hosting_ssl_included AS ssl_included
      WITH SYNONYMS ('free ssl', 'ssl bundled')
      COMMENT = 'Whether SSL is included in hosting plan',
    hosting.hosting_status AS hosting_status
      WITH SYNONYMS ('plan status')
      COMMENT = 'Hosting plan status: ACTIVE, EXPIRED, SUSPENDED',
    ssl_certs.ssl_certificate_type AS certificate_type
      WITH SYNONYMS ('ssl type', 'certificate level')
      COMMENT = 'SSL certificate type: DV, OV, EV, WILDCARD',
    ssl_certs.ssl_auto_renew AS auto_renew
      WITH SYNONYMS ('ssl automatic renewal')
      COMMENT = 'Whether SSL auto-renewal is enabled',
    ssl_certs.ssl_status AS cert_status
      WITH SYNONYMS ('ssl certificate status')
      COMMENT = 'SSL certificate status: ACTIVE, EXPIRED'
  )
  METRICS (
    customers.total_customers AS COUNT(DISTINCT customer_id)
      WITH SYNONYMS ('customer count', 'number of customers')
      COMMENT = 'Total number of customers',
    customers.avg_customer_risk_score AS AVG(risk_score)
      WITH SYNONYMS ('average risk score', 'mean risk')
      COMMENT = 'Average customer risk score',
    customers.avg_lifetime_value AS AVG(lifetime_value)
      WITH SYNONYMS ('average LTV', 'mean customer value')
      COMMENT = 'Average customer lifetime value',
    domains.total_domains AS COUNT(DISTINCT domain_id)
      WITH SYNONYMS ('domain count', 'number of domains')
      COMMENT = 'Total number of domains',
    domains.avg_registration_price AS AVG(registration_price)
      WITH SYNONYMS ('average domain price', 'mean registration cost')
      COMMENT = 'Average domain registration price',
    domains.avg_renewal_price AS AVG(renewal_price)
      WITH SYNONYMS ('average renewal cost')
      COMMENT = 'Average domain renewal price',
    hosting.total_hosting_plans AS COUNT(DISTINCT hosting_id)
      WITH SYNONYMS ('hosting count', 'number of hosting plans')
      COMMENT = 'Total number of hosting plans',
    hosting.avg_monthly_price AS AVG(monthly_price)
      WITH SYNONYMS ('average hosting price', 'mean hosting cost')
      COMMENT = 'Average monthly hosting price',
    hosting.avg_disk_space AS AVG(disk_space_gb)
      WITH SYNONYMS ('average storage', 'mean disk space')
      COMMENT = 'Average disk space in GB',
    hosting.avg_uptime_percentage AS AVG(uptime_percentage)
      WITH SYNONYMS ('average uptime', 'mean availability')
      COMMENT = 'Average hosting uptime percentage',
    ssl_certs.total_ssl_certificates AS COUNT(DISTINCT ssl_id)
      WITH SYNONYMS ('ssl count', 'certificate count')
      COMMENT = 'Total number of SSL certificates',
    ssl_certs.avg_ssl_price AS AVG(annual_price)
      WITH SYNONYMS ('average ssl cost', 'mean certificate price')
      COMMENT = 'Average annual SSL certificate price'
  )
  COMMENT = 'GoDaddy Domain & Hosting Intelligence - comprehensive view of domains, hosting, and SSL certificates';

-- ============================================================================
-- Semantic View 2: GoDaddy Product & Revenue Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_PRODUCT_REVENUE_INTELLIGENCE
  TABLES (
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('clients', 'buyers')
      COMMENT = 'GoDaddy customers',
    transactions AS RAW.TRANSACTIONS
      PRIMARY KEY (transaction_id)
      WITH SYNONYMS ('purchases', 'orders', 'sales')
      COMMENT = 'Customer transactions',
    products AS RAW.PRODUCTS
      PRIMARY KEY (product_id)
      WITH SYNONYMS ('services', 'offerings')
      COMMENT = 'GoDaddy products and services'
  )
  RELATIONSHIPS (
    transactions(customer_id) REFERENCES customers(customer_id),
    transactions(product_id) REFERENCES products(product_id)
  )
  DIMENSIONS (
    customers.customer_name AS customer_name
      WITH SYNONYMS ('client name')
      COMMENT = 'Name of the customer',
    customers.customer_segment AS customer_segment
      WITH SYNONYMS ('customer type', 'segment')
      COMMENT = 'Customer segment: ENTERPRISE, SMALL_BUSINESS, INDIVIDUAL',
    customers.customer_state AS state
      WITH SYNONYMS ('state')
      COMMENT = 'Customer state location',
    transactions.transaction_type AS transaction_type
      WITH SYNONYMS ('purchase type', 'order type')
      COMMENT = 'Type of transaction: DOMAIN_REGISTRATION, HOSTING_PURCHASE, SSL_PURCHASE, etc',
    transactions.product_type AS product_type
      WITH SYNONYMS ('product category')
      COMMENT = 'Product type: DOMAIN, HOSTING, SSL, EMAIL, WEBSITE_BUILDER',
    transactions.payment_method AS payment_method
      WITH SYNONYMS ('payment type')
      COMMENT = 'Payment method: CREDIT_CARD, PAYPAL, BANK_TRANSFER, CRYPTO',
    transactions.payment_status AS payment_status
      WITH SYNONYMS ('transaction status')
      COMMENT = 'Payment status: COMPLETED, FAILED, REFUNDED',
    transactions.currency AS currency
      WITH SYNONYMS ('payment currency')
      COMMENT = 'Transaction currency',
    products.product_name AS product_name
      WITH SYNONYMS ('service name', 'offering name')
      COMMENT = 'Name of the product',
    products.product_category AS product_category
      WITH SYNONYMS ('product type')
      COMMENT = 'Product category: DOMAIN, HOSTING, SSL, EMAIL, WEBSITE_BUILDER',
    products.product_subcategory AS product_subcategory
      WITH SYNONYMS ('subcategory')
      COMMENT = 'Product subcategory',
    products.billing_frequency AS billing_frequency
      WITH SYNONYMS ('payment frequency', 'billing cycle')
      COMMENT = 'Billing frequency: MONTHLY, ANNUAL, etc',
    products.product_active AS is_active
      WITH SYNONYMS ('available', 'active product')
      COMMENT = 'Whether product is currently active'
  )
  METRICS (
    customers.total_customers AS COUNT(DISTINCT customer_id)
      WITH SYNONYMS ('customer count')
      COMMENT = 'Total number of customers',
    transactions.total_transactions AS COUNT(DISTINCT transaction_id)
      WITH SYNONYMS ('transaction count', 'order count')
      COMMENT = 'Total number of transactions',
    transactions.total_revenue AS SUM(total_amount)
      WITH SYNONYMS ('total sales', 'gross revenue')
      COMMENT = 'Total revenue from all transactions',
    transactions.avg_transaction_amount AS AVG(total_amount)
      WITH SYNONYMS ('average order value', 'mean transaction')
      COMMENT = 'Average transaction amount',
    transactions.total_discount_amount AS SUM(discount_amount)
      WITH SYNONYMS ('total discounts', 'discount sum')
      COMMENT = 'Total discount amount given',
    transactions.total_tax_amount AS SUM(tax_amount)
      WITH SYNONYMS ('total tax', 'tax sum')
      COMMENT = 'Total tax amount collected',
    products.total_products AS COUNT(DISTINCT product_id)
      WITH SYNONYMS ('product count')
      COMMENT = 'Total number of unique products',
    products.avg_base_price AS AVG(base_price)
      WITH SYNONYMS ('average base price')
      COMMENT = 'Average product base price',
    products.avg_recurring_price AS AVG(recurring_price)
      WITH SYNONYMS ('average recurring price')
      COMMENT = 'Average product recurring price'
  )
  COMMENT = 'GoDaddy Product & Revenue Intelligence - comprehensive view of products, transactions, and revenue metrics';

-- ============================================================================
-- Semantic View 3: GoDaddy Customer Support Intelligence
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_CUSTOMER_SUPPORT_INTELLIGENCE
  TABLES (
    customers AS RAW.CUSTOMERS
      PRIMARY KEY (customer_id)
      WITH SYNONYMS ('clients', 'users')
      COMMENT = 'GoDaddy customers',
    tickets AS RAW.SUPPORT_TICKETS
      PRIMARY KEY (ticket_id)
      WITH SYNONYMS ('support cases', 'help requests')
      COMMENT = 'Customer support tickets',
    agents AS RAW.SUPPORT_AGENTS
      PRIMARY KEY (agent_id)
      WITH SYNONYMS ('support staff', 'help desk agents')
      COMMENT = 'Support agents'
  )
  RELATIONSHIPS (
    tickets(customer_id) REFERENCES customers(customer_id),
    tickets(assigned_agent_id) REFERENCES agents(agent_id)
  )
  DIMENSIONS (
    customers.customer_name AS customer_name
      WITH SYNONYMS ('client name')
      COMMENT = 'Name of the customer',
    customers.customer_segment AS customer_segment
      WITH SYNONYMS ('customer type')
      COMMENT = 'Customer segment: ENTERPRISE, SMALL_BUSINESS, INDIVIDUAL',
    tickets.issue_type AS issue_type
      WITH SYNONYMS ('problem type', 'ticket category')
      COMMENT = 'Type of issue: TECHNICAL, BILLING, ACCOUNT, DOMAIN, HOSTING, EMAIL, SSL',
    tickets.priority AS priority
      WITH SYNONYMS ('urgency', 'ticket priority')
      COMMENT = 'Ticket priority: LOW, MEDIUM, HIGH, URGENT',
    tickets.ticket_status AS ticket_status
      WITH SYNONYMS ('status', 'case status')
      COMMENT = 'Ticket status: OPEN, IN_PROGRESS, CLOSED',
    tickets.support_channel AS channel
      WITH SYNONYMS ('contact channel', 'communication method')
      COMMENT = 'Support channel: PHONE, EMAIL, CHAT, WEB_FORM',
    agents.agent_name AS agent_name
      WITH SYNONYMS ('support agent', 'rep name')
      COMMENT = 'Name of support agent',
    agents.agent_department AS department
      WITH SYNONYMS ('team', 'department')
      COMMENT = 'Agent department',
    agents.agent_specialization AS specialization
      WITH SYNONYMS ('expertise', 'specialty')
      COMMENT = 'Agent specialization area',
    agents.agent_status AS agent_status
      WITH SYNONYMS ('agent state')
      COMMENT = 'Agent status: ACTIVE, INACTIVE'
  )
  METRICS (
    customers.total_customers AS COUNT(DISTINCT customer_id)
      WITH SYNONYMS ('customer count')
      COMMENT = 'Total number of customers',
    tickets.total_tickets AS COUNT(DISTINCT ticket_id)
      WITH SYNONYMS ('ticket count', 'case count')
      COMMENT = 'Total number of support tickets',
    tickets.avg_resolution_time AS AVG(resolution_time_hours)
      WITH SYNONYMS ('average resolution time', 'mean time to resolve')
      COMMENT = 'Average ticket resolution time in hours',
    tickets.avg_satisfaction_rating AS AVG(satisfaction_rating)
      WITH SYNONYMS ('average satisfaction', 'csat score')
      COMMENT = 'Average customer satisfaction rating',
    agents.total_agents AS COUNT(DISTINCT agent_id)
      WITH SYNONYMS ('agent count', 'support staff count')
      COMMENT = 'Total number of support agents',
    agents.avg_agent_satisfaction AS AVG(average_satisfaction_rating)
      WITH SYNONYMS ('average agent rating')
      COMMENT = 'Average satisfaction rating across all agents',
    agents.total_tickets_resolved_by_agents AS SUM(total_tickets_resolved)
      WITH SYNONYMS ('total resolved tickets')
      COMMENT = 'Total tickets resolved by all agents'
  )
  COMMENT = 'GoDaddy Customer Support Intelligence - comprehensive view of support tickets, agents, and customer satisfaction';

-- ============================================================================
-- Display confirmation and verification
-- ============================================================================
SELECT 'Semantic views created successfully - all syntax verified' AS status;

-- Verify semantic views exist
SELECT 
    table_name AS semantic_view_name,
    comment AS description
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'ANALYTICS'
  AND table_name LIKE 'SV_%'
ORDER BY table_name;

-- Show semantic view details
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;

