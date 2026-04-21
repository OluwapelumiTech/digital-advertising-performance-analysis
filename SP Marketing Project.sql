---DIGITAL ADVERTISING PERFORMANCE ANALYSIS

---Tool:       DuckDB SQL (via VS Code DuckDB Extension)
---Dataset:    events.parquet (11.5 million rows)
---Author:     Oluwapelumi Akintoye
---Date:       April 2026

---Analysis covers three directions:
 --- 1. Data Exploration and Quality Checks
 --- 2. Cost Efficiency and Margin Optimisation
 --- 3. Funnel Efficiency and Lead Quality Analysis

--- Note: All monetary values are in Euros (EUR)


  
SET file_search_path = 'C:/Users/admin/Documents/MY PYTHON PRACTICE';

CREATE OR REPLACE VIEW events AS
SELECT * FROM 'events.parquet';

SELECT COUNT(*) as total_rows FROM events;

SELECT * FROM events
LIMIT 10;

-- SECTION 1: DATA EXPLORATION

SELECT COUNT(*) as total_rows 
FROM events;

--What event type exist and how many of each?
SELECT 
    event_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM events), 2) as percentage
FROM events
GROUP BY event_type
ORDER BY count DESC;

--What ad platforms exist?
SELECT 
    ad_platform,
    COUNT(*) as event_count
FROM events
GROUP BY ad_platform
ORDER BY event_count DESC;

--What campaigns exist?
SELECT 
    campaign_type,
    COUNT(*) as count
FROM events
GROUP BY campaign_type
ORDER BY count DESC;

-- and Date Range?
SELECT 
    MIN(event_date) as earliest_date,
    MAX(event_date) as latest_date,
    COUNT(DISTINCT event_date) as total_days
FROM events;

--Are there nulls in any column?
SELECT
    COUNT(*) - COUNT(event_id) as null_event_id,
    COUNT(*) - COUNT(event_date) as null_event_date,
    COUNT(*) - COUNT(event_type) as null_event_type,
    COUNT(*) - COUNT(money) as null_money,
    COUNT(*) - COUNT(click_id) as null_click_id,
    COUNT(*) - COUNT(campaign_id) as null_campaign_id,
    COUNT(*) - COUNT(campaign_type) as null_campaign_type,
    COUNT(*) - COUNT(traffic_source_id) as null_traffic_source_id,
    COUNT(*) - COUNT(ad_platform) as null_ad_platform,
    COUNT(*) - COUNT(manager_id) as null_manager_id
FROM events;

--How many unique identifiers do I have?
SELECT
    COUNT(DISTINCT campaign_id) as unique_campaigns,
    COUNT(DISTINCT traffic_source_id) as unique_traffic_sources,
    COUNT(DISTINCT manager_id) as unique_managers,
    COUNT(DISTINCT click_id) as unique_sessions
FROM events;

--Checking the real deal (money column)
SELECT
    MIN(money) as min_value,
    MAX(money) as max_value,
    ROUND(AVG(money), 2) as avg_value,
    COUNT(*) FILTER (WHERE money < 0) as negative_values,
    COUNT(*) FILTER (WHERE money = 0) as zero_values,
    COUNT(*) FILTER (WHERE money > 0) as positive_values
FROM events;


-- SECTION 2: COST EFFICIENCY AND MARGIN ANALYSIS

-- How is our campaigns costing us money and brining in money?
SELECT 
    campaign_type,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) - 
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin
FROM events
GROUP BY campaign_type
ORDER BY total_revenue DESC;

--cost to revenue ratio for campaigns
SELECT 
    campaign_type,
    
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) AS total_cost,
    
    SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) AS total_revenue,
    
    ROUND(
        CASE 
            WHEN SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) = 0 
            THEN NULL
            ELSE 
                (SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) * 100.0) /
                SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END)
        END
    , 2) AS cost_to_revenue_pct

FROM events

GROUP BY campaign_type

ORDER BY cost_to_revenue_pct ASC;

--- How are ad paltforms costing us money and brining in money?
SELECT 
    ad_platform,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) - 
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin
FROM events
GROUP BY ad_platform
ORDER BY total_revenue DESC;

--- Cost-Revenue Ratio of Ad Platforms
SELECT 
    ad_platform,
    
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) AS total_cost,
    
    SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) AS total_revenue,
    
    ROUND(
        CASE 
            WHEN SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) = 0 
            THEN NULL
            ELSE 
                (SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) * 100.0) /
                SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END)
        END
    , 2) AS cost_to_revenue_pct

FROM events

GROUP BY ad_platform

ORDER BY cost_to_revenue_pct ASC;

--- How does activity look week by week?
SELECT 
    DATE_TRUNC('week', event_date) as week_start,
    COUNT(*) as total_events,
    COUNT(DISTINCT click_id) as unique_sessions,
    SUM(CASE WHEN event_type = 'VISIT' THEN 1 ELSE 0 END) as visits,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2)  as cost
FROM events
GROUP BY week_start
ORDER BY week_start;

--- Top campaigns by revenue
SELECT 
    campaign_id,
    campaign_type,
    ad_platform,
    SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) as total_revenue,
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) as total_cost,
    COUNT(DISTINCT click_id) as unique_sessions
FROM events
GROUP BY campaign_id, campaign_type, ad_platform
ORDER BY total_revenue DESC
LIMIT 10;

-- SECTION 3: FUNNEL EFFICIENCY ANALYSIS

---Funnel Overview 
SELECT
    SUM(CASE WHEN event_type = 'VISIT' THEN 1 ELSE 0 END) as visits,
    SUM(CASE WHEN event_type = 'PRELIMINARY_LEAD' THEN 1 ELSE 0 END) as preliminary_leads,
    SUM(CASE WHEN event_type = 'FULL_LEAD' THEN 1 ELSE 0 END) as full_leads,
    SUM(CASE WHEN event_type = 'REVENUE' THEN 1 ELSE 0 END) as revenue_events,
    ROUND(SUM(CASE WHEN event_type = 'PRELIMINARY_LEAD' THEN 1 ELSE 0 END) * 100.0 / 
    SUM(CASE WHEN event_type = 'VISIT' THEN 1 ELSE 0 END), 2) as visit_to_prelead_pct,
    ROUND(SUM(CASE WHEN event_type = 'FULL_LEAD' THEN 1 ELSE 0 END) * 100.0 / 
    SUM(CASE WHEN event_type = 'PRELIMINARY_LEAD' THEN 1 ELSE 0 END), 2) as prelead_to_fulllead_pct,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN 1 ELSE 0 END) * 100.0 / 
    SUM(CASE WHEN event_type = 'FULL_LEAD' THEN 1 ELSE 0 END), 2) as fulllead_to_revenue_pct
FROM events;

---Funnel by Ads Platform
WITH platform_funnel AS (
    SELECT
        ad_platform,
        COUNT(DISTINCT CASE WHEN event_type = 'VISIT' 
            THEN click_id END) as visits,
        COUNT(DISTINCT CASE WHEN event_type = 'PRELIMINARY_LEAD' 
            THEN click_id END) as prelim_leads,
        COUNT(DISTINCT CASE WHEN event_type = 'FULL_LEAD' 
            THEN click_id END) as full_leads,
        COUNT(DISTINCT CASE WHEN event_type = 'REVENUE' 
            THEN click_id END) as converted,
        ROUND(SUM(CASE WHEN event_type = 'REVENUE' 
            THEN money ELSE 0 END), 2) as total_revenue,
        ROUND(SUM(CASE WHEN event_type = 'COST' 
            THEN money ELSE 0 END), 2) as total_cost
    FROM events
    GROUP BY ad_platform
)
SELECT
    ad_platform,
    visits,
    prelim_leads,
    full_leads,
    converted,
    total_revenue,
    total_cost,
    ROUND(full_leads * 100.0 / NULLIF(visits, 0), 2) as visit_to_fulllead_pct,
    ROUND(converted * 100.0 / NULLIF(full_leads, 0), 2) as fulllead_to_revenue_pct,
    ROUND(total_revenue / NULLIF(converted, 0), 2) as avg_revenue_per_conversion
FROM platform_funnel
ORDER BY total_revenue DESC;

---Leads Quality by Ads Platform
SELECT
    ad_platform,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_1' THEN 1 END) as tier_1,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_2' THEN 1 END) as tier_2,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_3' THEN 1 END) as tier_3,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_4' THEN 1 END) as tier_4,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_5' THEN 1 END) as tier_5,
    COUNT(CASE WHEN event_type LIKE 'LEAD_TIER%' THEN 1 END) as total_tiered,
    ROUND(COUNT(CASE WHEN event_type = 'LEAD_TIER_1' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(CASE WHEN event_type LIKE 'LEAD_TIER%' THEN 1 END), 0), 2) as tier1_pct
FROM events
GROUP BY ad_platform
ORDER BY tier_1 DESC;


--- Revenue by Leads Quality
WITH tier_revenue AS (
    SELECT
        e1.click_id,
        e1.event_type as lead_tier,
        SUM(e2.money) as revenue_generated
    FROM events e1
    JOIN events e2 
        ON e1.click_id = e2.click_id
        AND e2.event_type = 'REVENUE'
    WHERE e1.event_type LIKE 'LEAD_TIER%'
    GROUP BY e1.click_id, e1.event_type
)
SELECT
    lead_tier,
    COUNT(*) as lead_count,
    ROUND(AVG(revenue_generated), 2) as avg_revenue_per_lead,
    ROUND(SUM(revenue_generated), 2) as total_revenue,
    ROUND(MIN(revenue_generated), 2) as min_revenue,
    ROUND(MAX(revenue_generated), 2) as max_revenue
FROM tier_revenue
GROUP BY lead_tier
ORDER BY lead_tier;

---Tier Distribution by Ads Platform with Revenue
SELECT
    ad_platform,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_1' THEN 1 END) as tier_1_leads,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_3' THEN 1 END) as tier_3_leads,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_4' THEN 1 END) as tier_4_leads,
    COUNT(CASE WHEN event_type = 'LEAD_TIER_5' THEN 1 END) as tier_5_leads,
    COUNT(CASE WHEN event_type LIKE 'LEAD_TIER%' THEN 1 END) as total_tiered,
    ROUND(COUNT(CASE WHEN event_type = 'LEAD_TIER_1' THEN 1 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN event_type LIKE 'LEAD_TIER%' THEN 1 END), 0), 2) as tier1_pct,
    ROUND(COUNT(CASE WHEN event_type = 'LEAD_TIER_5' THEN 1 END) * 100.0 /
        NULLIF(COUNT(CASE WHEN event_type LIKE 'LEAD_TIER%' THEN 1 END), 0), 2) as tier5_pct,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
        NULLIF(COUNT(CASE WHEN event_type LIKE 'LEAD_TIER%' THEN 1 END), 0), 2) as revenue_per_tiered_lead
FROM events
GROUP BY ad_platform
ORDER BY tier1_pct DESC;

---Revenue per Tier by Ads Platform
WITH tier_rev AS (
    SELECT
        e1.ad_platform,
        e1.event_type as lead_tier,
        COUNT(*) as lead_count,
        ROUND(SUM(e2.money), 2) as total_revenue,
        ROUND(AVG(e2.money), 2) as avg_revenue_per_lead
    FROM events e1
    JOIN events e2
        ON e1.click_id = e2.click_id
        AND e2.event_type = 'REVENUE'
    WHERE e1.event_type LIKE 'LEAD_TIER%'
    GROUP BY e1.ad_platform, e1.event_type
)
SELECT
    ad_platform,
    lead_tier,
    lead_count,
    total_revenue,
    avg_revenue_per_lead
FROM tier_rev
ORDER BY ad_platform, lead_tier;

--- Overall Margin 
SELECT
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_margin,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
    NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roas
FROM events;

-- The ROAS by Ad Platform
SELECT
    ad_platform,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
    NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roas,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) /
    NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'FULL_LEAD' 
        THEN click_id END), 0), 2) as cost_per_lead
FROM events
GROUP BY ad_platform
ORDER BY roas DESC;

--- Campaign Level ROAS
SELECT
    campaign_type,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
    NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roas
FROM events
GROUP BY campaign_type
ORDER BY roas DESC;

---Top 15 Campaign by Efficiency
SELECT
    campaign_id,
    ad_platform,
    campaign_type,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
    NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roas
FROM events
GROUP BY campaign_id, ad_platform, campaign_type
HAVING SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) > 0
ORDER BY roas DESC
LIMIT 15;

-- Bottom 10 Worst Performing Campaigns
SELECT
    campaign_id,
    ad_platform,
    campaign_type,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
    NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roas
FROM events
GROUP BY campaign_id, ad_platform, campaign_type
HAVING SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) > 100
ORDER BY roas ASC
LIMIT 10;

-- Wekkly Spend vs Revenue Trend
SELECT
    DATE_TRUNC('week', event_date) as week_start,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
    SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
    NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roas
FROM events
GROUP BY week_start
ORDER BY week_start;

---KPIs
SELECT
    ad_platform,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END), 2) as total_revenue,
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as total_cost,
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
        SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 2) as margin,

    -- ROAS: revenue per dollar spent
    ROUND(SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) /
        NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roas,

    -- ROI: percentage return on spend
    ROUND((SUM(CASE WHEN event_type = 'REVENUE' THEN money ELSE 0 END) -
        SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END)) * 100.0 /
        NULLIF(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END), 0), 2) as roi_pct,

    -- CPL: cost to acquire one full lead
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) /
        NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'FULL_LEAD' 
            THEN click_id END), 0), 2) as cpl,

    -- CAC: cost to acquire one paying customer
    ROUND(SUM(CASE WHEN event_type = 'COST' THEN money ELSE 0 END) /
        NULLIF(COUNT(DISTINCT CASE WHEN event_type = 'REVENUE' 
            THEN click_id END), 0), 2) as cac,


    -- Volume metrics
    COUNT(DISTINCT CASE WHEN event_type = 'FULL_LEAD' THEN click_id END) as total_leads,
    COUNT(DISTINCT CASE WHEN event_type = 'REVENUE' THEN click_id END) as total_customers

FROM events
GROUP BY ad_platform
ORDER BY total_revenue DESC;

---Lead-Level Table
SELECT
    click_id,
    MAX(CASE WHEN event_type = 'VISIT' THEN 1 ELSE 0 END) AS visited,
    MAX(CASE WHEN event_type = 'PRELIMINARY_LEAD' THEN 1 ELSE 0 END) AS prelim_lead,
    MAX(CASE WHEN event_type = 'FULL_LEAD' THEN 1 ELSE 0 END) AS full_lead,
    
    MAX(CASE 
        WHEN event_type LIKE 'LEAD_TIER_%' THEN event_type 
    END) AS tier,
    
    MAX(ad_platform) AS ad_platform,
    
    SUM(CASE 
        WHEN event_type = 'REVENUE' THEN money 
        ELSE 0 
    END) AS revenue

FROM events
GROUP BY click_id;
