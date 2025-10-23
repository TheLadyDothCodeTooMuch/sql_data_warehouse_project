-- Ascending sort highlights underperformers rather than bestsellers.
SELECT TOP 5
    dp.product_number,
    dp.product_name,
    SUM(sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
INNER JOIN gold.dim_products AS dp
ON fs.product_key = dp.id
GROUP BY dp.product_number, product_name
ORDER BY total_revenue ASC;
