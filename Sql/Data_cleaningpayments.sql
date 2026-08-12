use phonepe;
select count( * )from payments;
describe payments;
-- Checking null rows 
SELECT
  SUM(CASE WHEN date                      IS NULL THEN 1 ELSE 0 END) AS null_date,
  SUM(CASE WHEN city                      IS NULL THEN 1 ELSE 0 END) AS null_city,
  SUM(CASE WHEN city_tier                  IS NULL THEN 1 ELSE 0 END) AS null_tier,
  SUM(CASE WHEN category                   IS NULL THEN 1 ELSE 0 END) AS null_category,
  SUM(CASE WHEN festival_name               IS NULL THEN 1 ELSE 0 END) AS null_festival,
  SUM(CASE WHEN surge_intensity             IS NULL THEN 1 ELSE 0 END) AS null_surge,
  SUM(CASE WHEN transaction_count           IS NULL THEN 1 ELSE 0 END) AS null_txn_count,
  SUM(CASE WHEN avg_transaction_amount_inr  IS NULL THEN 1 ELSE 0 END) AS null_avg_amt,
  SUM(CASE WHEN total_gmv_inr               IS NULL THEN 1 ELSE 0 END) AS null_gmv,
  SUM(CASE WHEN is_weekend                  IS NULL THEN 1 ELSE 0 END) AS null_weekend,
  SUM(CASE WHEN is_month_start              IS NULL THEN 1 ELSE 0 END) AS null_monthstart
FROM payments;
-- Each combination of date+city+category should appear exactly once
SELECT
  date,city,category,COUNT(*) AS occurrences
FROM payments
GROUP BY date, city, category
HAVING COUNT(*) > 1;

-- Check if any city name has leading/trailing spaces hiding
SELECT DISTINCT city, LENGTH(city) AS len, LENGTH(TRIM(city)) AS trimmed_len
FROM payments
WHERE LENGTH(city) != LENGTH(TRIM(city));

-- Check the date range — should be 2022-09-01 to 2023-12-31
SELECT
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date,
  COUNT(DISTINCT date) AS total_unique_dates
FROM payments;

-- Check if any date values are outside expected range
SELECT COUNT(*) AS out_of_range_dates
FROM payments
WHERE date < '2022-09-01' OR date > '2023-12-31';

-- Check if is_weekend only contains 0 or 1
SELECT DISTINCT is_weekend FROM payments;

-- Same check for is_month_start
SELECT DISTINCT is_month_start FROM payments;



