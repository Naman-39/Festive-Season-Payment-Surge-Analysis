SELECT * FROM phonepe.payments 
order by total_gmv_inr desc limit 10;

SELECT * FROM phonepe.payments 
where festival_name = 'diwali'
order by total_gmv_inr desc limit 10;

SELECT * FROM phonepe.payments 
group by festival_name 
order by total_gmv_inr desc limit 10;

-- Highest surge_intensity days across the whole dataset
SELECT date, city, festival_name, surge_intensity
FROM phonepe.payments
WHERE festival_name != 'None' and city_tier = 'tier1'
ORDER BY surge_intensity desc
LIMIT 80;


SELECT * FROM phonepe.payments
group by festival_name and category;

-- All Diwali rows (both years) sorted by transaction count
SELECT
  date,
  city,
  city_tier,
  category,
  transaction_count,
  total_gmv_inr,
  surge_intensity
FROM phonepe.payments
WHERE festival_name LIKE '%Diwali%'
ORDER BY transaction_count DESC
LIMIT 10;
-- On Diwali peak day, Kolkata had the highest transaction volume in Gifting with 11090 transactions and top 10 is gifting only. 

-- Bonus: same but for surge_intensity = 1.0 (peak day only)
SELECT
  date,
  city,
  city_tier,
  category,
  transaction_count,
  total_gmv_inr
FROM phonepe.payments
WHERE festival_name LIKE '%Diwali%'
  AND surge_intensity = 1.0
ORDER BY transaction_count DESC
LIMIT 20;

select *,((Avg_PerTxn_amt - prev_value)/prev_value)*100 as '%pertxnchange' ,
Total_txn_count-prevfest_count as 'Txn_count_change'
from(SELECT city_tier,category ,festival_name,sum(transaction_count)as Total_txn_count,
sum(total_gmv_inr)as Total_gmv_value ,round(avg(avg_transaction_amount_inr),2) as Avg_PerTxn_amt ,
lag(round(avg(avg_transaction_amount_inr),2)) over (PARTITION BY festival_name, city_tier order by festival_name, city_tier,category) as prev_value,
lag(sum(transaction_count)) over (PARTITION BY festival_name, city_tier) as 'prevfest_count'
FROM phonepe.payments 
group by festival_name, city_tier,category ) t
order by festival_name, city_tier,category;

-- Top Performing City per festival
with cte as 
(SELECT  festival_name , city , city_tier,sum(total_gmv_inr)as Total_GMV,
Row_number() over (partition by festival_name ORDER BY sum(total_gmv_inr) desc) as City_rank
from payments
group by city,festival_name) 
select * from cte 
where city_rank <=1
group by Total_GMV
ORDER BY Total_GMV DESC ;

-- Top Performing Categories Per city_tier
with T as (
SELECT city_tier , category , sum(transaction_count) as Total_Txncount ,
RANK()OVER(partition by city_tier order by transaction_count desc ) as Category_Rank
from payments
group by  city_tier, category   )
select * from T 
where Category_rank <= 1
group by Total_Txncount;

-- Quartile split of City_tier+ Category
with T as (
SELECT city ,city_tier, category , sum(total_gmv_inr) as Total_gmv ,
NTILE(4)OVER( order by sum(total_gmv_inr) desc ) as Category_Rank
from payments
group by  city, category   )
select city ,city_tier, category , Total_gmv ,
CASE 
    WHEN Category_Rank = 1 then 'High Value'
    WHEN Category_Rank = 2 then 'Medium High Value'
    WHEN Category_Rank = 3 then 'Medium Low Value'
    WHEN Category_Rank = 4 then 'Low Value'
    else 'Low Value' 
    END as GMV_value
    from T 
ORDER BY Total_gmv DESC;

-- All the txn_count spike is during festivals showing a 1.5x or more spike during festivals 
WITH FLAGS AS (
with Rolling as (
SELECT `DATE`,city_tier,category,transaction_count,festival_name,
avg(transaction_count) OVER(
                         partition by city_tier order by `date` 
                         ROWS BETWEEN 6 PRECEDING AND CURRENT ROW ) as weekly_avg from payments)
SELECT `DATE`,city_tier,category,transaction_count ,weekly_avg,festival_name,
CASE 
      WHEN transaction_count > 1.5*weekly_avg then 'surge days'
      else 'Normal days'
      END as Days FROM rolling )
      SELECT `DATE`,city_tier,category,transaction_count,weekly_avg,festival_name,days from flags
      where days = 'surge days';

-- FESTIVAL IMPACT SCORE (BASED ON CITY )
WITH city_metrics AS
(
    SELECT
        city,

        AVG(CASE WHEN festival_name <> 'None'
                 THEN total_gmv_inr END) AS fest_gmv,

        AVG(CASE WHEN festival_name = 'None'
                 THEN total_gmv_inr END) AS nonfest_gmv,

        AVG(CASE WHEN festival_name <> 'None'
                 THEN transaction_count END) AS fest_txn,

        AVG(CASE WHEN festival_name = 'None'
                 THEN transaction_count END) AS nonfest_txn,

        AVG(CASE WHEN festival_name <> 'None'
                 THEN avg_transaction_amount_inr END) AS fest_ticket,

        AVG(CASE WHEN festival_name = 'None'
                 THEN avg_transaction_amount_inr END) AS nonfest_ticket

    FROM payments
    GROUP BY city
),

growth_metrics AS
(
    SELECT
        city,
        ROUND(
            ((fest_gmv-nonfest_gmv)/nonfest_gmv)*100,2
        ) AS gmv_growth_pct,
        ROUND(
            ((fest_txn-nonfest_txn)/nonfest_txn)*100,2
        ) AS txn_growth_pct,
        ROUND(
            ((fest_ticket-nonfest_ticket)/nonfest_ticket)*100,2
        ) AS ticket_growth_pct
    FROM city_metrics
),
SCORES AS (
SELECT city ,gmv_growth_pct,txn_growth_pct,ticket_growth_pct ,
      round( (0.4*gmv_growth_pct)+(0.4*txn_growth_pct)+(0.2*ticket_growth_pct),2) as Agg_score from growth_metrics) 
       SELECT
    city,
    AGG_score,gmv_growth_pct,txn_growth_pct,ticket_growth_pct,
round(100 * (agg_score - MIN(agg_score) OVER()) /
(MAX(agg_score) OVER() - MIN(agg_score) OVER()),2) as Normalised_score,
    DENSE_RANK()
    OVER (ORDER BY AGG_score DESC) AS city_rank,

    CASE
        WHEN round(100 * (agg_score - MIN(agg_score) OVER()) /
(MAX(agg_score) OVER() - MIN(agg_score) OVER()),2) > 70
            THEN 'Festival-Dependent'

        WHEN round(100 * (agg_score - MIN(agg_score) OVER()) /
(MAX(agg_score) OVER() - MIN(agg_score) OVER()),2) >= 40
            THEN 'Moderate'

        ELSE 'Festival-Resistant'
    END AS city_type

FROM scores
ORDER BY AGG_score DESC ;

