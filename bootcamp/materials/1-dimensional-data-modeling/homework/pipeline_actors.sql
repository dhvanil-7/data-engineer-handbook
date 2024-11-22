create or replace procedure populate_actors (year_input int)
language SQL
as $$
	with prev_year as (
		select *
		from actors
		where current_year = year_input-1 ),
        curr_year as (
            select
                actor,
                actorid,
                array_agg(row(film, votes, rating, filmid)) as films,
                case
                    when avg(rating) > 8 then 'star'
                    when avg(rating) > 7 then 'good'
                    when avg(rating) > 6 then 'average'
                    else 'bad'
                end as quality_class
            from actor_films
            where year = year_input
            group by actor, actorid
        )
	
	insert into actors
	select
		coalesce (cy.actor, py.actor) as actor,
		coalesce (cy.actorid, py.actorid) as actorid,
		case
			when py.films is null then cy.films::text[]
			else py.films::text[] || cy.films::text[]
		end as films,
		coalesce(cy.quality, py.quality_class)::quality as quality_class,		
		case when cy.actor is null then false
			else true
			end as is_active,
		year_input as current_year
	from prev_year as py
	full outer join curr_year as cy
	on py.actorid = cy.actorid
$$;