-- Focusing on lowest order count helps flag disengaged customers for follow-up.
SELECT TOP 3
    dc.customer_number,
    dc.first_name,
    dc.last_name,
    COUNT(DISTINCT fs.order_number) AS total_number_of_orders
FROM gold.dim_customers AS dc
INNER JOIN gold.fact_sales AS fs
ON dc.customer_key = fs.customer_key
GROUP BY dc.customer_number, dc.first_name, dc.last_name
ORDER BY total_number_of_orders ASC;
