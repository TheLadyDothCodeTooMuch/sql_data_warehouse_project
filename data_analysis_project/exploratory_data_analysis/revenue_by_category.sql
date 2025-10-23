-- Left join ensures that even categories with zero sales appear for full visibility.
SELECT
    dp.category,
    sum(fs.sales_amount) AS total_revenue
FROM gold.dim_products AS dp
LEFT JOIN gold.fact_sales AS fs
ON dp.id = fs.product_key
GROUP BY dp.category;
