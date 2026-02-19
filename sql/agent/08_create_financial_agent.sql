-- ============================================================================
-- GoDaddy Intelligence Agent - Financial Services Agent Creation
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with ML model tools for
--          financial services analytics
-- Prerequisites: 
--   1. Run all setup scripts (01-06)
--   2. Run notebook ml_financial_models.ipynb to register ML models
--   3. Run 07_ml_model_functions.sql to create wrapper functions
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- Step 1: Create Cortex Search Services for Agent Context
-- ============================================================================

CREATE OR REPLACE CORTEX SEARCH SERVICE FINANCIAL_KNOWLEDGE_SEARCH
ON SEARCH_TEXT
WAREHOUSE = GODADDY_WH
TARGET_LAG = '1 hour'
AS (
    SELECT 
        'Customer LTV Analysis: Use GET_CUSTOMER_LTV_PREDICTIONS() to predict customer lifetime value. High-value customers (LTV > $5000) should receive premium support. LTV prediction considers tenure, product portfolio, transaction history, and satisfaction scores.' AS SEARCH_TEXT,
        'LTV_ANALYSIS' AS CATEGORY
    UNION ALL
    SELECT 
        'Payment Risk Assessment: Use GET_HIGH_RISK_TRANSACTIONS() to identify transactions likely to fail. Risk categories: HIGH_RISK (>70% failure probability), MEDIUM_RISK (40-70%), LOW_RISK (<40%). Consider payment method, customer history, and transaction patterns.',
        'PAYMENT_RISK'
    UNION ALL
    SELECT 
        'Revenue Churn Detection: Use GET_CHURN_RISK_CUSTOMERS() to find customers reducing spending. Early intervention for HIGH_RISK customers can save 30-50% of at-risk revenue. Key indicators: declining transactions, expiring domains, low satisfaction.',
        'CHURN_RISK'
    UNION ALL
    SELECT 
        'Financial Health Overview: Use GET_FINANCIAL_HEALTH_SUMMARY() for key metrics including active customers, average LTV, recent revenue, payment failure rate, high-value customer count, and expiring domains.',
        'FINANCIAL_HEALTH'
);

-- ============================================================================
-- Step 2: Create Tool Specifications for ML Functions
-- ============================================================================

CREATE OR REPLACE FUNCTION TOOL_GET_LTV_PREDICTIONS()
RETURNS TABLE (
    CUSTOMER_ID VARCHAR,
    CUSTOMER_NAME VARCHAR,
    CUSTOMER_SEGMENT VARCHAR,
    CURRENT_LTV NUMBER(12,2),
    PREDICTED_LTV FLOAT,
    LTV_GROWTH_POTENTIAL FLOAT,
    GROWTH_CATEGORY VARCHAR
)
LANGUAGE SQL
COMMENT = 'Predicts customer lifetime value for all active customers using ML model. Returns predicted LTV, growth potential, and growth category (HIGH_GROWTH, MODERATE_GROWTH, LOW_GROWTH, DECLINING).'
AS
$$
    SELECT * FROM TABLE(GET_CUSTOMER_LTV_PREDICTIONS()) LIMIT 100
$$;

CREATE OR REPLACE FUNCTION TOOL_GET_TOP_CUSTOMERS(N NUMBER DEFAULT 10)
RETURNS TABLE (
    RANK_NUM NUMBER,
    CUSTOMER_ID VARCHAR,
    CUSTOMER_NAME VARCHAR,
    CUSTOMER_SEGMENT VARCHAR,
    PREDICTED_LTV FLOAT
)
LANGUAGE SQL
COMMENT = 'Returns top N customers by predicted lifetime value. Use to identify highest-value customers for retention efforts.'
AS
$$
    SELECT * FROM TABLE(GET_TOP_LTV_CUSTOMERS(N))
$$;

CREATE OR REPLACE FUNCTION TOOL_GET_PAYMENT_RISKS()
RETURNS TABLE (
    TRANSACTION_ID VARCHAR,
    CUSTOMER_ID VARCHAR,
    CUSTOMER_NAME VARCHAR,
    TOTAL_AMOUNT NUMBER(12,2),
    PAYMENT_METHOD VARCHAR,
    FAILURE_PROBABILITY FLOAT,
    RISK_CATEGORY VARCHAR
)
LANGUAGE SQL
COMMENT = 'Identifies pending/recent transactions at risk of payment failure using ML model. Returns failure probability and risk category (HIGH_RISK, MEDIUM_RISK, LOW_RISK).'
AS
$$
    SELECT * FROM TABLE(GET_HIGH_RISK_TRANSACTIONS()) LIMIT 100
$$;

CREATE OR REPLACE FUNCTION TOOL_GET_CHURN_RISKS()
RETURNS TABLE (
    CUSTOMER_ID VARCHAR,
    CUSTOMER_NAME VARCHAR,
    CUSTOMER_SEGMENT VARCHAR,
    REVENUE_LAST_3M NUMBER(12,2),
    REVENUE_CHANGE_PCT FLOAT,
    CHURN_PROBABILITY FLOAT,
    CHURN_RISK_LEVEL VARCHAR,
    RECOMMENDED_ACTION VARCHAR
)
LANGUAGE SQL
COMMENT = 'Identifies customers at risk of revenue churn using ML model. Returns churn probability, risk level, and recommended retention actions.'
AS
$$
    SELECT * FROM TABLE(GET_CHURN_RISK_CUSTOMERS()) LIMIT 100
$$;

CREATE OR REPLACE FUNCTION TOOL_GET_FINANCIAL_SUMMARY()
RETURNS TABLE (
    METRIC_NAME VARCHAR,
    METRIC_VALUE VARCHAR,
    METRIC_CATEGORY VARCHAR
)
LANGUAGE SQL
COMMENT = 'Returns key financial health metrics: active customers, average LTV, recent revenue, payment failure rate, high-value customer count, and expiring domains.'
AS
$$
    SELECT * FROM TABLE(GET_FINANCIAL_HEALTH_SUMMARY())
$$;

-- ============================================================================
-- Step 3: Create the Financial Intelligence Agent
-- ============================================================================

CREATE OR REPLACE CORTEX AGENT GODADDY_FINANCIAL_AGENT
WAREHOUSE = GODADDY_WH
SYSTEM_PROMPT = 'You are a financial analytics assistant for GoDaddy. You help analyze customer lifetime value, payment risks, revenue churn, and overall financial health. You have access to ML models that predict customer behavior and financial outcomes.

When answering questions:
1. Use TOOL_GET_FINANCIAL_SUMMARY for overall financial health questions
2. Use TOOL_GET_LTV_PREDICTIONS for customer lifetime value analysis
3. Use TOOL_GET_TOP_CUSTOMERS to identify highest-value customers
4. Use TOOL_GET_PAYMENT_RISKS for payment failure risk assessment
5. Use TOOL_GET_CHURN_RISKS for revenue churn analysis

Always provide specific numbers and actionable recommendations. Format currency values with $ and two decimal places. Categorize risks as HIGH, MEDIUM, or LOW when applicable.'
TOOLS = (
    TOOL_GET_FINANCIAL_SUMMARY,
    TOOL_GET_LTV_PREDICTIONS,
    TOOL_GET_TOP_CUSTOMERS,
    TOOL_GET_PAYMENT_RISKS,
    TOOL_GET_CHURN_RISKS
)
SEARCH_SERVICES = (
    GODADDY_INTELLIGENCE.ANALYTICS.FINANCIAL_KNOWLEDGE_SEARCH,
    GODADDY_INTELLIGENCE.ANALYTICS.CUSTOMER_SEARCH,
    GODADDY_INTELLIGENCE.ANALYTICS.DOMAIN_SEARCH,
    GODADDY_INTELLIGENCE.ANALYTICS.SUPPORT_SEARCH
)
SEMANTIC_MODELS = (
    GODADDY_INTELLIGENCE.ANALYTICS.CUSTOMER_SEMANTIC_VIEW,
    GODADDY_INTELLIGENCE.ANALYTICS.REVENUE_SEMANTIC_VIEW
);

-- ============================================================================
-- Step 4: Grant Permissions
-- ============================================================================

GRANT USAGE ON FUNCTION TOOL_GET_FINANCIAL_SUMMARY() TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION TOOL_GET_LTV_PREDICTIONS() TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION TOOL_GET_TOP_CUSTOMERS(NUMBER) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION TOOL_GET_PAYMENT_RISKS() TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION TOOL_GET_CHURN_RISKS() TO ROLE PUBLIC;

-- ============================================================================
-- Step 5: Verification
-- ============================================================================

SELECT 'GoDaddy Financial Intelligence Agent created successfully' AS STATUS;

SHOW CORTEX AGENTS IN SCHEMA GODADDY_INTELLIGENCE.ANALYTICS;

-- ============================================================================
-- Sample Questions to Test the Agent
-- ============================================================================
/*
Test the agent with these sample questions:

FINANCIAL HEALTH:
- "What is our current financial health?"
- "Show me the key financial metrics for this month"
- "How many high-value customers do we have?"

CUSTOMER LTV:
- "Who are our top 10 highest value customers?"
- "Which customers have the highest growth potential?"
- "Show me customers with declining LTV"
- "What is the predicted lifetime value for enterprise customers?"

PAYMENT RISK:
- "Are there any high-risk transactions pending?"
- "Which transactions are most likely to fail?"
- "Show me payment risk by payment method"
- "What is our current payment failure rate?"

REVENUE CHURN:
- "Which customers are at risk of churning?"
- "Show me high-risk churn customers that need immediate attention"
- "What actions should we take for customers with declining revenue?"
- "How many customers have reduced their spending in the last 3 months?"

COMBINED ANALYSIS:
- "Give me a complete financial risk assessment"
- "Which enterprise customers need retention outreach?"
- "What is the total revenue at risk from churning customers?"
*/
