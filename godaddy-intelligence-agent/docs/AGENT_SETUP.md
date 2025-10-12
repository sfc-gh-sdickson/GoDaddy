# GoDaddy Intelligence Agent - Setup Guide

This guide walks through configuring a Snowflake Intelligence agent for GoDaddy's domain, hosting, and customer intelligence solution.

---

## Prerequisites

1. **Snowflake Account** with:
   - Snowflake Intelligence (Cortex) enabled
   - Appropriate warehouse size (recommended: X-SMALL or larger)
   - Permissions to create databases, schemas, tables, and semantic views

2. **Roles and Permissions**:
   - `ACCOUNTADMIN` role or equivalent for initial setup
   - `CREATE DATABASE` privilege
   - `CREATE SEMANTIC VIEW` privilege
   - `CREATE CORTEX SEARCH SERVICE` privilege
   - `USAGE` on warehouses

---

## Step 1: Execute SQL Scripts in Order

Execute the SQL files in the following sequence:

### 1.1 Database Setup
```sql
-- Execute: sql/setup/01_database_and_schema.sql
-- Creates database, schemas (RAW, ANALYTICS), and warehouse
-- Execution time: < 1 second
```

### 1.2 Create Tables
```sql
-- Execute: sql/setup/02_create_tables.sql
-- Creates all table structures with proper relationships
-- Tables: CUSTOMERS, DOMAINS, HOSTING_PLANS, TRANSACTIONS, SUPPORT_TICKETS,
--         WEBSITE_BUILDER_SUBSCRIPTIONS, EMAIL_SERVICES, SSL_CERTIFICATES,
--         SUPPORT_AGENTS, PRODUCTS, MARKETING_CAMPAIGNS, etc.
-- Execution time: < 5 seconds
```

### 1.3 Generate Sample Data
```sql
-- Execute: sql/data/03_generate_synthetic_data.sql
-- Generates realistic sample data:
--   - 100,000 customers
--   - 150,000 domains
--   - 200,000 hosting plans
--   - 2,000,000 transactions
--   - 150,000 support tickets
--   - Various other entities
-- Execution time: 5-15 minutes (depending on warehouse size)
```

### 1.4 Create Analytical Views
```sql
-- Execute: sql/views/04_create_views.sql
-- Creates curated analytical views:
--   - V_CUSTOMER_360
--   - V_DOMAIN_ANALYTICS
--   - V_HOSTING_PERFORMANCE
--   - V_REVENUE_ANALYTICS
--   - V_SUPPORT_ANALYTICS
--   - V_CAMPAIGN_PERFORMANCE
--   - V_PRODUCT_PERFORMANCE
-- Execution time: < 5 seconds
```

### 1.5 Create Semantic Views
```sql
-- Execute: sql/views/05_create_semantic_views.sql
-- Creates semantic views for AI agents (VERIFIED SYNTAX):
--   - SV_DOMAIN_HOSTING_INTELLIGENCE
--   - SV_PRODUCT_REVENUE_INTELLIGENCE
--   - SV_CUSTOMER_SUPPORT_INTELLIGENCE
-- Execution time: < 5 seconds
```

### 1.6 Create Cortex Search Services
```sql
-- Execute: sql/search/06_create_cortex_search.sql
-- Creates tables for unstructured text data:
--   - SUPPORT_TRANSCRIPTS (50,000 support interactions)
--   - DOMAIN_TRANSFER_NOTES (25,000 transfer notes)
--   - KNOWLEDGE_BASE_ARTICLES (5 help articles)
-- Creates Cortex Search services for semantic search:
--   - SUPPORT_TRANSCRIPTS_SEARCH
--   - DOMAIN_TRANSFER_NOTES_SEARCH
--   - KNOWLEDGE_BASE_SEARCH
-- Execution time: 3-5 minutes (data generation + index building)
```

---

## Step 2: Create Snowflake Intelligence Agent

### 2.1 Via Snowsight UI

1. Navigate to **Snowsight** (Snowflake Web UI)
2. Go to **AI & ML** → **Agents**
3. Click **Create Agent**
4. Configure the agent:

**Basic Settings:**
```yaml
Name: GoDaddy_Intelligence_Agent
Description: AI agent for analyzing GoDaddy customer data, domains, hosting services, and revenue intelligence
```

**Data Sources (Semantic Views):**
Add the following semantic views:
- `GODADDY_INTELLIGENCE.ANALYTICS.SV_DOMAIN_HOSTING_INTELLIGENCE`
- `GODADDY_INTELLIGENCE.ANALYTICS.SV_PRODUCT_REVENUE_INTELLIGENCE`
- `GODADDY_INTELLIGENCE.ANALYTICS.SV_CUSTOMER_SUPPORT_INTELLIGENCE`

**Warehouse:**
- Select: `GODADDY_WH`

**Instructions (System Prompt):**
```
You are an AI intelligence agent for GoDaddy, the world's largest domain registrar and web hosting provider.

Your role is to analyze:
1. Domain Portfolio: Registrations, renewals, extensions, expirations
2. Hosting Services: Performance, uptime, plan types, usage
3. Customer Intelligence: Segments, lifetime value, risk scores, behavior
4. Revenue Analytics: Transactions, pricing, product performance
5. Support Operations: Ticket resolution, agent performance, satisfaction

When answering questions:
- Provide specific metrics and data-driven insights
- Compare trends over time and across dimensions
- Highlight renewal risks and revenue opportunities
- Benchmark performance across products and segments
- Calculate rates, percentages, and derived metrics
- Identify actionable recommendations

Data Context:
- Domains: Registrations across .com, .net, .org, .io, and other extensions
- Hosting: SHARED, VPS, DEDICATED, CLOUD hosting plans
- Services: Email, Website Builder, SSL certificates
- Customer Segments: ENTERPRISE, SMALL_BUSINESS, INDIVIDUAL
- Support Channels: PHONE, EMAIL, CHAT, WEB_FORM
```

5. Click **Create Agent**

---

## Step 3: Add Cortex Search Services to Agent

### 3.1 Add Support Transcripts Search

1. In Agent settings, click **Tools**
2. Find **Cortex Search** and click **+ Add**
3. Configure:
   - **Name**: Support Transcripts Search
   - **Search service**: `GODADDY_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH`
   - **Warehouse**: `GODADDY_WH`
   - **Description**:
     ```
     Search 50,000 customer support transcripts to find similar issues,
     resolution procedures, and support best practices. Use for questions
     about customer service patterns, technical troubleshooting, and
     support efficiency.
     ```

### 3.2 Add Domain Transfer Notes Search

1. Click **+ Add** again for Cortex Search
2. Configure:
   - **Name**: Domain Transfer Notes Search
   - **Search service**: `GODADDY_INTELLIGENCE.RAW.DOMAIN_TRANSFER_NOTES_SEARCH`
   - **Warehouse**: `GODADDY_WH`
   - **Description**:
     ```
     Search 25,000 domain transfer notes to find similar transfer cases,
     common issues, and resolution procedures. Use for questions about
     domain transfers, registrar changes, and transfer troubleshooting.
     ```

### 3.3 Add Knowledge Base Search

1. Click **+ Add** again for Cortex Search
2. Configure:
   - **Name**: Knowledge Base Search
   - **Search service**: `GODADDY_INTELLIGENCE.RAW.KNOWLEDGE_BASE_SEARCH`
   - **Warehouse**: `GODADDY_WH`
   - **Description**:
     ```
     Search help articles and documentation for setup guides, configuration
     instructions, and troubleshooting procedures. Use for questions about
     product features, setup procedures, and technical guidance.
     ```

---

## Step 4: Test the Agent

### 4.1 Simple Test Questions

Start with simple questions to verify connectivity:

1. **"How many customers does GoDaddy have?"**
   - Should query SV_DOMAIN_HOSTING_INTELLIGENCE
   - Expected: ~100,000 customers

2. **"What is the total number of domains registered?"**
   - Should query SV_DOMAIN_HOSTING_INTELLIGENCE
   - Expected: ~150,000 domains

3. **"How many support tickets are currently open?"**
   - Should query SV_CUSTOMER_SUPPORT_INTELLIGENCE
   - Expected: Count of tickets with status = 'OPEN'

### 4.2 Complex Test Questions

Test with the 10 complex questions provided in `docs/questions.md`, including:

1. Domain Renewal Risk Analysis
2. Hosting Uptime Performance Benchmarking
3. Customer Lifetime Value by Product Mix
4. Support Ticket Resolution Efficiency
5. Revenue Trend Analysis with Seasonality
6. Marketing Campaign ROI and Attribution
7. Cross-Sell Opportunity Identification
8. Domain Extension Performance Analysis
9. Support Agent Performance Benchmarking
10. Customer Churn Risk Prediction

### 4.3 Cortex Search Test Questions

Test unstructured data search:

1. **"Search support transcripts for email configuration issues"**
2. **"Find domain transfer notes about unauthorized transfers"**
3. **"What does our knowledge base say about SSL setup?"**

---

## Step 5: Query Cortex Search Services Directly

You can also query Cortex Search services directly using SQL:

### Query Support Transcripts
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'GODADDY_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH',
      '{
        "query": "email configuration problems",
        "columns":["transcript_text", "interaction_type"],
        "limit":10
      }'
  )
)['results'] as results;
```

### Query Domain Transfer Notes
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'GODADDY_INTELLIGENCE.RAW.DOMAIN_TRANSFER_NOTES_SEARCH',
      '{
        "query": "transfer failed auth code",
        "columns":["note_text", "transfer_status"],
        "limit":10
      }'
  )
)['results'] as results;
```

### Query Knowledge Base
```sql
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
      'GODADDY_INTELLIGENCE.RAW.KNOWLEDGE_BASE_SEARCH',
      '{
        "query": "how to setup dns records",
        "columns":["title", "content"],
        "limit":5
      }'
  )
)['results'] as results;
```

---

## Step 6: Access Control

### Create Role for Agent Users
```sql
CREATE ROLE IF NOT EXISTS GODADDY_AGENT_USER;

-- Grant necessary privileges
GRANT USAGE ON DATABASE GODADDY_INTELLIGENCE TO ROLE GODADDY_AGENT_USER;
GRANT USAGE ON SCHEMA GODADDY_INTELLIGENCE.ANALYTICS TO ROLE GODADDY_AGENT_USER;
GRANT USAGE ON SCHEMA GODADDY_INTELLIGENCE.RAW TO ROLE GODADDY_AGENT_USER;
GRANT SELECT ON ALL VIEWS IN SCHEMA GODADDY_INTELLIGENCE.ANALYTICS TO ROLE GODADDY_AGENT_USER;
GRANT USAGE ON WAREHOUSE GODADDY_WH TO ROLE GODADDY_AGENT_USER;

-- Grant Cortex Search usage
GRANT USAGE ON CORTEX SEARCH SERVICE GODADDY_INTELLIGENCE.RAW.SUPPORT_TRANSCRIPTS_SEARCH TO ROLE GODADDY_AGENT_USER;
GRANT USAGE ON CORTEX SEARCH SERVICE GODADDY_INTELLIGENCE.RAW.DOMAIN_TRANSFER_NOTES_SEARCH TO ROLE GODADDY_AGENT_USER;
GRANT USAGE ON CORTEX SEARCH SERVICE GODADDY_INTELLIGENCE.RAW.KNOWLEDGE_BASE_SEARCH TO ROLE GODADDY_AGENT_USER;

-- Grant to specific user
GRANT ROLE GODADDY_AGENT_USER TO USER your_username;
```

---

## Troubleshooting

### Issue: Semantic views not found

**Solution:**
```sql
-- Verify semantic views exist
SHOW SEMANTIC VIEWS IN SCHEMA GODADDY_INTELLIGENCE.ANALYTICS;

-- Check permissions
SHOW GRANTS ON SEMANTIC VIEW SV_DOMAIN_HOSTING_INTELLIGENCE;
```

### Issue: Cortex Search returns no results

**Solution:**
```sql
-- Verify service exists and is populated
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- Check data in source table
SELECT COUNT(*) FROM RAW.SUPPORT_TRANSCRIPTS;

-- Verify change tracking is enabled
SHOW TABLES LIKE 'SUPPORT_TRANSCRIPTS';
```

### Issue: Slow query performance

**Solution:**
- Increase warehouse size (MEDIUM or LARGE)
- Check for missing filters on date columns
- Review query execution plan
- Consider materializing frequently-used aggregations

---

## Success Metrics

Your agent is successfully configured when:

✅ All 6 SQL scripts execute without errors  
✅ All semantic views are created and validated  
✅ All 3 Cortex Search services are created and indexed  
✅ Agent can answer simple test questions  
✅ Agent can answer complex analytical questions  
✅ Cortex Search returns relevant results  
✅ Query performance is acceptable (< 30 seconds for complex queries)  
✅ Results are accurate and match expected business logic  

---

## Support Resources

- **Snowflake Documentation**: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
- **GoDaddy Website**: https://www.godaddy.com
- **Snowflake Community**: https://community.snowflake.com

---

**Version:** 1.0  
**Created:** October 2025  
**Based on:** Early-Warning Intelligence Template

