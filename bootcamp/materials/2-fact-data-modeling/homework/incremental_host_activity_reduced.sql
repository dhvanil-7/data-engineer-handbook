-- Incremental load for populating hosts_activity_reduced

-- Fetch events data for current date
with curr_hosts as (
	select 
		host,
		count(distinct event_time) as hits,
		count(distinct user_id) as unique_visitors,
		min(event_time)::date as date
	from events
	where user_id is not null
		and event_time::date = '2023-01-01'
	group by host
),

-- CTE to fetch previous day records from hosts_cumulated
prev_hosts_activity_reduced as (
	select
		*
	from hosts_activity_reduced
	where date = (
                    select
                        date - interval '1 day' as date
                    from curr_hosts
                    where month = extract(month from date)
                    limit 1
                )
          
),

--CTE to join current date statistics with previous days
hosts_activity_stats as (
	select
		coalesce(ch.host, ph.host) as host,
		coalesce(extract(month from ch.date), ph.month) as month,
		array_cat(
			coalesce(ph.hit_array,
						array_fill(0,array[extract(day from ch.date)::int - 1])),
			array[ch.hits]
		) as hit_array,
		array_cat(
			coalesce(ph.unique_visitors,
						array_fill(0,array[extract(day from ch.date)::int - 1])),
			array[ch.unique_visitors]
		) as unique_visitors,
		coalesce(ch.date, ph.date + interval '1 day')::date as date
	from curr_hosts ch
	full join prev_hosts_activity_reduced ph
	on ch.host = ph.host
)


-- Query to insert records into hosts_activity_reduced

insert into 
hosts_activity_reduced
select
	*
from hosts_activity_stats
on conflict (host, date)
do update
	set month = excluded.month,
		hit_array = excluded.hit_array,
		unique_visitors = excluded.unique_visitors;