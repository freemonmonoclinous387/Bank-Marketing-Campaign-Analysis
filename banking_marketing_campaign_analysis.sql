
create database bank_marketing_campaign_db;


use bank_marketing_campaign_db;

CREATE TABLE data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    occupation VARCHAR(50),
    age INT,
    education_level VARCHAR(50),
    marital_status VARCHAR(50),
    communication_channel VARCHAR(50),
    call_month VARCHAR(15),
    call_day INT,
    call_duration INT, -- Duration in seconds
    call_frequency INT,
    previous_campaign_outcome VARCHAR(50),
    conversion_status VARCHAR(20)
);

-- total number of records
select count(*) from data;


-- 1. Overall Campaign Conversion Rate
-- What percentage of customers converted in the campaign?

select * from data;

select 
	conversion_status,
    (count(*) / (select count(*) from data))*100 as percentages
from data
group by conversion_status
having conversion_status = "converted";

-- 2. Conversion Rate by Customer Segment
-- Which age group / occupation / education level has the highest conversion rate?

-- correlated subquery -> too complex and time consuming
SELECT 
    occupation,
    (SELECT COUNT(*) 
     FROM data AS d2 
     WHERE d2.conversion_status = 'converted' 
     AND d2.occupation = d1.occupation) AS converted_counts
FROM data AS d1
GROUP BY occupation;

-- efficient query
select
	occupation,
    count( case when conversion_status="converted" then 1 end ) as converted_counts ,
    count(*) as total_counts,
    round((count( case when conversion_status="converted" then 1 end ) / count(*)) * 100 , 2)as percentages
from data 
group by occupation
order by percentages desc;


-- 3. Conversion Rate by Communication Channel
-- Which channel (mobile, telephone, etc.) performs best?

select * from data;

select
	communication_channel,
    count( case when conversion_status="converted" then 1 end) as converted_counts,
    count(*) as total_counts,
    round((count( case when conversion_status="converted" then 1 end) / count(*) * 100 ), 2) as percentages
from data
group by communication_channel
order by percentages desc;


-- 4. Monthly Campaign Performance
-- Which month generated the highest conversion rate and total conversions?

select
	call_month,
    count( case when conversion_status="converted" then 1 end) as converted_counts,
    count(*) as total_counts,
    round((count( case when conversion_status="converted" then 1 end) / count(*) * 100 ), 2) as percentages
from data
group by call_month
order by percentages desc;



-- 5. Campaign Volume vs Conversion
-- Which months had high call volume but low conversions (inefficient campaigns)?

select * from data;

-- call_day is the day of the month on which we made a call
select 
distinct (call_day)
from data
order by call_day;


with cte as (
select 
	call_month,
    sum(call_frequency) as total_calls,
    count(case when conversion_status="converted" then 1 end) as converted_counts
from data
group by call_month )
select 
	*,
    round((converted_counts / total_calls)*100, 1) as efficiency
from cte
order by efficiency desc;



-- Campaign Efficiency Queries

-- 6. Optimal Call Frequency
-- What is the conversion rate by number of calls made to customers?

select
	call_frequency,
    count(case when conversion_status="converted" then 1 end) as converted_counts,
    count(*) as total_customers,
	(count(case when conversion_status="converted" then 1 end)  /
    count(*) ) * 100 as conversion_rate
from data
group by call_frequency
order by conversion_rate desc;


-- 7. Diminishing Returns Analysis
-- After how many calls does conversion probability start dropping?
select
	call_frequency,
    count(case when conversion_status="converted" then 1 end) as converted_leads
from data
group by call_frequency
order by call_frequency;

-- insight:
-- roughly after 20 call per person, the conversion probability starts dropping



-- 8. Call Duration Effectiveness
-- Does longer call duration increase conversion probability?

select * from data;

SELECT DISTINCT
    call_duration,
    COUNT(CASE WHEN conversion_status = 'converted' THEN 1 END) 
        OVER(PARTITION BY call_duration) AS conversion_counts
FROM data
ORDER BY conversion_counts DESC;
