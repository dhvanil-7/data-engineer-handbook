-- Query to deduplicate using row_number window function game_details records
with dedup_game_details as (
	select
		*,
		row_number() over(partition by game_id, team_id, player_id) as rn
	from game_details 
)

-- selecting row number=1 for unique records
select
	*
from dedup_game_details
where rn=1;