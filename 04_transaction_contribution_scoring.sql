/* ============================================================
   QUERY 04: Transaction Contribution Scoring

   OBJECTIVE
   Calculate a weighted transaction score for each customer
   based on transaction type and status during a specified
   reporting period.

   BUSINESS RULES

   BUY Transactions
   - Completed BUY transactions contribute 100%
     of the transaction amount.

   SELL Transactions
   - Completed SELL transactions contribute 10%
     of the transaction amount.

   Cancelled Transactions
   - Cancelled BUY transactions reduce the score
     by 1% of the transaction amount.
   - Cancelled SELL transactions reduce the score
     by 1% of the transaction amount.

   Pending Transactions
   - Ignored entirely.

   OUTPUT
   - Customer
   - BUY Contribution
   - SELL Contribution
   - Total Contribution Score

   SQL CONCEPTS USED
   - Common Table Expressions (CTEs)
   - Conditional Aggregation
   - CASE Expressions
   - SUM()
   - ROUND()
   - Business Rule Implementation

   BUSINESS VALUE
   Demonstrates how SQL can be used to translate
   complex transaction weighting rules into
   customer-level performance metrics.

============================================================ */

WITH totals AS
(SELECT
	customer,
	ROUND(
	SUM(CASE 
		WHEN type LIKE 'BUY' AND status LIKE 'COMPLETED' THEN CAST(amount AS FLOAT)
		WHEN type LIKE 'BUY' AND status LIKE 'CANCELED' THEN CAST(amount AS FLOAT) * - 0.01
	ELSE 0
	END), 2) AS buy_amt,

	ROUND(
	SUM(CASE
		WHEN type LIKE 'SELL' AND status LIKE 'COMPLETED' THEN CAST(amount AS FLOAT) * 0.10
		WHEN type LIKE 'SELL' AND status LIKE 'CANCELED' THEN CAST(amount AS FLOAT) * - 0.01
	ELSE 0
	END), 2) AS sell_amt
FROM
	transactions
WHERE
	MONTH(dt) = 7
GROUP BY
	customer)

SELECT
	*,
	ROUND(buy_amt + sell_amt, 2) AS total
FROM
	totals
ORDER BY
	total DESC;