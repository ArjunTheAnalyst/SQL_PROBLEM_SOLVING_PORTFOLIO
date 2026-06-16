/* ============================================================
   QUERY 03: Customer Orders Data Cleaning & Standardization

   OBJECTIVE
   Clean and standardize raw customer order data by:

   - Fixing inconsistent customer names
   - Handling missing email values
   - Standardizing order dates
   - Normalizing product names
   - Converting quantity values into numeric format
   - Cleaning price values
   - Standardizing country names
   - Standardizing order status values
   - Removing duplicate customer records

   SQL CONCEPTS USED
   - Common Table Expressions (CTEs)
   - CASE Expressions
   - String Manipulation Functions
   - COALESCE()
   - CAST()
   - ROW_NUMBER()
   - Data Standardization
   - Data Deduplication

   BUSINESS VALUE
   Produces a clean and analysis-ready customer dataset
   that can be reliably used for reporting, dashboarding,
   customer analytics, and downstream business processes.
============================================================ */

WITH cleaned_orders AS
(SELECT
	
	order_id AS Order_ID,

	-- CLEAN CUSTOMER NAME
	CASE
		WHEN customer_name LIKE 'Null' THEN NULL
	
		WHEN 
			CHARINDEX(' ', TRIM(customer_name)) = 0 THEN 
			UPPER(LEFT(TRIM(customer_name), 1)) 
			+ 
			LOWER(SUBSTRING(TRIM(customer_name), 2, LEN(TRIM(customer_name))))
	
		ELSE 
			UPPER(LEFT(TRIM(customer_name), 1)) 
			+ 
			LOWER(
				SUBSTRING(TRIM(customer_name), 2, CHARINDEX(' ', TRIM(customer_name)) - 1)
				)
			+
			UPPER(
				SUBSTRING(TRIM(customer_name), CHARINDEX(' ', TRIM(customer_name)) + 1, 1)
				)
			+
			LOWER(
				SUBSTRING(TRIM(customer_name), CHARINDEX(' ', TRIM(customer_name)) + 2, LEN(TRIM(customer_name)))
				)
	END AS Customer_Name,

	
	-- HANDLE MISSING EMAIL VALUES
	COALESCE(email, 'NOT AVAILABLE') AS Email,


	-- STANDARDIZE ORDER DATE
	CAST(order_date AS DATE) AS Order_Date,


	-- STANDARDIZE PRODUCT NAMES
	CASE
		WHEN product_name LIKE 'NULL' then NULL
		WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
		WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsunng Galaxy S22'
		WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
		WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
		WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'iPhone 14'
		ELSE 'Other'
	END Product_Name,


	-- STANDARDIZE QUANTITY
	CAST(REPLACE(quantity, 'two', 2) AS INT) AS Qunatity,


	-- STANDARDIZE PRICE
	COALESCE(
	CAST(ROUND(REPLACE(REPLACE(price, '$', ''), ',', ''), 0) AS INT), 0) AS Price,


	-- STANDARDIZE COUNTRY NAMES
	CASE
		WHEN LOWER(country) LIKE '%us%' THEN 'United States'
		WHEN LOWER(country) LIKE '%united states%' THEN 'United States'
		WHEN LOWER(country) LIKE '%uk%' THEN 'United Kingdom'
		WHEN LOWER(country) LIKE '%united kingdom%' THEN 'United Kingdom'
		WHEN LOWER(country) LIKE '%cana%' THEN 'Canada'
		WHEN LOWER(country) LIKE '%spa%' THEN 'Spain'
		WHEN LOWER(country) LIKE '%ind%' THEN 'India'
		ELSE 'Other'
	END AS Country,


	-- STNADARDIZE ORDER STATUS
	CASE
		WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
		WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
		WHEN LOWER(order_status) LIKE '%refund%' THEN 'Refunded'
		WHEN LOWER(order_status) LIKE '%pend%' THEN 'Pending'
		WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
	ELSE 'Other'
	END AS Order_Status
FROM
	customer_orders),

deduplicated_orders AS
(SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY Customer_Name, Email ORDER BY Order_ID) AS RN
FROM
	cleaned_orders)

SELECT
	Order_ID,
	Customer_Name,
	Email,
	Order_Date,
	Qunatity,
	Price,
	Country,
	Order_Status
FROM
	deduplicated_orders
WHERE
	RN = 1
ORDER BY
	Order_ID;