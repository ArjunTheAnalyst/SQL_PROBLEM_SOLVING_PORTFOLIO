/*
===============================================================================
QUERY 11: Suspicious Transaction Sequence Detection
===============================================================================

DESCRIPTION
Identify suspicious transaction sequences where the same sender performs
multiple transactions within a short time period.

A sequence is defined as consecutive transactions made by the same sender
with no gap greater than 60 minutes between transactions.

RISK CRITERIA
- At least 2 transactions in a sequence
- Total sequence amount >= 150

OUTPUT
- Sender
- Sequence Start Time
- Sequence End Time
- Transaction Count
- Total Transaction Amount

SQL CONCEPTS USED
- Common Table Expressions (CTEs)
- LAG()
- Window Functions
- Running Totals
- Sequence Detection
- Conditional Logic
- Aggregations

BUSINESS APPLICATIONS
- Fraud Detection
- Transaction Monitoring
- AML Analytics
- Risk Management
*/

WITH previous_transactions AS
(SELECT
	sender,
	dt,
	amount,
	LAG(dt) OVER(PARTITION BY sender ORDER BY dt) AS previous_transaction_time
FROM
	transactions),

sequence_start_points AS
(SELECT
	sender,
	dt,
	amount,
	previous_transaction_time,

	-- FLAG 1: START A NEW SEQUENCE
	-- FLAG 0: CONTINUE THE CURRENT SEQUENCE
	CASE
		WHEN previous_transaction_time IS NULL THEN 1 -- FIRST TRANSACTION -> START A NEW SEQUENCE
		WHEN DATEDIFF(MINUTE, previous_transaction_time, dt) > 60 THEN 1 -- GAP BETWEEN TRANSACTIONS GREATER THAN 60 MINS -> START A NEW SEQUENCE
		ELSE 0 -- TRANSACTION BELONGS TO THE SAME SEQUENCE
		END AS is_sequence_start
FROM
	previous_transactions),

transaction_sequences AS
(SELECT
	sender,
	dt,
	amount,
	previous_transaction_time,
	is_sequence_start,


	/*
	CREATE A RUNNING TOTAL OF is_sequence_start TO GENERATE SEQUENCE IDs
	1. EACH TIME is_sequence_start = 1, SEQUENCE ID INCREASES BY 1
	2. EACH TIME is_sequence_start = 0, SEQUENCE ID REMAINS THE SAME
	*/
	SUM(is_sequence_start) OVER(PARTITION BY sender ORDER BY dt) AS sequence_id
FROM
	sequence_start_points)

SELECT
	sender,
	MIN(dt) AS sequence_start_time,
	MAX(dt) AS sequence_end_time,
	COUNT(amount) AS txn_cnt,
	SUM(amount) AS txn_amt
FROM
	transaction_sequences
GROUP BY
	sender,
	sequence_id
HAVING
	COUNT(amount) >= 2
AND
	SUM(amount) >= 150
ORDER BY
	sender,
	sequence_start_time,
	sequence_end_time;