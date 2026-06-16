/*
===============================================================================
QUERY 12: Event Leaderboard Ranking and Winner Identification
===============================================================================

DESCRIPTION
Identify the top three positions for each event based on participants'
best scores.

The solution handles ties by assigning ranks using DENSE_RANK() and
returns all participants sharing the same position as a comma-separated list.

OUTPUT
- Event ID
- First Place Winner(s)
- Second Place Winner(s)
- Third Place Winner(s)

BUSINESS REQUIREMENT
For each event:
1. Determine each participant's highest score.
2. Rank participants based on their best score.
3. Handle ties appropriately.
4. Display winners for the top three ranks.
5. Show tied participants together in the same position.

SQL CONCEPTS USED
- Common Table Expressions (CTEs)
- Aggregations
- MAX()
- DENSE_RANK()
- Window Functions
- STRING_AGG()
- Conditional Aggregation
- Ranking Logic

APPROACH
1. Calculate each participant's best score per event.
2. Rank participants within each event using DENSE_RANK().
3. Aggregate participants belonging to the same rank.
4. Pivot rankings into First, Second, and Third Place columns.

BUSINESS APPLICATIONS
- Competition Leaderboards
- Tournament Rankings
- Employee Performance Rankings
- Sales Competitions
- Academic Scoreboards
*/

WITH best_scores AS
(SELECT
	event_id,
	participant_name,
	MAX(score) AS best_score
FROM
	scoretable
GROUP BY
	event_id,
	participant_name),

ranked_participants AS
(SELECT
	event_id,
	participant_name,
	best_score,
	DENSE_RANK() OVER(PARTITION BY event_id ORDER BY best_score DESC) AS ranking
FROM
	best_scores)

SELECT
	event_id,
	-- COUNT(participant_name)
	STRING_AGG(CASE WHEN ranking = 1 THEN participant_name END, ', ') WITHIN GROUP(ORDER BY participant_name) AS first_place,
	STRING_AGG(CASE WHEN ranking = 2 THEN participant_name END, ', ') WITHIN GROUP(ORDER BY participant_name) AS second_place,
	STRING_AGG(CASE WHEN ranking = 3 THEN participant_name END, ', ') WITHIN GROUP(ORDER BY participant_name) AS third_place
FROM
	ranked_participants
WHERE
	ranking <= 3
GROUP BY
	event_id
ORDER BY
	event_id;