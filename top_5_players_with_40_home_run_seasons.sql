WITH player_aggregate AS (
	SELECT
		SUM("HR"::INT) AS total_home_runs,
		"yearID",
		"playerID"
	FROM "Batting"
	GROUP BY "yearID", "playerID"
), number_of_seasons_with_30_home_runs_or_more AS (
	SELECT
		COUNT(*) number_of_seasons,
		"playerID"
	FROM player_aggregate
	WHERE total_home_runs >= 40
	GROUP BY "playerID"
)
SELECT
	number_of_seasons_with_30_home_runs_or_more.*,
	CONCAT("nameFirst", ' ', "nameLast") AS player_name
FROM number_of_seasons_with_30_home_runs_or_more 
INNER JOIN "People" ON number_of_seasons_with_30_home_runs_or_more."playerID" = "People"."playerID"
ORDER BY number_of_seasons DESC
LIMIT 5
