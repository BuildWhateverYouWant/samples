WITH player_stats_aggregated_by_year AS (
	SELECT
		SUM("HR"::INT) AS home_runs,
		"yearID",
		"playerID"
	FROM "Batting"
	GROUP BY "playerID", "yearID"
), seasons_ranked_by_player AS (
	SELECT
		ROW_NUMBER() OVER (PARTITION BY "playerID" ORDER BY home_runs DESC) AS home_run_rank,
		"playerID",
		"yearID",
		home_runs
	FROM player_stats_aggregated_by_year
	WHERE home_runs IS NOT NULL
), difference_between_top_two_seasons_with_most_home_runs AS (
	SELECT
		seasons_with_most_home_runs.home_runs - seasons_with_2nd_most_home_runs.home_runs AS difference,
		seasons_with_most_home_runs.home_runs AS most_home_runs_in_a_season,
		seasons_with_most_home_runs."yearID" AS year_with_most_home_runs,
		seasons_with_2nd_most_home_runs.home_runs AS second_most_home_runs_in_a_season,
		seasons_with_2nd_most_home_runs."yearID" AS year_with_second_most_home_runs, 
		seasons_with_most_home_runs."playerID"
	FROM seasons_ranked_by_player AS seasons_with_2nd_most_home_runs
	INNER JOIN seasons_ranked_by_player AS seasons_with_most_home_runs ON (
		seasons_with_most_home_runs.home_run_rank = 1
		AND seasons_with_most_home_runs."playerID" = seasons_with_2nd_most_home_runs."playerID"
	)
	WHERE seasons_with_2nd_most_home_runs.home_run_rank = 2
)
SELECT
	CONCAT("People"."nameFirst", ' ', "People"."nameLast") AS player_name,
	difference_between_top_two_seasons_with_most_home_runs.*,
	"People"."finalGame" AS final_game
FROM difference_between_top_two_seasons_with_most_home_runs
INNER JOIN "People" ON "People"."playerID" = difference_between_top_two_seasons_with_most_home_runs."playerID"
WHERE "People"."finalGame" IS NOT NULL -- Using filter to exclude active players
ORDER BY difference_between_top_two_seasons_with_most_home_runs DESC, most_home_runs_in_a_season DESC -- Using most_home_runs_in_a_season to break ties
LIMIT 10

