-- Query to convert device_activity_datelist to device_activity_dateint
-- This query helps to track device activity in a month.


-- CTE to check device activity based on device_activity_datelist 
WITH device_activity_tracker AS (
	    SELECT udd.device_activity_datelist @> ARRAY [DATE(d.valid_date)]   AS is_active,
	           EXTRACT(
	               DAY FROM DATE('2023-01-31') - d.valid_date) AS days_since,
	           udd.user_id,
	           udd.browser_type
	    FROM user_devices_cumulated udd
	     CROSS JOIN
	        (select
	         	generate_series('2023-01-31'::date- interval '32 day', '2023-01-31', INTERVAL '1 day') AS valid_date
	     	) as d
),

-- CTE to generate dateint as 32 bits format
-- 32 bit represents activity as 0 or 1 for 32 days
-- datelist_int represents last 32 days activity by bit value 0 or 1
     bits AS (
         SELECT user_id,
                browser_type,
                SUM(CASE
                        WHEN is_active THEN POW(2, 31 - days_since)
                        ELSE 0 END)::bigint::bit(32) AS datelist_int
         FROM device_activity_tracker
         GROUP BY user_id, browser_type
     )

-- Query to fetch all required columns from bits CTE
SELECT
       user_id,
       browser_type,
       datelist_int
FROM bits;
