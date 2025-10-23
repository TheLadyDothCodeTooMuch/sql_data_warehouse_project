-- Indicates demand concentration that affects shipping priorities.
SELECT
    dc.country,
    SUM(fs.quantity) AS total_sold_items
FROM gold.dim_customers AS dc
INNER JOIN gold.fact_sales AS fs
ON dc.customer_key = fs.customer_key
GROUP BY dc.country
ORDER BY total_sold_items DESC;
