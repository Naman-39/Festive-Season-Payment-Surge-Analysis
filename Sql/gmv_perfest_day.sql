CREATE VIEW festival_enriched AS
SELECT
  s.date,
  s.day_of_week,
  s.month,
  s.week_number,
  s.city,
  s.city_tier,
  s.category,
  s.festival_name,
  s.surge_intensity,
  s.transaction_count,
  s.avg_transaction_amount_inr,
  s.total_gmv_inr,
  s.is_weekend,
  s.is_month_start,

  -- Clean festival columns with no NULLs
  COALESCE(f.festival_type,    'Non-Festival') AS festival_type,
  COALESCE(f.religion_culture, 'Non-Festival') AS religion_culture,
  COALESCE(f.region_relevance, 'Pan-India')    AS region_relevance,
  COALESCE(f.notes,            'Regular day')  AS festival_notes

FROM payments s
LEFT JOIN festivals f
  ON s.festival_name = f.festival_name;

-- Verify the view works
SELECT * FROM festival_enriched LIMIT 10;
SELECT
  festival_name,
  festival_type,
  SUM(total_gmv_inr)                              AS total_festival_gmv,
  DATEDIFF(MAX(s.date), MIN(s.date)) + 1          AS festival_duration_days,
  ROUND(SUM(total_gmv_inr) /
    (DATEDIFF(MAX(s.date), MIN(s.date)) + 1), 0)  AS gmv_per_day
FROM festival_enriched s
WHERE festival_name != 'None'
GROUP BY festival_name, festival_type,YEAR(date)
ORDER BY gmv_per_day DESC;

SELECT
  festival_name,
  YEAR(`date`)                                      AS festival_year,
  CONCAT(festival_name, ' ', YEAR(`date`))          AS festival_label,
  SUM(total_gmv_inr)                                AS total_festival_gmv,
  DATEDIFF(MAX(`date`), MIN(`date`)) + 1            AS festival_duration_days,
  ROUND(
    SUM(total_gmv_inr) /
    (DATEDIFF(MAX(`date`), MIN(`date`)) + 1)
  , 0)                                              AS gmv_per_day
FROM festival_enriched
WHERE festival_name != 'None'
GROUP BY festival_name, YEAR(`date`)        -- year added here
ORDER BY gmv_per_day DESC;