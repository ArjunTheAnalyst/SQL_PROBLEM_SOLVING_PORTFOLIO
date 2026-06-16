/* ============================================================
   QUERY 05: Student Attendance Improvement Analysis

   OBJECTIVE
   Identify students whose attendance percentage
   improved compared to the previous month.

   METRICS CALCULATED
   - Monthly Attendance Percentage
   - Previous Month Attendance Percentage
   - Month-over-Month Attendance Improvement

   APPROACH

   Step 1:
   Calculate attendance percentage for each
   student by month.

   Attendance Percentage =
   Present Days / Total Attendance Records × 100

   Step 2:
   Retrieve the previous month's attendance
   percentage using the LAG() window function.

   Step 3:
   Compare current and previous month
   attendance percentages.

   Step 4:
   Count students whose attendance improved.

   SQL CONCEPTS USED
   - Common Table Expressions (CTEs)
   - Conditional Aggregation
   - Window Functions
   - LAG()
   - Percentage Calculations
   - Trend Analysis

   BUSINESS VALUE
   Enables educational institutions to monitor
   attendance trends and identify students
   demonstrating improved engagement over time.

============================================================ */

WITH monthly_attendance AS
(SELECT
	student_id,
	FORMAT(attendance_date, 'MM: MMM') AS current_month,
	(
	COUNT(CASE WHEN status LIKE 'Present' THEN 1 ELSE NULL END)
	/
	CAST(
	COUNT(status) AS FLOAT)
	) * 100 AS current_month_attendance_percentage
FROM
	Attendance
GROUP BY
	student_id,
	FORMAT(attendance_date, 'MM: MMM')),

attendance_comparison AS
(SELECT
	*,
	LAG(current_month_attendance_percentage) OVER(PARTITION BY student_id ORDER BY current_month) AS previous_month_attendance_percentage
FROM
	monthly_attendance)

SELECT
	COUNT(student_id) AS students_with_improved_attendance
FROM
	attendance_comparison
WHERE
	current_month_attendance_percentage > previous_month_attendance_percentage;