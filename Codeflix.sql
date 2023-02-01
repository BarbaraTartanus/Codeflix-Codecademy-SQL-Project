--Checking the data and table structure
SELECT * 
FROM subscriptions
LIMIT 10;

--Checking the time period in our data
SELECT 
MIN(subscription_start) AS 'start date',
MAX(subscription_start) AS 'end date'
FROM subscriptions;

--Buliding the months table
WITH months AS (
SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
UNION
SELECT 
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
UNION
SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
cross_join AS --Adding the cross join table
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS --Adding the status table with 4 cases (active and canceled status for both segments - 30 and 87)
(SELECT id, first_day as month,
CASE
  WHEN (subscription_start < first_day) AND ( subscription_end > first_day
  OR subscription_end is NULL) AND (segment = 87) THEN 1
  ELSE 0
END AS is_active_87,
CASE
  WHEN (subscription_start < first_day) AND ( subscription_end > first_day
  OR subscription_end is NULL) AND (segment = 30) THEN 1
  ELSE 0
END AS is_active_30,
CASE 
  WHEN (subscription_end BETWEEN first_day AND last_day)
    AND (segment = 87) THEN 1
  ELSE 0
END AS is_canceled_87,
CASE 
  WHEN (subscription_end BETWEEN first_day AND last_day)
    AND (segment = 30) THEN 1
  ELSE 0
END AS is_canceled_30
FROM cross_join),
status_aggregate AS --Adding the aggragate table where we sum up all active and cancelled users by month
(SELECT month,
SUM(is_active_87) as sum_active_87,
SUM(is_active_30) as sum_active_30,
SUM(is_canceled_87) as sum_canceled_87,
SUM(is_canceled_30) as sum_canceled_30
FROM status
GROUP BY month)

--Calculate the churn rate for each month

SELECT 
month, 
1.0 * sum_canceled_87 / sum_active_87 AS churn_rate_87,
1.0 * sum_canceled_30 / sum_active_30 AS churn_rate_30
FROM status_aggregate;

--Portfolio Question: How would you modify this code to support a large number of segments?
--By also selecting the segment column in the cross_join table and removing the part checking for segment from the CASE section. 
--Under the status_aggregare table we could group by segment additionally to the month and would see the same result

