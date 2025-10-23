-- Categories with exceptionally high costs may require supplier negotiation.
SELECT
    category,
    avg(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;
