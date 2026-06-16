/* ============================================================
   QUERY 02: SALES TREND ANALYSIS

   Objective:
   Analyze monthly sales performance for each city and year.

   Metrics Calculated:
   - Previous Month Sales
   - Current Month Sales
   - Next Month Sales
   - Year-to-Date (YTD) Sales

   Approaches Demonstrated:
   1. Self-Join Approach
      - Traditional SQL method using multiple joins
      - Useful for understanding relational logic

   2. Window Function Approach
      - Uses LAG(), LEAD(), and running totals
      - More concise and scalable solution

   Skills Demonstrated:
   - Window Functions
   - LAG()
   - LEAD()
   - Running Totals
   - Self Joins
   - Time Series Analysis
   - Year-to-Date Calculations

   Database:
   Microsoft SQL Server (T-SQL)
============================================================ */

-- APPROACH 1
WITH sales_with_ytd AS
(SELECT
	City,
	[Year],
	[Month],
	Sales,
	SUM(Sales) OVER(PARTITION BY City, [Year] ORDER BY [Month]) AS YTD_Sales
FROM 
	sales_data),

sales_with_previous_month AS
(SELECT
	current_month.City,
	current_month.[Year],
	current_month.[Month],
	current_month.Sales,
	previous_month.Sales AS Previous_Month_Sales,
	current_month.YTD_Sales
FROM
	sales_with_ytd AS current_month
LEFT JOIN
	sales_with_ytd AS previous_month
ON
	current_month.City = previous_month.City
AND
	current_month.[Year] = previous_month.[Year]
AND
	current_month.[Month] = previous_month.[Month] + 1),

sales_with_next_month AS
(SELECT
	current_month.City,
	current_month.[Year],
	current_month.[Month],
	current_month.Sales,
	next_month.Sales AS Next_Month_Sales,
	current_month.YTD_Sales
FROM
	sales_with_ytd AS current_month
LEFT JOIN
	sales_with_ytd AS next_month
ON
	current_month.City = next_month.City
AND
	current_month.[Year] = next_month.[Year]
AND
	current_month.[Month] = next_month.[Month] - 1)

SELECT
	prev.City,
	prev.[Year],
	prev.[Month],
	prev.Sales,
	prev.Previous_Month_Sales,
	nxt.Next_Month_Sales,
	prev.YTD_Sales
FROM
	sales_with_previous_month AS prev
LEFT JOIN
	sales_with_next_month AS nxt
ON
	prev.City = nxt.City
AND
	prev.[Year] = nxt.[Year]
AND
	prev.[Month] = nxt.[Month]
ORDER BY
	prev.City,
	prev.[Year],
	prev.[Month];


-- APPROACH 2
SELECT
	City,
	[Year],
	[Month],
	Sales,
	LAG(Sales) OVER(PARTITION BY City, [Year] ORDER BY [Month]) AS Previous_Month_Sales,
	LEAD(Sales) OVER(PARTITION BY City, [Year] ORDER BY [Month]) AS Next_Month_Sales,
	SUM(Sales) OVER(PARTITION BY City, [Year] ORDER BY [Month]) AS YTD_Sales
FROM
	sales_data
ORDER BY
	City,
	[Year],
	[Month];