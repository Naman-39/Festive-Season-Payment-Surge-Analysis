SELECT
  concat(f.festival_name,' ',year(f.end_date))  as Festival_Name ,                         -- uses calendar name (has year)
  f.festival_type as Type,
  f.religion_culture as Relevance,
  SUM(s.total_gmv_inr)                           AS total_festival_gmv,
  DATEDIFF(f.end_date, f.start_date) + 1         AS festival_duration_days,
  ROUND(
    SUM(s.total_gmv_inr) /
    (DATEDIFF(f.end_date, f.start_date) + 1)
  , 0)                                           AS gmv_per_day
FROM phonepe.payments s
JOIN festivalS f
  ON s.`date` BETWEEN f.start_date AND f.end_date
GROUP BY
  f.festival_name,
  f.start_date,
  f.end_date                                     -- include so GROUP BY is unambiguous
ORDER BY gmv_per_day DESC;
-- New Year 2023 has the highest GMV Per Day then comes Christmas 2022 then Diwali 2023


WITH daily_gmv AS (
  SELECT
  s.city_tier,
  concat(f.festival_name,' ',year(f.end_date))  as Festival_Name ,   s.`date`,                      -- uses calendar name (has year)
  SUM(s.total_gmv_inr)          AS daily_gmv 
  FROM phonepe.payments s
  JOIN festivals f
    ON s.`date` BETWEEN f.start_date AND f.end_date
  GROUP BY f.festival_name, s.`date`, s.city_tier
),

ranked AS (
  SELECT
    festival_name,
    `date`,
    city_tier,
    daily_gmv,
    RANK() OVER (
      PARTITION BY festival_name,year(date), city_tier
      ORDER BY daily_gmv DESC
    )                              AS gmv_rank
  FROM daily_gmv
),

peak_dates AS (
  SELECT
    festival_name,
    city_tier,
    `date`                         AS peak_date
  FROM ranked
  WHERE gmv_rank = 1
)

-- Final comparison: Tier1 vs Tier2 vs Tier3 lag
SELECT
  t1.festival_name,
  t1.peak_date                     AS tier1_peak,
  t2.peak_date                     AS tier2_peak,
  t3.peak_date                     AS tier3_peak,
  DATEDIFF(t2.peak_date, t1.peak_date)
                                   AS tier2_lag_days,
  DATEDIFF(t3.peak_date, t1.peak_date)
                                   AS tier3_lag_days
FROM peak_dates t1
JOIN peak_dates t2
  ON t1.festival_name = t2.festival_name
  AND t2.city_tier = 'Tier2'
JOIN peak_dates t3
  ON t1.festival_name = t3.festival_name
  AND t3.city_tier = 'Tier3'
WHERE t1.city_tier = 'Tier1'
ORDER BY t1.festival_name 
-- Tier 2 and Tier 3 cities shows a lag of 2 days in reaching Peak compared to Tier 1 in Diwali 
-- Tier 3 cities consistently peak 2 days after Tier 1 cities on single-peak festivals like Diwali and Raksha Bandhan —
-- suggesting PhonePe can run a second targeted campaign wave for non-metro users 48 hours after the metro launch