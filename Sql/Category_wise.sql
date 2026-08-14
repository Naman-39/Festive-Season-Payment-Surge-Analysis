SELECT
  city_tier,
  category,
  festival_name,

  -- Volume metrics
  Total_txn_count,
  avg_txn_count,
   -- Change in transaction count (absolute)
  (Total_txn_count - avg_txn_count)            
    AS txn_count_change,
    -- Change in transaction count (percentage)
  ROUND(
    ((Total_txn_count - avg_txn_count) / avg_txn_count) * 100
  , 1)                                           
    AS txn_count_change_pct,
  Avg_PerTxn_amt,
  avgtxn_amt,
  ROUND(
    ((Avg_PerTxn_amt -  avgtxn_amt) /  avgtxn_amt) * 100
  , 1)                                           
    AS avg_amt_change_pct,
   Total_gmv_value,
   avg_gmv_value,
-- Change in GMV (absolute)
  round((Total_gmv_value - avg_gmv_value),2)            
    AS gmv_change,

  -- Change in GMV (percentage)
  ROUND(
    ((Total_gmv_value - avg_gmv_value) / avg_gmv_value) * 100
  , 1)                                           
    AS gmv_change_pct,
    
    ROUND(
    Total_txn_count * 100.0 /
    SUM(Total_txn_count) OVER (PARTITION BY category, city_tier)
  , 1)                                           AS Festival_txn_share_pct ,
   -- Rank of category within each festival
  RANK() OVER (
    PARTITION BY category, city_tier
    ORDER BY Total_txn_count DESC
  )                                              AS Festival_rank,
  

 

  -- Dashboard labels
  CASE
    WHEN festival_name = 'None' THEN 'Non-Festival'
    ELSE 'Festival'
  END     AS day_type,

  CASE
    WHEN ROUND(
           ((Avg_PerTxn_amt - avgtxn_amt) / avgtxn_amt) * 100
         , 1) > 15  THEN ' Major Increase'
    WHEN ROUND(
           ((Avg_PerTxn_amt - avgtxn_amt) / avgtxn_amt) * 100
         , 1) > 0   THEN 'Slight Increase'
    WHEN ROUND(
           ((Avg_PerTxn_amt - avgtxn_amt) / avgtxn_amt) * 100
         , 1) < 0   THEN 'Decline'
    ELSE 'Stable'
  END        AS Per_txn_growth

FROM (
  SELECT
    city_tier,
    category,
    festival_name,

    -- Core aggregates
    SUM(transaction_count)                          AS Total_txn_count,
    SUM(total_gmv_inr)                              AS Total_gmv_value,
    ROUND(AVG(avg_transaction_amount_inr), 2)       AS Avg_PerTxn_amt,

    -- LAG with PARTITION BY so comparison stays within same group
    round(avg(SUM(transaction_count))
      OVER (PARTITION BY category, city_tier
            ORDER BY festival_name  rows between unbounded preceding and unbounded following),2)  AS avg_txn_count,

    round(avg(ROUND(AVG(avg_transaction_amount_inr), 2))
      OVER (PARTITION BY category, city_tier
            ORDER BY festival_name rows between unbounded preceding and unbounded following),2)   AS avgtxn_amt,

    round(avg(SUM(total_gmv_inr))
      OVER (PARTITION BY category, city_tier
            ORDER BY festival_name rows between unbounded preceding and unbounded following),2)  AS avg_gmv_value
  FROM phonepe.payments
  GROUP BY category, city_tier, festival_name
) t
ORDER BY category, city_tier, festival_name;


select * from category_wise
where Per_txn_growth like '%Increase' and category = 'Gifting'
order by category,city_tier,avg_amt_change_pct desc,Festival_rank;
-- Key Insights Gifting Sector's Avg xn value increase by nearly 40% during Diwalicand Raksha Bandhan coampared to yearly avg.