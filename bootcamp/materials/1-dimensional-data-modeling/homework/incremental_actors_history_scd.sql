CREATE OR REPLACE PROCEDURE incremental_actors_scd (input_year int)
LANGUAGE SQL
AS $$
	WITH prev_year_actors AS (
	    SELECT *
	    FROM actors_history_scd
	    WHERE current_year = input_year-1
	),
	curr_year_actors AS (
	    SELECT *
	    FROM actors
	    WHERE current_year = input_year
	),
	changed_states AS (
	    SELECT
	        COALESCE(py.actor, cy.actor) AS actor,
	        COALESCE(py.actorid, cy.actorid) AS actorid,
	        cy.quality_class AS quality_class,
	        cy.is_active AS is_active,
	        TO_DATE('01-01-' || cy.current_year, 'MM-DD-YYYY') AS start_date,
	        TO_DATE('12-31-' || cy.current_year, 'MM-DD-YYYY') AS end_date,
	        cy.current_year AS current_year
	    FROM curr_year_actors AS cy
	    LEFT JOIN prev_year_actors AS py
	        ON py.actorid = cy.actorid
	    WHERE (py.quality_class <> cy.quality_class OR py.is_active <> cy.is_active)
	       OR py.actorid IS NULL
	),
	nonchanged_states as (
		SELECT
	        COALESCE(py.actor, cy.actor) AS actor,
	        COALESCE(py.actorid, cy.actorid) AS actorid,
	        cy.quality_class AS quality_class,
	        cy.is_active AS is_active,
	        COALESCE(py.start_date,TO_DATE('01-01-' || cy.current_year, 'MM-DD-YYYY')) AS start_date,
	        TO_DATE('12-31-' || cy.current_year, 'MM-DD-YYYY') AS end_date,
	        cy.current_year AS current_year
	    FROM curr_year_actors AS cy
	    LEFT JOIN prev_year_actors AS py
	        ON py.actorid = cy.actorid
	    WHERE (py.quality_class = cy.quality_class AND py.is_active = cy.is_active)
	),
	all_states_data as (
	SELECT * FROM changed_states
	UNION
	SELECT * FROM nonchanged_states)
	
	INSERT INTO actors_history_scd (actor, actorid, quality_class, is_active, start_date, end_date, current_year)
	SELECT actor, actorid, quality_class, is_active, start_date, end_date, current_year
	FROM all_states_data
	ON CONFLICT (actorid, start_date)
	DO UPDATE SET 
	    end_date = EXCLUDED.end_date,
	    current_year = EXCLUDED.current_year
$$;