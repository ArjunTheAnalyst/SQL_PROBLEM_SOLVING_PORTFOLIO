/*
============================================================
QUERY 01: POLL WINNER PAYOUT DISTRIBUTION
============================================================

BUSINESS PROBLEM
------------------------------------------------------------
A polling platform allows users to stake money on
different poll options.

After the winning option is determined, all money
wagered on losing options is redistributed among
the winning users in proportion to their stake size.

OBJECTIVE
------------------------------------------------------------
Calculate:

1. Each winning user's original stake
2. Their proportion of the winning pool
3. Their share of the losing pool
4. Their final payout amount

BUSINESS RULES
------------------------------------------------------------
- Users who selected the winning option receive
  their original stake back.

- The total amount wagered on losing options is
  redistributed among winning users.

- Redistribution is proportional to the size of
  each user's winning stake.

FORMULA
------------------------------------------------------------
Stake Proportion
=
User Winning Stake
/
Total Winning Stakes

Winning Payout
=
Winning Stake
+
(Stake Proportion × Total Losing Stakes)

SQL CONCEPTS DEMONSTRATED
------------------------------------------------------------
- Common Table Expressions (CTEs)
- Conditional Aggregation
- SUM()
- CROSS JOIN
- Financial Calculations
- Proportional Allocation Logic

============================================================
*/

WITH payout_pool AS
(
-- CALCULATE TOTAL WINNING AND LOSING POOLS
SELECT
	SUM(CASE WHEN poll_option_id LIKE 'C' THEN amount ELSE 0 END) AS winning_option_total,
	SUM(CASE WHEN poll_option_id in ('A', 'B', 'D') THEN amount ELSE 0 END) AS losing_options_total
FROM
	poll_results),

winner_proportions AS
(
-- CALCULATE EACH WINNER'S SHARE OF THE WINNING POOL
SELECT
	[user_id],
	amount AS winning_stake,
	amount / CAST(winning_option_total AS FLOAT) AS stake_proportion,
	losing_options_total
FROM
	poll_results
CROSS JOIN
	payout_pool
WHERE
	poll_option_id LIKE 'C')

-- CALCULATE FINAL PAYOUT
SELECT
	[user_id],
	winning_stake,
	winning_stake + (stake_proportion * losing_options_total) AS winning_payout
FROM
	winner_proportions
ORDER BY
	winning_payout DESC;