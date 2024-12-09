-- DDL for table hosts_activity_reduced

create table if not exists hosts_activity_reduced (
	host text,
 month int,
 hit_array int[],
 unique_visitors int[],
 date date,
 primary key (host, date)
);