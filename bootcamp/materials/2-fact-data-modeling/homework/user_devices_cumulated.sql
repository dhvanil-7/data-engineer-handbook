-- DDL for user_devices_cumulated table
-- This table has an array column of date type named device_activity_datelist
-- device_activity_datelist has all dates where the device is active
-- Record is identified by composite columns: user_id, browser_type

create table if not exists user_devices_cumulated (
	user_id numeric,
	browser_type text,
	device_activity_datelist date[],
	primary key (user_id, browser_type)
);