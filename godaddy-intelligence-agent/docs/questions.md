<img src="../../Snowflake_Logo.svg" width="200">

# GoDaddy Intelligence Agent - Complex Questions

These 10 complex questions demonstrate the intelligence agent's ability to analyze GoDaddy's customer data, domain portfolio, hosting services, revenue metrics, and support operations across multiple dimensions.

---

## 1. Domain Renewal Risk Analysis

**Question:** "Analyze domains expiring in the next 30 days. Show me the total count, total renewal revenue at risk, breakdown by domain extension, and percentage with auto-renew disabled. Which customer segments have the highest risk of non-renewal?"

**Why Complex:**
- Time-based filtering (next 30 days)
- Revenue at risk calculation
- Multi-dimensional breakdown (extension + segment)
- Percentage calculations
- Risk assessment across segments

**Data Sources:** DOMAINS, CUSTOMERS

---

## 2. Hosting Uptime Performance Benchmarking

**Question:** "Compare hosting plan uptime percentages across different plan types (SHARED, VPS, DEDICATED, CLOUD). Show average uptime, count of plans, and identify which customers experienced below 99.5% uptime in the last 90 days. What is the correlation between plan type and uptime?"

**Why Complex:**
- Performance benchmarking across plan types
- Statistical analysis (averages, thresholds)
- Time-based filtering (90 days)
- Threshold-based identification (<99.5%)
- Correlation analysis

**Data Sources:** HOSTING_PLANS, CUSTOMERS

---

## 3. Customer Lifetime Value by Product Mix

**Question:** "Segment customers by the products they use (domains only, domains+hosting, domains+hosting+email, full stack). For each segment, calculate average lifetime value, total revenue, customer count, and average support tickets. Which product mix generates the highest LTV with lowest support burden?"

**Why Complex:**
- Custom segmentation by product combinations
- Multiple metric calculations per segment
- Cross-product analysis
- Efficiency metrics (LTV vs support burden)
- Optimal segment identification

**Data Sources:** CUSTOMERS, DOMAINS, HOSTING_PLANS, EMAIL_SERVICES, WEBSITE_BUILDER_SUBSCRIPTIONS, SSL_CERTIFICATES, TRANSACTIONS, SUPPORT_TICKETS

---

## 4. Support Ticket Resolution Efficiency

**Question:** "Analyze support ticket resolution times by issue type, priority, and channel. Show average resolution time for each combination, identify which issue types take longest to resolve, and determine which support channels provide fastest resolution. Are urgent priority tickets actually being resolved faster?"

**Why Complex:**
- Multi-dimensional analysis (issue type × priority × channel)
- Time-based metrics
- Comparative analysis across dimensions
- Priority verification analysis
- Efficiency benchmarking

**Data Sources:** SUPPORT_TICKETS, SUPPORT_AGENTS

---

## 5. Revenue Trend Analysis with Seasonality

**Question:** "Analyze monthly revenue trends over the past 12 months broken down by product type. Identify seasonal patterns, calculate month-over-month growth rates, and highlight which products show strongest growth. Are domain registrations higher in certain months?"

**Why Complex:**
- Time-series analysis (12 months)
- Product-level breakdown
- Seasonal pattern detection
- Growth rate calculations (MoM)
- Comparative trend analysis

**Data Sources:** TRANSACTIONS, PRODUCTS

---

## 6. Marketing Campaign ROI and Attribution

**Question:** "For each marketing campaign, calculate total spend, customer interactions, conversion rate, revenue generated, and ROI. Which campaigns had conversion rates above 10%? Show ROI ranking and identify which customer segments responded best to which campaign types."

**Why Complex:**
- Financial calculations (ROI, conversion rates)
- Multi-metric campaign analysis
- Threshold filtering (>10% conversion)
- Ranking and comparison
- Customer segment attribution

**Data Sources:** MARKETING_CAMPAIGNS, CUSTOMER_CAMPAIGN_INTERACTIONS, CUSTOMERS

---

## 7. Cross-Sell Opportunity Identification

**Question:** "Identify customers who have domains but no hosting, customers with hosting but no SSL certificates, and customers with websites but no professional email. For each group, calculate total count, average customer lifetime value, and potential revenue opportunity. Prioritize cross-sell targets by LTV and segment."

**Why Complex:**
- Gap analysis across product portfolio
- Multiple cross-sell opportunity identification
- Revenue opportunity calculation
- Customer prioritization
- Segmentation and targeting

**Data Sources:** CUSTOMERS, DOMAINS, HOSTING_PLANS, SSL_CERTIFICATES, EMAIL_SERVICES, WEBSITE_BUILDER_SUBSCRIPTIONS

---

## 8. Domain Extension Performance Analysis

**Question:** "Compare performance across different domain extensions (.com, .net, .org, .io, .co). Show total registrations, average registration price, average renewal price, renewal rate, and revenue per extension. Which extensions have highest renewal rates and why?"

**Why Complex:**
- Extension-level aggregation
- Multiple performance metrics
- Pricing analysis
- Renewal rate calculation
- Comparative performance analysis

**Data Sources:** DOMAINS, TRANSACTIONS

---

## 9. Support Agent Performance Benchmarking

**Question:** "Analyze support agent performance across departments. Show average resolution time, ticket volume, customer satisfaction ratings, and resolution rate per agent. Identify top performers and agents needing additional training. How does performance vary by specialization?"

**Why Complex:**
- Agent-level performance metrics
- Department-level aggregation
- Quality metrics (satisfaction, resolution rate)
- Performance ranking
- Specialization analysis

**Data Sources:** SUPPORT_AGENTS, SUPPORT_TICKETS

---

## 10. Customer Churn Risk Prediction

**Question:** "Identify customers at risk of churn based on: domains expiring soon without auto-renew, hosting plans expired or expiring, no transactions in last 6 months, multiple unresolved support tickets, or low satisfaction ratings. Calculate a churn risk score for each at-risk customer and prioritize retention outreach by customer lifetime value."

**Why Complex:**
- Multi-factor risk assessment
- Temporal analysis (expiration dates, transaction recency)
- Risk scoring calculation
- Customer prioritization
- Actionable segmentation

**Data Sources:** CUSTOMERS, DOMAINS, HOSTING_PLANS, TRANSACTIONS, SUPPORT_TICKETS

---

## Cortex Search Questions (Unstructured Data)

These questions test the agent's ability to search and retrieve insights from unstructured data using Cortex Search services.

### 11. Domain Transfer Issue Patterns

**Question:** "Search domain transfer notes for cases where transfers failed or were delayed. What were the most common reasons? What resolution procedures were successful?"

**Why Complex:**
- Semantic search over transfer documentation
- Pattern extraction from unstructured text
- Success factor identification
- Resolution procedure analysis

**Data Source:** DOMAIN_TRANSFER_NOTES_SEARCH

---

### 12. Customer Support Best Practices

**Question:** "Find support transcript examples where customers were highly satisfied (sentiment score > 80). What techniques did agents use? How were complex issues resolved?"

**Why Complex:**
- Sentiment-based filtering
- Best practice extraction
- Technique identification
- Resolution strategy analysis

**Data Source:** SUPPORT_TRANSCRIPTS_SEARCH

---

### 13. Technical Documentation Retrieval

**Question:** "How do I configure DNS records for email? What are the specific MX record settings for GoDaddy email services?"

**Why Complex:**
- Technical procedure retrieval
- Specific configuration extraction
- Step-by-step instruction synthesis

**Data Source:** KNOWLEDGE_BASE_SEARCH

---

### 14. Email Configuration Issues

**Question:** "Search support transcripts for email configuration problems. What were the most common issues and how were they resolved?"

**Why Complex:**
- Issue pattern identification
- Resolution strategy extraction
- Common problem analysis

**Data Source:** SUPPORT_TRANSCRIPTS_SEARCH

---

### 15. SSL Certificate Troubleshooting

**Question:** "What does our knowledge base say about SSL certificate installation errors? What are the common troubleshooting steps?"

**Why Complex:**
- Technical troubleshooting retrieval
- Step extraction from documentation
- Error pattern identification

**Data Source:** KNOWLEDGE_BASE_SEARCH

---

### 16. Transfer Security Issues

**Question:** "Find domain transfer notes involving security concerns or unauthorized transfer attempts. What security measures were implemented?"

**Why Complex:**
- Security incident identification
- Protective measure extraction
- Incident response analysis

**Data Source:** DOMAIN_TRANSFER_NOTES_SEARCH

---

### 17. Billing Dispute Resolution

**Question:** "Search support transcripts for billing disputes. How were refunds handled? What was the typical resolution process?"

**Why Complex:**
- Dispute pattern analysis
- Process extraction
- Resolution procedure identification

**Data Source:** SUPPORT_TRANSCRIPTS_SEARCH

---

### 18. Website Builder Guidance

**Question:** "What guidance does our knowledge base provide for customers new to Website Builder? What are the getting started steps?"

**Why Complex:**
- Onboarding information retrieval
- Step-by-step extraction
- Beginner guidance synthesis

**Data Source:** KNOWLEDGE_BASE_SEARCH

---

### 19. Bulk Transfer Procedures

**Question:** "Find notes about bulk domain transfers (multiple domains). What special procedures were followed? What challenges arose?"

**Why Complex:**
- Bulk operation identification
- Procedure extraction
- Challenge analysis

**Data Source:** DOMAIN_TRANSFER_NOTES_SEARCH

---

### 20. Cross-Platform Knowledge Synthesis

**Question:** "For setting up a complete online presence (domain + hosting + email + SSL), combine information from: 1) Knowledge base setup guides, 2) Support transcripts showing successful setups, and 3) Any domain transfer notes if domain is coming from another registrar."

**Why Complex:**
- Multi-source information synthesis
- Step-by-step procedure combination
- Comprehensive solution assembly
- Context integration

**Data Sources:** KNOWLEDGE_BASE_SEARCH, SUPPORT_TRANSCRIPTS_SEARCH, DOMAIN_TRANSFER_NOTES_SEARCH

---

## Question Complexity Summary

These questions test the agent's ability to:

1. **Multi-table joins** - connecting customers, domains, hosting, transactions, support
2. **Temporal analysis** - time-based patterns, expiration tracking, trend analysis
3. **Segmentation & classification** - customer segments, product mixes, risk tiers
4. **Derived metrics** - rates, percentages, ratios, growth calculations
5. **Correlation analysis** - relationships between variables
6. **Pattern recognition** - support patterns, transfer issues, seasonal trends
7. **Comparative analysis** - benchmarking, performance comparison, rankings
8. **Financial calculations** - ROI, revenue, LTV, opportunity sizing
9. **Aggregation at multiple levels** - customer, product, time period, segment
10. **Risk assessment** - churn prediction, renewal risk, security concerns
11. **Semantic search** - understanding intent in unstructured data
12. **Information synthesis** - combining insights from multiple sources

These questions reflect realistic business intelligence needs for GoDaddy's domain registration, hosting, and customer support operations.

---

**Version:** 1.0  
**Created:** October 2025  
**Based on:** Early-Warning Intelligence Template

