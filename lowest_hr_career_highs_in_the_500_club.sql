--Querying the Lahman Baseball Database in Postgres
WITH player_stats_aggregated_by_year AS (
	SELECT
		SUM("HR"::INT) AS home_runs,
		"playerID",
		"yearID"
	FROM "Batting"
	GROUP BY "playerID", "yearID"
), career_statistics AS (
	SELECT
		SUM(home_runs) AS career_home_runs,
		"playerID"
	FROM player_stats_aggregated_by_year
	GROUP BY "playerID"
), players_with_over_500_home_runs AS (
	SELECT
		ROW_NUMBER() OVER(ORDER BY career_home_runs DESC) AS career_rank,
		*
	FROM career_statistics
	WHERE career_home_runs >= 500
), seasons_ranked_by_home_runs AS (
	SELECT
		ROW_NUMBER() OVER(PARTITION BY "playerID" ORDER BY home_runs DESC) AS season_ranked,
		*
	FROM player_stats_aggregated_by_year
), career_high_seasons_for_players_with_over_500_home_runs AS (
	SELECT
		*
	FROM seasons_ranked_by_home_runs
	WHERE season_ranked = 1
	AND "playerID" IN (
		SELECT
			"playerID"
		FROM players_with_over_500_home_runs
	)
)
SELECT
	career_high_seasons_for_players_with_over_500_home_runs.*,
	CONCAT("People"."nameFirst", ' ', "People"."nameLast"),
	players_with_over_500_home_runs.career_home_runs,
	players_with_over_500_home_runs.career_rank
FROM career_high_seasons_for_players_with_over_500_home_runs
INNER JOIN players_with_over_500_home_runs ON players_with_over_500_home_runs."playerID" = career_high_seasons_for_players_with_over_500_home_runs."playerID"
INNER JOIN "People" ON "People"."playerID" = career_high_seasons_for_players_with_over_500_home_runs."playerID"
ORDER BY home_runs ASC
