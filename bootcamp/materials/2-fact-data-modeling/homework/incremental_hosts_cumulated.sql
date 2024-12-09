-- Incremental query to generate hosts_cumulated

-- Fetch events data for current date
with curr_hosts as (
	select 
		host,
		min(event_time):: date as date
	from events
	where user_id is not null
		and event_time::date = '2023-01-10'
	group by host
),

-- CTE to fetch previous day records from hosts_cumulated
	prev_hosts as (
	select
		*
	from hosts_cumulated
	where date = (
                    select
                        date - interval '1 day'
                    from curr_hosts
                    limit 1
                )
),

-- CTE to join current day and previous day records

	aggregated_hosts_cumulated as (
		select 
			coalesce(ch.host, ph.host) as host,
			case
				when ch.date is null
					then ph.host_activity_datelist
				else 
					array_cat(array[ch.date], ph.host_activity_datelist)
			end as host_activity_datelist,
			coalesce(ch.date, ph.date + interval '1 day')::date as date
		from curr_hosts ch
		full join prev_hosts ph
		on ch.host = ph.host
)


-- query to insert data into hosts_cumulated and update values on conflict
insert into hosts_cumulated
select * from aggregated_hosts_cumulated
on conflict (host, date)
do update
	set host_activity_datelist = excluded.host_activity_datelist;
