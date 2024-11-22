CREATE TABLE actors_history_scd (
	actor text,
	actorid text,
	quality_class quality,
	is_active bool,
	start_date date,
	end_date date,
	current_year int4,
	CONSTRAINT actors_history_scd_pkey PRIMARY KEY (actorid, start_date)
);