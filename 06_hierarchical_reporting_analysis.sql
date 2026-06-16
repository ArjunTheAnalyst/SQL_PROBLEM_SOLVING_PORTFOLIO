/* ============================================================
   QUERY 06: Hierarchical Reporting Analysis

   OBJECTIVE
   Generate a hierarchical summary showing each ruler,
   the number of subordinates they manage, and a
   consolidated list of subordinate names.

   METRICS CALCULATED
   - Total Subordinates per Ruler
   - Ordered List of Descendants

   APPROACH

   Step 1:
   Join rulers with their corresponding subordinates.

   Step 2:
   Count the number of subordinates assigned to
   each ruler.

   Step 3:
   Concatenate subordinate names into a single
   ordered hierarchy string using STRING_AGG().

   SQL CONCEPTS USED
   - LEFT JOIN
   - GROUP BY
   - COUNT()
   - STRING_AGG()
   - Ordered Aggregation
   - Hierarchical Reporting

   BUSINESS VALUE
   Demonstrates how SQL can be used to summarize
   hierarchical relationships and transform
   row-level data into management-friendly reports.

============================================================ */

SELECT
	Rulers.RulerID,
	Rulers.RulerName,
	COUNT(Subordinates.SubordinateID) AS Subordinate_Count,
	STRING_AGG(Subordinates.SubordinateName, ' -> ') WITHIN GROUP (ORDER BY Subordinates.SubordinateName) AS Descendants
FROM
	Rulers
LEFT JOIN
	Subordinates
ON
	Rulers.RulerID = Subordinates.RulerID
GROUP BY
	Rulers.RulerID,
	Rulers.RulerName;