-- Filtering null dates prevents calendar gaps in time-series aggregation.
SELECT
    year(order_date) AS order_year,
    month(order_date) AS order_month,
    SUM(sales_amount) AS total_revenue,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantities
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY  year(order_date), month(order_date)
ORDER BY year(order_date), month(order_date) DESC;
