-- ============================================================================
-- GoDaddy Intelligence Agent - Financial Services Agent Creation
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with ML model tools for
--          financial services analytics
-- Prerequisites: 
--   1. Run scripts 01-06 in order
--   2. Run 07_ml_model_functions.sql to create views and functions
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- Create Cortex Agent
-- ============================================================================
CREATE OR REPLACE AGENT GODADDY_FINANCIAL_AGENT
  COMMENT = 'GoDaddy financial analytics agent with ML predictions and semantic search'
  PROFILE = '{"display_name": "GoDaddy Financial Assistant", "color": "blue"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: "You are a helpful financial analytics assistant for GoDaddy. Provide clear, accurate answers about customer lifetime value, payment risks, revenue churn, and financial health. When using ML predictions, explain the insights clearly. Always cite data sources."
    orchestration: "For customer and revenue data use RevenueAnalyst. For support transcripts use SupportSearch. For customer LTV predictions use LTV_Predictions. For top customers use Top_Customers. For payment risk use Payment_Risks. For churn risk use Churn_Risks. For financial health metrics use Financial_Summary."
    system: "You are an expert financial analytics assistant. You help analyze customer lifetime value, payment risks, revenue churn patterns, and overall financial health for GoDaddy."
    sample_questions:
      # Customer Lifetime Value Questions
      - question: "Who are our top 10 highest value customers?"
        answer: "I'll use Top_Customers to retrieve the top 10 customers by predicted lifetime value."
      - question: "Which customers have the highest LTV growth potential?"
        answer: "I'll use LTV_Predictions to find customers with HIGH_GROWTH category."
      - question: "Show me customers with declining LTV predictions"
        answer: "I'll use LTV_Predictions to filter for customers in the DECLINING growth category."
      - question: "What is the predicted lifetime value for enterprise customers?"
        answer: "I'll use LTV_Predictions filtered by enterprise segment."
      
      # Payment Risk Questions
      - question: "Are there any high-risk transactions pending?"
        answer: "I'll use Payment_Risks to find transactions with failure_probability >= 0.7."
      - question: "Which transactions are most likely to fail?"
        answer: "I'll use Payment_Risks to get transactions sorted by failure probability descending."
      - question: "Show me payment risk by payment method"
        answer: "I'll use Payment_Risks and group results by payment_method to analyze risk distribution."
      
      # Revenue Churn Questions
      - question: "Which customers are at risk of churning?"
        answer: "I'll use Churn_Risks to identify customers with elevated churn probability."
      - question: "Show me high-risk churn customers that need immediate attention"
        answer: "I'll use Churn_Risks filtered for HIGH_RISK level customers."
      - question: "Which enterprise customers need retention outreach?"
        answer: "I'll use Churn_Risks filtered for enterprise segment with elevated risk."
      
      # Financial Health Questions
      - question: "What is our current financial health?"
        answer: "I'll use Financial_Summary to provide key metrics including active customers, average LTV, and risk indicators."
      - question: "Give me a complete financial risk assessment"
        answer: "I'll combine Financial_Summary, Payment_Risks, and Churn_Risks for a comprehensive view."
      - question: "What is our payment failure rate?"
        answer: "I'll use Financial_Summary which includes the current payment failure rate metric."
      - question: "How many high-value customers do we have?"
        answer: "I'll use Financial_Summary to get the count of customers with LTV > $5000."

  tools:
    # Semantic View for Cortex Analyst
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "RevenueAnalyst"
        description: "Analyzes structured financial data including customers, transactions, revenue trends, and product performance. Use for questions about sales, revenue, and customer data."

    # Cortex Search Service
    - tool_spec:
        type: "cortex_search"
        name: "SupportSearch"
        description: "Searches support transcripts and documentation. Use when users ask about support interactions, customer complaints, or service issues."

    # ML Model Functions
    - tool_spec:
        type: "generic"
        name: "LTV_Predictions"
        description: "Returns ML-predicted customer lifetime values with growth potential and category (HIGH_GROWTH, MODERATE_GROWTH, LOW_GROWTH, DECLINING)."

    - tool_spec:
        type: "generic"
        name: "Top_Customers"
        description: "Returns the top 10 highest predicted lifetime value customers with rank, segment, and growth category."

    - tool_spec:
        type: "generic"
        name: "Payment_Risks"
        description: "Returns transactions at risk of payment failure with probability scores and risk categories (HIGH_RISK, MEDIUM_RISK, LOW_RISK)."

    - tool_spec:
        type: "generic"
        name: "Churn_Risks"
        description: "Returns customers at risk of revenue churn with probability scores, risk levels, and recommended retention actions."

    - tool_spec:
        type: "generic"
        name: "Financial_Summary"
        description: "Returns key financial health metrics: active customers, average LTV, recent revenue, payment failure rate, high-value customer count, expiring domains."

  tool_resources:
    # Semantic View Resource
    RevenueAnalyst:
      semantic_view: "GODADDY_INTELLIGENCE.ANALYTICS.SV_PRODUCT_REVENUE_INTELLIGENCE"

    # Cortex Search Resource
    SupportSearch:
      name: "GODADDY_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH"
      max_results: "10"
      title_column: "ticket_id"
      id_column: "transcript_id"

    # ML Model Function Resources
    LTV_Predictions:
      type: "function"
      identifier: "GODADDY_INTELLIGENCE.ANALYTICS.AGENT_GET_LTV_PREDICTIONS"
      execution_environment:
        type: "warehouse"
        warehouse: "GODADDY_WH"

    Top_Customers:
      type: "function"
      identifier: "GODADDY_INTELLIGENCE.ANALYTICS.AGENT_GET_TOP_CUSTOMERS"
      execution_environment:
        type: "warehouse"
        warehouse: "GODADDY_WH"

    Payment_Risks:
      type: "function"
      identifier: "GODADDY_INTELLIGENCE.ANALYTICS.AGENT_GET_PAYMENT_RISKS"
      execution_environment:
        type: "warehouse"
        warehouse: "GODADDY_WH"

    Churn_Risks:
      type: "function"
      identifier: "GODADDY_INTELLIGENCE.ANALYTICS.AGENT_GET_CHURN_RISKS"
      execution_environment:
        type: "warehouse"
        warehouse: "GODADDY_WH"

    Financial_Summary:
      type: "function"
      identifier: "GODADDY_INTELLIGENCE.ANALYTICS.AGENT_GET_FINANCIAL_SUMMARY"
      execution_environment:
        type: "warehouse"
        warehouse: "GODADDY_WH"
  $$;

-- ============================================================================
-- Permissions
-- ============================================================================
GRANT USAGE ON AGENT GODADDY_FINANCIAL_AGENT TO ROLE SYSADMIN;

SELECT 'GoDaddy Financial Intelligence Agent created successfully' AS STATUS;
SHOW AGENTS IN SCHEMA ANALYTICS;
