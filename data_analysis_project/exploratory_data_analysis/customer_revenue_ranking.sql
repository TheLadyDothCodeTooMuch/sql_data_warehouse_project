-- Customer ranking supports loyalty programs and revenue concentration analysis.
SELECT
    dc.customer_number,
    dc.first_name,
    dc.last_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.dim_customers AS dc
INNER JOIN gold.fact_sales AS fs
ON dc.customer_key = fs.customer_key
GROUP BY dc.customer_number, dc.first_name, dc.last_name
ORDER BY total_sales DESC;
