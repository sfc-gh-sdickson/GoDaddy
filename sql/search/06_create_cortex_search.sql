-- ============================================================================
-- GoDaddy Intelligence Agent - Cortex Search Service Setup
-- ============================================================================
-- Purpose: Create unstructured data tables and Cortex Search services for
--          support transcripts, domain notes, and knowledge base articles
-- Syntax verified against: https://docs.snowflake.com/en/sql-reference/sql/create-cortex-search
-- ============================================================================

USE DATABASE GODADDY_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE GODADDY_WH;

-- ============================================================================
-- Step 1: Create table for support transcripts (unstructured text data)
-- ============================================================================
CREATE OR REPLACE TABLE SUPPORT_TRANSCRIPTS (
    transcript_id VARCHAR(30) PRIMARY KEY,
    ticket_id VARCHAR(30),
    customer_id VARCHAR(20),
    agent_id VARCHAR(20),
    transcript_text VARCHAR(16777216) NOT NULL,
    interaction_type VARCHAR(50),
    interaction_date TIMESTAMP_NTZ NOT NULL,
    sentiment_score NUMBER(5,2),
    keywords VARCHAR(500),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (ticket_id) REFERENCES SUPPORT_TICKETS(ticket_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (agent_id) REFERENCES SUPPORT_AGENTS(agent_id)
);

-- ============================================================================
-- Step 2: Create table for domain transfer notes
-- ============================================================================
CREATE OR REPLACE TABLE DOMAIN_TRANSFER_NOTES (
    note_id VARCHAR(30) PRIMARY KEY,
    domain_id VARCHAR(30),
    customer_id VARCHAR(20),
    note_text VARCHAR(16777216) NOT NULL,
    note_type VARCHAR(50),
    transfer_status VARCHAR(30),
    issue_resolved BOOLEAN,
    created_date TIMESTAMP_NTZ NOT NULL,
    created_by VARCHAR(100),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (domain_id) REFERENCES DOMAINS(domain_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- ============================================================================
-- Step 3: Create table for knowledge base articles
-- ============================================================================
CREATE OR REPLACE TABLE KNOWLEDGE_BASE_ARTICLES (
    article_id VARCHAR(30) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content VARCHAR(16777216) NOT NULL,
    article_category VARCHAR(50),
    product_category VARCHAR(50),
    tags VARCHAR(500),
    author VARCHAR(100),
    last_updated TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    view_count NUMBER(10,0) DEFAULT 0,
    helpfulness_score NUMBER(3,2),
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Step 4: Enable change tracking (required for Cortex Search)
-- ============================================================================
ALTER TABLE SUPPORT_TRANSCRIPTS SET CHANGE_TRACKING = TRUE;
ALTER TABLE DOMAIN_TRANSFER_NOTES SET CHANGE_TRACKING = TRUE;
ALTER TABLE KNOWLEDGE_BASE_ARTICLES SET CHANGE_TRACKING = TRUE;

-- ============================================================================
-- Step 5: Generate sample support transcripts
-- ============================================================================
INSERT INTO SUPPORT_TRANSCRIPTS
SELECT
    'TRANS' || LPAD(SEQ4(), 10, '0') AS transcript_id,
    st.ticket_id,
    st.customer_id,
    st.assigned_agent_id AS agent_id,
    CASE (ABS(RANDOM()) % 20)
        WHEN 0 THEN 'Agent: Thank you for contacting GoDaddy support. How can I help you today? Customer: Hi, I am trying to transfer my domain from another registrar but it is not going through. Agent: I can definitely help with that. Can you provide me the domain name? Customer: Yes, it is mycompanysite.com. Agent: Let me check that for you. I see the issue - the domain is currently locked at your current registrar. You will need to unlock it first and get the authorization code. Customer: How do I do that? Agent: You will need to log into your current registrar account and look for domain settings. There should be an option to unlock the domain and generate an auth code. Once you have that, come back to GoDaddy and initiate the transfer again. Customer: Okay, I will try that. Thank you!'
        WHEN 1 THEN 'Customer: My website has been down for 2 hours! This is unacceptable! Agent: I am very sorry to hear that. Let me check your hosting account immediately. What is your domain name? Customer: businessonline.com. Agent: Thank you. I am pulling up your account now. I can see your hosting is active but there appears to be a DNS configuration issue. When did you last make changes to your DNS settings? Customer: I tried to add a new subdomain this morning. Agent: That is likely the issue. Let me review your DNS records. Yes, I see the problem - there is a syntax error in one of your A records. I can fix this for you right now. Customer: Please do! Agent: Done. Your DNS should propagate within 15-30 minutes. I am also giving you a credit for the downtime. Customer: Thank you so much!'
        WHEN 2 THEN 'Chat started. Agent: Hello! Welcome to GoDaddy support. Customer: Hi, I need to set up email for my domain. I just purchased it yesterday. Agent: Congratulations on your new domain! I can help you set up email. Which email plan did you purchase? Customer: I got the Professional Email plan. Agent: Perfect. Let me send you the setup instructions. You will need to verify your domain first. Check your email for a verification link. Customer: I already did that. Agent: Great! Then you can now create your email addresses. Go to your account dashboard, click on Email & Office, then create your first mailbox. Customer: Can I have info@mydomain.com? Agent: Absolutely! You can create that and any other addresses you need up to your plan limit. Customer: Got it, thank you!'
        WHEN 3 THEN 'Agent: GoDaddy Technical Support, this is Mike. How can I assist? Customer: My SSL certificate expired and now visitors are getting security warnings. Agent: I understand the urgency. Let me help you renew that right away. What is your domain? Customer: securesite.org. Agent: Thank you. I see your SSL expired 3 days ago. I can renew this for you now. Do you have the same SSL type as before? Customer: Yes, the same one please. Agent: Processing your renewal now... Okay, your SSL certificate has been renewed and is installing. This should take about 15 minutes. Customer: Will my site be down during this? Agent: No, there will be no downtime. Once installed, the security warning will disappear. Customer: Perfect, thank you!'
        WHEN 4 THEN 'Email Support Thread. Customer: I was charged twice for my domain renewal. Can you refund one charge? Agent: I apologize for the duplicate charge. Let me review your account. I can see two charges on [date] for the same domain renewal. Customer: Yes, that is correct. Agent: I am processing a refund for the duplicate charge right now. You should see it back in your account within 5-7 business days. Customer: Thank you. Will this affect my domain renewal? Agent: Not at all. Your domain is properly renewed through [date]. The refund is only for the duplicate charge. Customer: Great, I appreciate your help.'
        WHEN 5 THEN 'Agent: Thank you for calling GoDaddy. Customer: Hi, I want to upgrade my hosting plan. I am getting too much traffic for my current plan. Agent: That is wonderful that your site is growing! What plan are you currently on? Customer: Economy hosting. Agent: And what would you like to upgrade to? Customer: What do you recommend for an e-commerce site with about 10,000 monthly visitors? Agent: I would recommend our Deluxe or Ultimate plan. Ultimate gives you 2x processing power which is great for e-commerce. Customer: Let us go with Ultimate. Agent: Excellent choice. I am processing that upgrade now. You will see the change reflect immediately and billing will be prorated. Customer: Thank you!'
        WHEN 6 THEN 'Customer: I need help with my Website Builder. I cannot figure out how to add a contact form. Agent: I can walk you through that. Are you in the Website Builder editor now? Customer: Yes, I am on the page where I want to add it. Agent: Great! Look for the plus icon on the left side. Click that to add elements. Customer: Okay, I see it. Agent: Now scroll down and find Contact Form in the list. Drag it onto your page where you want it. Customer: Oh wow, that was easy! Agent: You can customize the fields by clicking on the form. Add or remove fields as needed. Customer: This is perfect. Can I get emails when someone submits? Agent: Yes! Click on Form Settings and add your email address. You will get notifications for each submission. Customer: Thank you so much!'
        WHEN 7 THEN 'Agent: GoDaddy Domain Support. Customer: Someone is trying to steal my domain! I got an email saying my domain was transferred but I did not authorize it! Agent: That is very concerning. Let me check this immediately. What is your domain name? Customer: mycompanybrand.com. Agent: Thank you. Let me pull up your account... I can see your domain is still in your account and there are no transfer requests pending. Customer: But the email said it was transferred to another company! Agent: That email was a phishing scam. GoDaddy will never email you about transfers without your authorization. Your domain is safe and locked. Customer: Oh thank goodness! Should I do anything? Agent: Yes, I recommend enabling two-factor authentication on your account for added security. I can help you set that up now. Customer: Yes please!'
        WHEN 8 THEN 'Chat. Customer: My website builder is not saving my changes! Agent: I am sorry to hear that. Let me troubleshoot this with you. What browser are you using? Customer: Chrome. Agent: Are you seeing any error messages? Customer: No, it just keeps showing "saving" but never completes. Agent: Try refreshing your browser and clearing your cache. Sometimes that resolves the issue. Customer: Okay, trying now... It is still not working. Agent: Let me check if there is a known issue. One moment please... I see there was a brief service interruption 30 minutes ago but it is resolved now. Try logging out completely and logging back in. Customer: That worked! All my changes are saving now. Agent: Wonderful! Let me know if you need anything else. Customer: All good, thank you!'
        WHEN 9 THEN 'Agent: Thank you for contacting GoDaddy billing support. Customer: I want to cancel my hosting plan. I am moving to another provider. Agent: I am sorry to hear you are leaving. May I ask why you are moving? Customer: I found a cheaper option elsewhere. Agent: I understand. Before you cancel, let me see if I can offer you a retention discount. How much time is left on your current plan? Customer: 3 months. Agent: I can offer you 30% off your renewal if you stay with us. That would make it comparable to other providers. Customer: How long is that discount for? Agent: For the next year. After that, standard pricing. Customer: That is actually a really good deal. Okay, I will stay. Agent: Excellent! I am applying that discount to your account now. You will see it on your next renewal. Customer: Thanks for working with me on this.'
        WHEN 10 THEN 'Customer inquiry via email: I purchased a domain yesterday but now I want to buy privacy protection. How do I add that? Agent response: Thank you for contacting us! You can add domain privacy protection at any time. Simply log into your GoDaddy account, go to My Products, find your domain, and click on Add Privacy Protection. The cost is $9.99/year and it will hide your personal information from WHOIS lookups. Customer reply: I found it and added it. How long before it takes effect? Agent: Privacy protection activates immediately. Your personal information should be hidden from WHOIS within 24 hours. Customer: Perfect, thank you!'
        WHEN 11 THEN 'Phone support. Agent: GoDaddy email support, how may I help you? Customer: I am not receiving emails to my GoDaddy email address. Agent: Let me help you troubleshoot that. When did this start? Customer: This morning. I was getting emails fine yesterday. Agent: Are you checking via webmail or an email client like Outlook? Customer: Outlook. Agent: Let me check your email settings. Can you verify your incoming mail server settings? It should be pop.godaddy.com or imap.godaddy.com. Customer: Oh, I see the problem. It says something different. Agent: That is likely the issue. Let me send you the correct settings. You will need to update your server settings in Outlook. Customer: I will do that now. Agent: Great! Try sending a test email once you update it. Customer: It is working now! Thank you!'
        WHEN 12 THEN 'Agent: Welcome to GoDaddy chat support! Customer: I want to build a website but I have never done it before. What should I start with? Agent: Great question! GoDaddy makes it very easy. Do you already have a domain name? Customer: No, not yet. Agent: Perfect, let us start there. Think of a domain name for your website. What is your website about? Customer: I am a photographer and want to showcase my work. Agent: Nice! So you will want a domain like yourname.com or yournamephotography.com. Once you have your domain, I recommend our Website Builder with a portfolio template. Customer: That sounds good. How much does this cost? Agent: Domains start at $11.99/year and Website Builder is $9.99/month. We have bundle deals too. Customer: Can you help me set it all up? Agent: Absolutely! Let us start with registering your domain. What name would you like?'
        WHEN 13 THEN 'Customer: My domain is about to expire. How do I renew it? Agent: I can help you renew your domain right away. What is the domain name? Customer: myblogsite.com. Agent: Let me pull that up. I see it expires in 5 days. Would you like me to process the renewal now? Customer: Yes please. How much is it? Agent: Your renewal is $17.99 for one year. Would you like to enable auto-renewal so it automatically renews next year? Customer: How much is auto-renewal? Agent: It is the same price, but it will automatically charge your payment method on file before expiration so you never lose your domain. Customer: Oh, that is smart. Yes, turn that on. Agent: Done! Your domain is renewed through next year and auto-renew is enabled. You are all set!'
        WHEN 14 THEN 'Email support. Customer: I am trying to point my domain to an external website. How do I do that? Agent: You will need to update your domain nameservers. Are you comfortable making DNS changes or would you like step-by-step instructions? Customer: I need instructions. Agent: No problem! Log into your GoDaddy account. Go to My Products > Domains. Find your domain and click DNS. You will see Nameservers at the top. Click Change and select Custom. Enter your external hosting provider nameservers here. Do you have those nameservers from your hosting provider? Customer: Yes, I have them. Agent: Perfect! Enter those, save changes, and your domain will point to your external site within 24-48 hours. Customer: Great, thank you!'
        WHEN 15 THEN 'Agent: GoDaddy VPS hosting support. Customer: My VPS server is running slow. Can you check what is going on? Agent: I can definitely help with that. Let me check your server resources. What is your VPS account ID? Customer: VPS12345. Agent: Thank you. Checking now... I can see your CPU usage is at 95% consistently. Do you know what might be causing high CPU usage? Customer: We had a traffic spike yesterday from a viral post. Agent: That would explain it. Your current plan may be undersized for your traffic. Have you considered upgrading to a larger VPS plan? Customer: How much would that cost? Agent: Your current plan is $29.99/month. The next tier is $49.99/month with double the resources. Customer: Let us upgrade. Agent: Processing that now. Your VPS will be upgraded within the hour and you should see performance improve immediately.'
        WHEN 16 THEN 'Customer: How do I add a subdomain? Agent: I can walk you through that. Log into your GoDaddy account and go to My Products > Domains. Click on your domain, then Manage DNS. Customer: Okay, I am there. Agent: Scroll down to Records. Click Add to create a new record. Customer: What type of record? Agent: Select A record. For Name, enter your subdomain (like "blog" for blog.yourdomain.com). For Value, enter your IP address. Customer: I do not know my IP address. Agent: You can find that in your hosting control panel. Or if you are pointing to your GoDaddy hosting, I can look it up for you. Customer: Yes, it is GoDaddy hosting. Agent: Let me get that IP for you... Okay, use this IP: 192.0.2.1. Enter that in the Value field and save. Customer: Done! How long until it works? Agent: Subdomains usually propagate within 1 hour. Customer: Perfect, thank you!'
        WHEN 17 THEN 'Chat support. Customer: I forgot my account password. Agent: I can help you reset that. Do you have access to the email address on file? Customer: Yes. Agent: Great! I just sent a password reset link to that email. Check your inbox and spam folder. Customer: Got it! I reset my password. Agent: Perfect! You should be able to log in now. For security, I recommend enabling two-factor authentication. Customer: How do I do that? Agent: In your account settings, look for Security Settings. You can enable it there and it will require a code from your phone when you log in. Customer: Okay, I will do that. Thanks!'
        WHEN 18 THEN 'Agent: GoDaddy dedicated server support. Customer: I need to upgrade my server RAM. What is the process? Agent: I can help with that. Dedicated server upgrades require a scheduled maintenance window. How much RAM do you currently have and how much do you need? Customer: I have 16GB and need 32GB. Agent: That upgrade is available. It will require about 30 minutes of downtime. When would be the best time for you? Customer: Can we do it tonight at 2 AM? Agent: Yes, I can schedule that. I will need your approval and payment first. The upgrade cost is $50/month additional. Customer: That is fine. Let us do it. Agent: Processing your order now. You will receive a confirmation email with the maintenance window details. Your server will be upgraded tonight at 2 AM.'
        WHEN 19 THEN 'Customer: My email is being marked as spam by recipients. Agent: That is frustrating. Let me help you troubleshoot. Are you sending from a GoDaddy email address? Customer: Yes, from my domain email. Agent: There are a few reasons this might happen. First, do you have an SSL certificate on your domain? Customer: Yes. Agent: Good. Next, we need to check your SPF and DKIM records. These authenticate your emails. Let me check your DNS... I see you are missing a DKIM record. I can add that for you. Customer: Please do! Agent: Done. Also, make sure you are not sending mass emails without proper permission. That is a common cause of spam flagging. Customer: I only email people who signed up for my newsletter. Agent: That is good. With the DKIM record added, your email deliverability should improve significantly. Give it 24 hours to take effect.'
    END AS transcript_text,
    ARRAY_CONSTRUCT('PHONE', 'EMAIL', 'CHAT')[UNIFORM(0, 2, RANDOM())] AS interaction_type,
    st.created_date AS interaction_date,
    (UNIFORM(-50, 100, RANDOM()) / 1.0)::NUMBER(5,2) AS sentiment_score,
    CASE (ABS(RANDOM()) % 5)
        WHEN 0 THEN 'domain,transfer,help'
        WHEN 1 THEN 'hosting,downtime,urgent'
        WHEN 2 THEN 'email,setup,configuration'
        WHEN 3 THEN 'ssl,certificate,security'
        WHEN 4 THEN 'billing,refund,charge'
    END AS keywords,
    st.created_date AS created_at
FROM RAW.SUPPORT_TICKETS st
WHERE st.ticket_id IS NOT NULL
LIMIT 50000;

-- ============================================================================
-- Step 6: Generate sample domain transfer notes
-- ============================================================================
INSERT INTO DOMAIN_TRANSFER_NOTES
SELECT
    'NOTE' || LPAD(SEQ4(), 10, '0') AS note_id,
    d.domain_id,
    d.customer_id,
    CASE (ABS(RANDOM()) % 15)
        WHEN 0 THEN 'Domain transfer initiated from Network Solutions. Auth code provided by customer. Domain currently locked at losing registrar. Instructed customer to unlock domain and disable privacy protection before retrying transfer. Estimated completion: 5-7 days after unlock.'
        WHEN 1 THEN 'Transfer request from Namecheap. Customer owns domain for 3 years. All verification checks passed. Domain unlocked. Auth code verified. Transfer initiated successfully. Sent confirmation email to customer. Expected completion by ' || DATEADD('day', 5, CURRENT_DATE())::VARCHAR || '.'
        WHEN 2 THEN 'Customer attempting to transfer expired domain. Explained that domain must be renewed at current registrar before transfer is possible. Customer opted to renew at current registrar first. Will re-initiate transfer once renewal complete. Follow-up scheduled for next week.'
        WHEN 3 THEN 'Transfer rejected by losing registrar. Reason: Admin contact email does not match. Customer needs to update contact email at current registrar to match GoDaddy account email. Provided step-by-step instructions. Await customer confirmation before retry.'
        WHEN 4 THEN 'Successful transfer completed. Domain now active in customer GoDaddy account. Nameservers remain pointed to previous hosting. Confirmed with customer they want to keep current nameservers. No hosting migration needed. Sent welcome packet and account setup guide.'
        WHEN 5 THEN 'Transfer in progress. Day 3 of 5-7 day transfer window. Losing registrar approved transfer. ICANN verification email sent to customer. Customer must click approval link within 5 days or transfer will auto-complete. Following up tomorrow if not confirmed.'
        WHEN 6 THEN 'Customer reports transfer stuck at pending. Investigated and found registrar lock still enabled. Contacted losing registrar support on customer behalf. Lock removed. Transfer now proceeding. Updated customer via email. New estimated completion: ' || DATEADD('day', 3, CURRENT_DATE())::VARCHAR || '.'
        WHEN 7 THEN 'Premium domain transfer. Additional verification required due to domain value. Verified customer identity through phone call and photo ID. Transfer approved. Processing with 2-factor authentication. Priority handling due to domain value. Monitoring closely.'
        WHEN 8 THEN 'Bulk transfer request: 25 domains from GoDaddy competitor. Created spreadsheet of all domain auth codes. Verified all domains are unlocked. Initiated batch transfer. 23 successful, 2 failed (expired). Contacted customer about 2 expired domains. Renewal required before transfer.'
        WHEN 9 THEN 'Transfer dispute escalation. Customer claims they did not authorize transfer out of GoDaddy. Initiated security review. Verified login IP addresses show suspicious access from foreign country. Transfer CANCELLED. Account secured, password reset required. Fraud investigation opened.'
        WHEN 10 THEN 'Domain transfer-in delayed. Losing registrar not responding to transfer request. Customer frustrated. Escalated to registrar relations team. Filed formal complaint with ICANN. Provided customer with timeline and updates. Expedited processing once registrar responds.'
        WHEN 11 THEN 'Customer wants to transfer domain but hosting is also at current registrar. Explained separation of domain and hosting. Provided hosting migration guide. Customer decided to transfer domain now and migrate hosting next month. Transfer initiated, hosting remains with current provider temporarily.'
        WHEN 12 THEN 'International domain transfer (.co.uk). Additional verification required for UK registry. Customer provided UK business registration documents. Documents verified. Transfer meets Nominet requirements. Processing with 5-day IPS tag change period. Customer notified of extended timeline.'
        WHEN 13 THEN 'Transfer completed but customer lost email due to nameserver change. Explained that email hosting was at previous registrar. Helped customer set up GoDaddy email service. Migrated existing emails. Configured MX records. Email service restored within 2 hours. Customer satisfied.'
        WHEN 14 THEN 'Customer received unexpected transfer confirmation email. Investigation revealed customer account compromised. Password changed from unfamiliar IP. Transfer was unauthorized hijack attempt. Transfer BLOCKED. Security measures implemented: 2FA enabled, account locked, security questions updated. Law enforcement notified.'
    END AS note_text,
    ARRAY_CONSTRUCT('TRANSFER_REQUEST', 'TRANSFER_IN_PROGRESS', 'TRANSFER_COMPLETE', 'TRANSFER_ISSUE', 'SECURITY_REVIEW')[UNIFORM(0, 4, RANDOM())] AS note_type,
    ARRAY_CONSTRUCT('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED', 'CANCELLED')[UNIFORM(0, 4, RANDOM())] AS transfer_status,
    UNIFORM(0, 100, RANDOM()) < 75 AS issue_resolved,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_date,
    'Transfer Specialist ' || UNIFORM(1, 20, RANDOM())::VARCHAR AS created_by,
    DATEADD('day', -1 * UNIFORM(0, 365, RANDOM()), CURRENT_TIMESTAMP()) AS created_at
FROM RAW.DOMAINS d
WHERE UNIFORM(0, 100, RANDOM()) < 20
LIMIT 25000;

-- ============================================================================
-- Step 7: Generate sample knowledge base articles
-- ============================================================================
INSERT INTO KNOWLEDGE_BASE_ARTICLES VALUES
('KB001', 'How to Transfer Your Domain to GoDaddy', 
$$Transferring your domain to GoDaddy is a straightforward process. Here are the steps:

1. PREPARE YOUR DOMAIN FOR TRANSFER
- Unlock your domain at your current registrar
- Obtain the authorization (EPP) code from your current registrar
- Disable domain privacy protection temporarily
- Ensure your admin email is current and accessible
- Verify the domain is not within 60 days of registration or previous transfer

2. INITIATE THE TRANSFER AT GODADDY
- Go to godaddy.com/domains/domain-transfer
- Enter your domain name
- Enter your authorization code
- Complete the checkout process
- The transfer process typically takes 5-7 days

3. APPROVE THE TRANSFER
- Check your email for transfer approval link
- Click the link to approve (or transfer auto-approves after 5 days)
- Monitor transfer status in your GoDaddy account

4. AFTER TRANSFER COMPLETION
- Verify nameservers point to correct hosting
- Re-enable domain privacy if desired
- Set up auto-renewal to prevent expiration

COMMON ISSUES:
- Domain locked: Unlock at current registrar first
- Invalid auth code: Request new code from current registrar
- Transfer rejected: Verify domain is not recently registered or transferred
- Email disruption: Email hosting may need reconfiguration after transfer

For assistance, contact GoDaddy transfer specialists 24/7 at 480-505-8877.$$,
'HOW_TO', 'DOMAIN', 'domain,transfer,auth code,registrar', 'GoDaddy Team', CURRENT_TIMESTAMP(), 15234, 4.7, TRUE, CURRENT_TIMESTAMP()),

('KB002', 'Configuring DNS Records for Your Domain',
$$DNS (Domain Name System) records control how your domain functions. This guide explains common DNS record types and how to configure them.

COMMON DNS RECORD TYPES:

A RECORD - Points domain to IPv4 address
- Example: yourdomain.com → 192.0.2.1
- Use: Point domain to web hosting server
- TTL: 600 seconds (10 minutes) recommended

CNAME RECORD - Points subdomain to another domain
- Example: www.yourdomain.com → yourdomain.com
- Use: Create aliases, point to CDN, subdomains
- Cannot be used for root domain

MX RECORD - Directs email to mail server
- Example: yourdomain.com → mail.yourdomain.com (Priority: 10)
- Use: Configure email hosting
- Multiple MX records for redundancy

TXT RECORD - Stores text information
- Example: SPF record for email authentication
- Use: Email verification, domain ownership verification, security policies

NS RECORD - Specifies authoritative nameservers
- Example: yourdomain.com → ns1.godaddy.com
- Use: Delegate domain to nameservers
- Critical for domain functionality

HOW TO UPDATE DNS RECORDS IN GODADDY:
1. Log into your GoDaddy account
2. Go to My Products > Domains
3. Click on your domain
4. Click "Manage DNS"
5. Click "Add" to create new record
6. Select record type
7. Enter required information
8. Set TTL (Time To Live)
9. Save changes

DNS PROPAGATION:
- Changes can take 24-48 hours to propagate globally
- Lower TTL before making changes for faster propagation
- Use DNS checker tools to verify changes

TROUBLESHOOTING:
- Changes not taking effect: Check TTL and wait for propagation
- Email not working: Verify MX records point to correct mail server
- Website not loading: Verify A record points to correct IP address
- Subdomain not working: Check CNAME record configuration

For advanced DNS configuration, contact GoDaddy support.$$,
'GUIDE', 'DOMAIN', 'dns,records,nameservers,configuration', 'Technical Team', CURRENT_TIMESTAMP(), 28453, 4.5, TRUE, CURRENT_TIMESTAMP()),

('KB003', 'Setting Up Professional Email with Your Domain',
$$GoDaddy Professional Email provides business-class email with your domain name. This guide covers setup and configuration.

GETTING STARTED:
1. Purchase Professional Email plan
2. Verify domain ownership
3. Create email addresses
4. Configure email client or use webmail

CREATING EMAIL ADDRESSES:
1. Log into GoDaddy account
2. Go to Email & Office
3. Click "Create Address"
4. Enter desired email address (e.g., info@yourdomain.com)
5. Set password
6. Allocate storage (based on plan)
7. Save

EMAIL CLIENT CONFIGURATION:

IMAP SETTINGS (recommended):
- Incoming Server: imap.godaddy.com
- Port: 993
- Security: SSL/TLS
- Username: Your full email address
- Password: Your email password

- Outgoing Server (SMTP): smtp.godaddy.com
- Port: 465 (SSL) or 587 (TLS)
- Authentication: Required
- Username: Your full email address
- Password: Your email password

POP3 SETTINGS:
- Incoming Server: pop.godaddy.com
- Port: 995
- Security: SSL/TLS

WEBMAIL ACCESS:
- Go to email.godaddy.com
- Enter your full email address and password
- Access email from any browser

MOBILE SETUP:
iOS:
1. Settings > Mail > Accounts > Add Account
2. Select "Other"
3. Enter IMAP/SMTP settings above

Android:
1. Email app > Settings > Add Account
2. Select "Other"
3. Enter IMAP/SMTP settings above

BEST PRACTICES:
- Use IMAP for syncing across devices
- Enable two-factor authentication
- Set up email forwarding if needed
- Configure spam filters
- Create email aliases for different purposes
- Set up auto-responders when away

TROUBLESHOOTING:
- Cannot send email: Verify SMTP settings and authentication
- Not receiving email: Check MX records in DNS settings
- Emails going to spam: Configure SPF and DKIM records
- Storage full: Archive or delete old emails, or upgrade plan

EMAIL MIGRATION:
If migrating from another provider:
1. Export emails from old provider
2. Import to GoDaddy Professional Email
3. Update MX records to point to GoDaddy
4. Test email sending and receiving
5. Keep old email active for 30 days during transition

For technical assistance, contact GoDaddy email support 24/7.$$,
'GUIDE', 'EMAIL', 'email,setup,imap,smtp,configuration', 'Email Team', CURRENT_TIMESTAMP(), 34521, 4.8, TRUE, CURRENT_TIMESTAMP()),

('KB004', 'SSL Certificate Installation and Troubleshooting',
$$SSL (Secure Sockets Layer) certificates encrypt data between your website and visitors. This guide covers SSL installation and common issues.

WHY YOU NEED SSL:
- Encrypts sensitive data (passwords, credit cards)
- Improves search engine rankings
- Builds customer trust
- Required for e-commerce
- Browsers show "Not Secure" without SSL

SSL CERTIFICATE TYPES:

Domain Validated (DV):
- Basic encryption
- Validates domain ownership only
- Issues in minutes
- Best for: Blogs, personal sites
- Price: $79.99/year

Organization Validated (OV):
- Business verification
- Displays organization name
- Issues in 1-3 days
- Best for: Business websites
- Price: $299.99/year

Extended Validation (EV):
- Highest validation level
- Green address bar (some browsers)
- Extensive business verification
- Issues in 3-7 days
- Best for: E-commerce, enterprises
- Price: $499.99/year

Wildcard SSL:
- Covers unlimited subdomains
- Single certificate for *.yourdomain.com
- Cost-effective for multiple subdomains
- Price: $299.99/year

AUTOMATIC INSTALLATION (MANAGED HOSTING):
If you have GoDaddy hosting:
1. Purchase SSL certificate
2. GoDaddy automatically installs within 24 hours
3. Certificate renews automatically before expiration
4. No technical knowledge required

MANUAL INSTALLATION:
For external hosting:
1. Generate CSR (Certificate Signing Request)
2. Submit CSR to GoDaddy
3. Complete domain validation
4. Download certificate files
5. Install on your web server
6. Configure server to use HTTPS
7. Test installation

FORCE HTTPS:
Add to .htaccess file:
```
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

Or use hosting control panel redirect feature.

TROUBLESHOOTING:

"Not Secure" Warning:
- Verify SSL is installed correctly
- Check certificate hasn't expired
- Ensure HTTPS is enforced
- Fix mixed content (HTTP resources on HTTPS pages)

Certificate Mismatch:
- Certificate doesn't match domain name
- Install correct certificate for your domain
- Use wildcard cert for subdomains

Certificate Expired:
- Renew certificate before expiration
- Enable auto-renewal
- Update certificate on server

Mixed Content Errors:
- Update all HTTP links to HTTPS
- Update image sources
- Update script sources
- Check third-party resources

MONITORING SSL:
- Check expiration date regularly
- Enable auto-renewal
- Monitor certificate validity
- Test HTTPS functionality after updates

SSL CHECKERS:
- ssllabs.com/ssltest - comprehensive SSL testing
- whynopadlock.com - finds mixed content issues
- GoDaddy dashboard - certificate status

For SSL installation assistance, contact GoDaddy SSL support team.$$,
'GUIDE', 'SSL', 'ssl,certificate,https,security,encryption', 'Security Team', CURRENT_TIMESTAMP(), 19876, 4.6, TRUE, CURRENT_TIMESTAMP()),

('KB005', 'GoDaddy Website Builder: Complete Guide',
$$GoDaddy Website Builder is a drag-and-drop tool for creating professional websites without coding. This comprehensive guide covers all features.

GETTING STARTED:
1. Choose a template or start from scratch
2. Customize design and content
3. Add pages and sections
4. Connect your domain
5. Publish your site

CHOOSING A TEMPLATE:
- 100+ professionally designed templates
- Categories: Business, Portfolio, E-commerce, Blog, Restaurant, etc.
- Mobile-responsive by default
- Customizable colors, fonts, layouts
- Preview before selecting

EDITOR FEATURES:

Drag-and-Drop Interface:
- Add sections by clicking + icon
- Drag elements anywhere on page
- Resize by dragging corners
- Duplicate sections quickly
- Undo/redo changes

Content Elements:
- Text blocks
- Images and galleries
- Videos (YouTube, Vimeo)
- Buttons and links
- Contact forms
- Social media feeds
- Maps
- Testimonials
- Pricing tables

Design Customization:
- Change fonts (100+ Google Fonts)
- Customize colors (brand colors)
- Adjust spacing and padding
- Background images or colors
- Animations and transitions

PAGES AND NAVIGATION:
- Add unlimited pages
- Create dropdown menus
- Set homepage
- Configure URL slugs
- Add footer links
- Hide pages from navigation

SEO FEATURES:
- Edit meta titles and descriptions
- Add alt text to images
- Create XML sitemap (automatic)
- Submit to search engines
- Mobile-friendly (Google ranking factor)
- Fast page load speeds

E-COMMERCE (COMMERCE PLAN):
- Add products with images and descriptions
- Set pricing and variants
- Configure shipping options
- Accept credit card payments
- Manage orders
- Track inventory
- Offer coupon codes

FORMS AND EMAIL:
- Contact forms
- Newsletter signup
- Custom forms
- Email notifications
- Integration with marketing tools

MOBILE EDITING:
- Separate mobile view
- Adjust mobile layout independently
- Test mobile responsiveness
- Mobile-specific content

ANALYTICS:
- Visitor statistics
- Page views
- Traffic sources
- Geographic data
- Device types

PUBLISHING:
1. Click Preview to test
2. Check mobile view
3. Click Publish
4. Choose domain
5. Site goes live immediately

CUSTOM DOMAIN:
- Connect existing GoDaddy domain
- Purchase new domain
- Use temporary domain during development

TROUBLESHOOTING:

Changes Not Saving:
- Check internet connection
- Clear browser cache
- Try different browser
- Save frequently

Site Not Loading:
- Verify domain is connected
- Check DNS propagation (24-48 hours)
- Clear browser cache

Mobile View Issues:
- Use mobile editor
- Test on actual mobile devices
- Adjust mobile-specific settings

Slow Loading:
- Optimize image sizes
- Limit video embeds
- Remove unnecessary sections
- Compress files

BEST PRACTICES:
- Keep design simple and clean
- Use high-quality images
- Write clear, concise content
- Include clear calls-to-action
- Test on multiple devices
- Update content regularly
- Optimize for search engines

SUPPORT RESOURCES:
- Video tutorials in editor
- Live chat support
- Phone support 24/7
- Community forum
- Knowledge base articles

For Website Builder assistance, contact GoDaddy support team.$$,
'GUIDE', 'WEBSITE_BUILDER', 'website builder,templates,editor,design', 'Product Team', CURRENT_TIMESTAMP(), 42157, 4.7, TRUE, CURRENT_TIMESTAMP());

-- ============================================================================
-- Step 8: Create Cortex Search Service for Support Transcripts
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE SUPPORT_TRANSCRIPTS_SEARCH
  ON transcript_text
  ATTRIBUTES customer_id, agent_id, interaction_type, interaction_date
  WAREHOUSE = GODADDY_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for customer support transcripts - enables semantic search across support interactions'
AS
  SELECT
    transcript_id,
    transcript_text,
    ticket_id,
    customer_id,
    agent_id,
    interaction_type,
    interaction_date,
    sentiment_score,
    keywords,
    created_at
  FROM RAW.SUPPORT_TRANSCRIPTS;

-- ============================================================================
-- Step 9: Create Cortex Search Service for Domain Transfer Notes
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE DOMAIN_TRANSFER_NOTES_SEARCH
  ON note_text
  ATTRIBUTES domain_id, customer_id, note_type, transfer_status, created_date
  WAREHOUSE = GODADDY_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Cortex Search service for domain transfer notes - enables semantic search across transfer documentation'
AS
  SELECT
    note_id,
    note_text,
    domain_id,
    customer_id,
    note_type,
    transfer_status,
    issue_resolved,
    created_date,
    created_by,
    created_at
  FROM RAW.DOMAIN_TRANSFER_NOTES;

-- ============================================================================
-- Step 10: Create Cortex Search Service for Knowledge Base
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE KNOWLEDGE_BASE_SEARCH
  ON content
  ATTRIBUTES article_category, product_category, title
  WAREHOUSE = GODADDY_WH
  TARGET_LAG = '24 hours'
  COMMENT = 'Cortex Search service for knowledge base articles - enables semantic search across help documentation'
AS
  SELECT
    article_id,
    title,
    content,
    article_category,
    product_category,
    tags,
    author,
    last_updated,
    view_count,
    helpfulness_score,
    created_at
  FROM RAW.KNOWLEDGE_BASE_ARTICLES;

-- ============================================================================
-- Step 11: Verify Cortex Search Services Created
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;

-- ============================================================================
-- Display success message
-- ============================================================================
SELECT 'Cortex Search services created successfully' AS status,
       COUNT(*) AS service_count
FROM (
  SELECT 'SUPPORT_TRANSCRIPTS_SEARCH' AS service_name
  UNION ALL
  SELECT 'DOMAIN_TRANSFER_NOTES_SEARCH'
  UNION ALL
  SELECT 'KNOWLEDGE_BASE_SEARCH'
);

-- ============================================================================
-- Display data counts
-- ============================================================================
SELECT 'SUPPORT_TRANSCRIPTS' AS table_name, COUNT(*) AS row_count FROM SUPPORT_TRANSCRIPTS
UNION ALL
SELECT 'DOMAIN_TRANSFER_NOTES', COUNT(*) FROM DOMAIN_TRANSFER_NOTES
UNION ALL
SELECT 'KNOWLEDGE_BASE_ARTICLES', COUNT(*) FROM KNOWLEDGE_BASE_ARTICLES
ORDER BY table_name;

