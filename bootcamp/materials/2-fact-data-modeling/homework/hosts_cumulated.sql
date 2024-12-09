-- DDL for table hosts_cumulated
-- host_activity_datelist is a date array which tracks activity on host for all dates

create table if not exists hosts_cumulated (
	host text,
	host_activity_datelist date[],
	date date,
 primary key (host, date)
);