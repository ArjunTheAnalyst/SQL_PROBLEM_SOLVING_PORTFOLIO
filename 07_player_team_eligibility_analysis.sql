/* ============================================================
   QUERY 07: Player Team Eligibility Analysis

   OBJECTIVE
   Identify players who are eligible to join a team
   based on historical performance criteria.

   ELIGIBILITY RULES

   A player is eligible only if:

   - They have previously played for the team.
   - Their total wins exceed their total losses
     while representing that team.

   METRICS CALCULATED
   - Total Matches Won
   - Total Matches Lost
   - Eligibility Status

   APPROACH

   Step 1:
   Join player records with historical game data.

   Step 2:
   Calculate total wins and total losses for
   each player.

   Step 3:
   Compare wins against losses.

   Step 4:
   Return players who satisfy the eligibility
   criteria.

   SQL CONCEPTS USED
   - Common Table Expressions (CTEs)
   - INNER JOIN
   - Conditional Aggregation
   - COUNT()
   - CASE Expressions
   - Business Rule Implementation

   BUSINESS VALUE
   Demonstrates how SQL can be used to enforce
   performance-based eligibility criteria and
   support decision-making using historical data.

============================================================ */

WITH wins_and_losses AS
(SELECT
	Games.Pid,
	Player.Pname,
	COUNT(CASE
		WHEN [Status] LIKE 'WON'
		THEN 1
		ELSE NULL END) AS Total_Wins,
	
	COUNT(CASE
		WHEN [Status] LIKE 'LOST'
		THEN 1
		ELSE NULL END) AS Total_Losses
FROM
	Games
INNER JOIN
	Player
ON
	Games.Pid = Player.Pid
AND
	Games.Team_Name = Player.Team_Name
GROUP BY
	Games.Pid,
	Player.Pname)

SELECT
	Pname
FROM
	wins_and_losses
WHERE
	Total_Wins > Total_Losses
ORDER BY
	Pname;
