-- ============================================================================
-- GoDaddy Intelligence Agent - Financial Services Agent Creation
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with ML model tools for
--          financial services analytics
-- Prerequisites: 
--   1. Run all setup scripts (01-06)
--   2. Run notebook ml_financial_models.ipynb to register ML models
--   3. Run 07_ml_model_functions.sql to create wrapper functions and views
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- Create the Financial Intelligence Agent
-- ============================================================================

CREATE OR REPLACE AGENT GODADDY_FINANCIAL_AGENT
  COMMENT = 'Financial analytics agent for GoDaddy with ML-powered predictions'
  FROM SPECIFICATION
$$
models:
  orchestration: claude-4-sonnet

orchestration:
  budget:
    seconds: 60
    tokens: 16000

instructions:
  system: |
    You are a financial analytics assistant for GoDaddy. You help analyze customer lifetime value, 
    payment risks, revenue churn, and overall financial health. You have access to ML models that 
    predict customer behavior and financial outcomes.
    
    Always provide specific numbers and actionable recommendations. Format currency values with $ 
    and two decimal places. Categorize risks as HIGH, MEDIUM, or LOW when applicable.
  
  orchestration: |
    Use RevenueAnalyst for structured data queries about customers, transactions, and revenue.
    Use SupportSearch for policy questions and documentation.
    Use LTV_Predictions for customer lifetime value analysis.
    Use Top_Customers for identifying highest-value customers.
    Use Payment_Risks for payment failure risk assessment.
    Use Churn_Risks for revenue churn analysis.
    Use Financial_Summary for overall financial health metrics.
  
  response: |
    Always provide specific numbers and actionable recommendations.
    Format currency values with $ and two decimal places.
    Categorize risks as HIGH, MEDIUM, or LOW when applicable.
    When showing customer lists, include relevant context like segment and risk level.
  
  sample_questions:
    - question: "Who are our top 10 highest value customers?"
      answer: "I'll use the Top_Customers tool to identify customers with the highest predicted lifetime value."
    - question: "Are there any high-risk transactions pending?"
      answer: "I'll use the Payment_Risks tool to find transactions with elevated failure probability."
    - question: "Which customers are at risk of churning?"
      answer: "I'll use the Churn_Risks tool to identify customers showing revenue decline patterns."
    - question: "What is our current financial health?"
      answer: "I'll use the Financial_Summary tool to provide key metrics including active customers, average LTV, and risk indicators."
    - question: "Which customers have the highest LTV growth potential?"
      answer: "I'll use the LTV_Predictions tool to find customers with significant predicted value increase."
    - question: "Show me enterprise customers at risk of leaving"
      answer: "I'll use the Churn_Risks tool filtered for enterprise segment to identify at-risk high-value accounts."
    - question: "What is our payment failure rate?"
      answer: "I'll use the Financial_Summary tool which includes the current payment failure rate metric."
    - question: "Give me a complete financial risk assessment"
      answer: "I'll combine data from Financial_Summary, Payment_Risks, and Churn_Risks to provide a comprehensive risk overview."
    - question: "Which customers need immediate retention outreach?"
      answer: "I'll use the Churn_Risks tool to find HIGH_RISK customers with recommended immediate action."
    - question: "Show customers with declining LTV predictions"
      answer: "I'll use the LTV_Predictions tool and filter for customers in the DECLINING growth category."

tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: RevenueAnalyst
      description: "Analyzes structured financial data including customers, transactions, revenue trends, and product performance"
  
  - tool_spec:
      type: cortex_search
      name: SupportSearch
      description: "Searches support transcripts and documentation for policy and procedure information"
  
  - tool_spec:
      type: generic
      name: LTV_Predictions
      description: "Returns ML-predicted customer lifetime values with growth potential and category (HIGH_GROWTH, MODERATE_GROWTH, LOW_GROWTH, DECLINING)"
  
  - tool_spec:
      type: generic
      name: Top_Customers
      description: "Returns the top 10 highest predicted lifetime value customers"
  
  - tool_spec:
      type: generic
      name: Payment_Risks
      description: "Returns transactions at risk of payment failure with probability scores and risk categories (HIGH_RISK, MEDIUM_RISK, LOW_RISK)"
  
  - tool_spec:
      type: generic
      name: Churn_Risks
      description: "Returns customers at risk of revenue churn with probability scores, risk levels, and recommended retention actions"
  
  - tool_spec:
      type: generic
      name: Financial_Summary
      description: "Returns key financial health metrics: active customers, average LTV, recent revenue, payment failure rate, high-value customer count, expiring domains"

tool_resources:
  RevenueAnalyst:
    semantic_view: "GODADDY_INTELLIGENCE.ANALYTICS.SV_PRODUCT_REVENUE_INTELLIGENCE"
    execution_environment:
      type: warehouse
      warehouse: GODADDY_WH
      query_timeout: 60
  
  SupportSearch:
    search_service: "GODADDY_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH"
    max_results: 5
    title_column: "ticket_id"
    id_column: "transcript_id"
  
  LTV_Predictions:
    type: function
    execution_environment:
      type: warehouse
      warehouse: GODADDY_WH
      query_timeout: 60
    identifier: "GODADDY_INTELLIGENCE.ANALYTICS.GET_CUSTOMER_LTV_PREDICTIONS"
  
  Top_Customers:
    type: function
    execution_environment:
      type: warehouse
      warehouse: GODADDY_WH
      query_timeout: 60
    identifier: "GODADDY_INTELLIGENCE.ANALYTICS.GET_TOP_LTV_CUSTOMERS"
  
  Payment_Risks:
    type: function
    execution_environment:
      type: warehouse
      warehouse: GODADDY_WH
      query_timeout: 60
    identifier: "GODADDY_INTELLIGENCE.ANALYTICS.GET_HIGH_RISK_TRANSACTIONS"
  
  Churn_Risks:
    type: function
    execution_environment:
      type: warehouse
      warehouse: GODADDY_WH
      query_timeout: 60
    identifier: "GODADDY_INTELLIGENCE.ANALYTICS.GET_CHURN_RISK_CUSTOMERS"
  
  Financial_Summary:
    type: function
    execution_environment:
      type: warehouse
      warehouse: GODADDY_WH
      query_timeout: 60
    identifier: "GODADDY_INTELLIGENCE.ANALYTICS.GET_FINANCIAL_HEALTH_SUMMARY"
$$;

-- ============================================================================
-- Grant Permissions
-- ============================================================================

GRANT USAGE ON AGENT GODADDY_FINANCIAL_AGENT TO ROLE PUBLIC;

-- ============================================================================
-- Verification
-- ============================================================================

SELECT 'GoDaddy Financial Intelligence Agent created successfully' AS STATUS;

SHOW AGENTS IN SCHEMA GODADDY_INTELLIGENCE.ANALYTICS;

DESCRIBE AGENT GODADDY_FINANCIAL_AGENT;

-- ============================================================================
-- Sample Questions to Test the Agent (10 ML-Powered Questions)
-- ============================================================================
/*
Test the agent with these sample questions:

CUSTOMER LIFETIME VALUE (ML Model: CUSTOMER_LTV_PREDICTOR):
1. "Who are our top 10 highest value customers?"
2. "Which customers have the highest LTV growth potential?"
3. "Show me customers with declining LTV predictions"
4. "What is the predicted lifetime value for enterprise customers?"

PAYMENT RISK (ML Model: PAYMENT_FAILURE_RISK):
5. "Are there any high-risk transactions pending?"
6. "Which transactions are most likely to fail?"
7. "Show me payment risk by payment method"

REVENUE CHURN (ML Model: REVENUE_CHURN_PREDICTOR):
8. "Which customers are at risk of churning?"
9. "Show me high-risk churn customers that need immediate attention"
10. "Which enterprise customers need retention outreach?"

FINANCIAL HEALTH (Combined):
11. "What is our current financial health?"
12. "Give me a complete financial risk assessment"
13. "What is our payment failure rate?"
14. "How many high-value customers do we have?"

COMBINED ANALYSIS:
15. "Find high-value customers who are also at churn risk"
16. "What is the total revenue at risk from churning customers?"
*/
