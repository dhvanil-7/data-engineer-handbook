create type films as (
	film text,
	votes integer,
	rating real,
	filmid text);

	
create type quality as ENUM('star', 'good', 'average', 'bad');


create table if not exists actors (
	actor text,
	actorid text,
	films text,
	quality_class quality,
	is_active bool,
	current_year integer,
	primary key(actorid, current_year)
	);