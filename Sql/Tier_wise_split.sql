use phonepe;
CREATE VIEW festival_wise AS
SELECT 
city_tier , festival_name,category,Total_gmv_value,max_gmv,total_gmv_value-max_gmv as Gmv_change
,((total_gmv_value-max_gmv)/max_gmv)*100 as Per_gmv_change,
Total_txn_count,maxfest_count,
Total_txn_count-maxfest_count as Txn_change,
((Total_txn_count-maxfest_count)/maxfest_count)*100 as Per_txn_change
,Avg_PerTxn_amt,max_txn_value,
Avg_PerTxn_amt-max_txn_value as Avg_value_change ,
((Avg_PerTxn_amt-max_txn_value)/max_txn_value)*100 as Per_value_change,
-- Share of this category within the festival (most useful column)
  ROUND(
    Total_txn_count * 100.0 /
    SUM(Total_txn_count) OVER (PARTITION BY festival_name, city_tier)
  , 1)                                           AS Category_txn_share_pct,

  -- Rank of category within each festival
  RANK() OVER (
    PARTITION BY festival_name, city_tier
    ORDER BY Total_txn_count DESC
  )                                              AS Category_rank,

 CASE
    WHEN festival_name = 'None' THEN 'Non-Festival'
    ELSE 'Festival'
  END AS day_type,
  CASE
    WHEN ROUND(
           ((Total_txn_count -  maxfest_count) /  maxfest_count) * 100
         , 1) > 20  THEN 'High Growth'
    WHEN ROUND(
           ((Total_txn_count -  maxfest_count) /  maxfest_count) * 100
         , 1) > 0   THEN 'Moderate Growth'
    WHEN ROUND(
           ((Total_txn_count - maxfest_count) / maxfest_count) * 100
         , 1) < 0   THEN 'Decline'
    ELSE 'Stable'
  END AS growth_label
FROM
    (SELECT city_tier,category ,festival_name,total_gmv_inr,sum(transaction_count)as Total_txn_count,
sum(total_gmv_inr)as Total_gmv_value ,
avg(sum(total_gmv_inr)) over (PARTITION BY festival_name, city_tier 
order by festival_name, city_tier,category 
rows between unbounded preceding and unbounded following)as max_gmv,
round(avg(avg_transaction_amount_inr),2) as Avg_PerTxn_amt ,
avg(round(avg(avg_transaction_amount_inr),2)) over 
(PARTITION BY festival_name, city_tier order by festival_name, city_tier,category 
rows between unbounded preceding and unbounded following) as max_txn_value,
avg(sum(transaction_count)) over (PARTITION BY festival_name, city_tier
rows between unbounded preceding and unbounded following) as maxfest_count
FROM phonepe.payments 
group by festival_name, city_tier,category ) t
order by festival_name, city_tier,category;
-- Key Insights
-- Gifting in Raksha Bandhan and Diwali has the highest txn count across all tiers with nearly 95% and 80% more compared to avg txn 
-- Entertainment and Travelling in New Year has the highest transaction growth in 50% and gmv growth across all city tiers nearly '260%' gmv growth
-- then Food&Dining in New Year and Shopping in Diwali , Entertainment in christmas are subsequent categories 

SELECT * FROM FESTIVAL_WISE
WHERE DAY_TYPE='NON-FESTIVAL'
order by per_txn_change desc;
-- ON normal days Tier 1 cities has max txns on billing and 
-- tier 2,3 on Groceries with a minute change of 0.25% from avg figures

select * ,Festival_AvgTxnValue-NonFestival_AvgTxnValue as TxnValue_growth,
(((Festival_Gmv/Festival_Txn)-(Nonfestival_gmv/Nonfestival_Txn))/(Nonfestival_Gmv/Nonfestival_Txn))*100 
as Gmvgrowth_Per from (SELECT
    AVG(CASE WHEN day_type = 'FESTIVAL' THEN total_gmv_value END) AS Festival_GMV,
    AVG(CASE WHEN day_type = 'NON-FESTIVAL' THEN total_gmv_value END) AS NonFestival_GMV,

    AVG(CASE WHEN day_type = 'FESTIVAL' THEN Total_txn_count END) AS Festival_Txn,
    AVG(CASE WHEN day_type = 'NON-FESTIVAL' THEN Total_txn_count END) AS NonFestival_Txn,

    AVG(CASE WHEN day_type = 'FESTIVAL' THEN avg_pertxn_amt END) AS Festival_AvgTxnValue,
    AVG(CASE WHEN day_type = 'NON-FESTIVAL' THEN avg_pertxn_amt END) AS NonFestival_AvgTxnValue
FROM festival_wise) t;
-- Key Insights People Spend about Rs.185/txn extra during Festivals
-- Which leads to around 17% more gmv value for particular txns  

SELECT
  festival_name,
  COUNT(CASE WHEN Per_gmv_change > 0 THEN 1 END)   AS categories_that_grew,
  COUNT(CASE WHEN per_txn_change > 0 THEN 1 END)   as Txn_growth,
  COUNT(*)                                           AS total_categories,
  AVG(Per_gmv_change)                     AS avg_growth_across_categories
FROM festival_wise
WHERE festival_name != 'None'
GROUP BY festival_name 
ORDER BY categories_that_grew DESC, avg_growth_across_categories DESC;
-- Key Insights Navratri enables a market growth among 12 categories then dussehra with 11.






