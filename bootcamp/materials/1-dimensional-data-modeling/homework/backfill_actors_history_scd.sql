WITH actors_history_scd AS (
	    select
	    	actor,
			actorid,
			quality_class,
			lag(quality_class, 1) over(partition by actorid order by current_year) as prev_quality_class,
			is_active,
			lag(is_active, 1) over(partition by actorid order by current_year) as prev_is_active,
			current_year		
		from actors
	    WHERE current_year <= extract(year from current_date)
    ),
    
	identified_changed_states as (	
		select
			*,
			case when (prev_quality_class <> quality_class or prev_is_active <> is_active) then 1
			else 0 end as changed_states
		from actors_history_scd
	),
	
	identified_streaks as (	
		select
			*,
			sum(changed_states) over(partition by actorid order by current_year) as streak_id
		from identified_changed_states
	),
	
	aggregated_states_data as (
		select 
			actor,
			actorid,
			quality_class,
			is_active,
			min(current_year) as start_year,
			max(current_year) as end_year
		from identified_streaks
		group by actor, actorid, quality_class, is_active, streak_id
	)
	
	
	insert into actors_history_scd
	select	
		actor,
		actorid,
		quality_class,
		is_active,
		to_date('01-01-' || start_year, 'MM-DD-YYYY') as start_date,
		to_date('12-31-' || end_year, 'MM-DD-YYYY') as end_date,
		extract(year from current_date) as current_year
	from aggregated_states_data;