-- Query to populate user_devices_cumulated 
-- This query is based on a full load configuration.
-- CTE to implement row_number window function to remove duplicates
with users_devices_details as (
	select
		user_id,
		d.device_id as device_id,
		d.browser_type as browser_type,
		event_time::date as date,
		row_number() over(partition by user_id, browser_type, event_time::date) as rn
	from events e
	join devices d
	on d.device_id = e.device_id
	where user_id is not null
),

-- Selecting row number=1 provides all unique records
dedup_user_browsers as (
	select
		*
	from users_devices_details
	where rn=1
),

-- CTE to generate device_activity_datelist using array_agg
aggregated_user_browsers as (
	select
		user_id,
		browser_type,
		array_agg(date) as device_activity_datelist
	from dedup_user_browsers
	group by user_id, browser_type
)

--Query inserts records to user_devices_cumulated
insert into
user_devices_cumulated
select
	*
from aggregated_user_browsers;