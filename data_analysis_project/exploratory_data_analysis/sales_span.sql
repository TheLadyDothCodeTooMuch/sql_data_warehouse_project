-- The difference between earliest and latest sales helps estimate business longevity.
SELECT
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS NoOfYears
FROM gold.fact_sales;
