-- Categories with too few products might be candidates for merging.
SELECT
    category,
    COUNT(DISTINCT product_name) AS no_of_categories
FROM gold.dim_products
GROUP BY category
ORDER BY no_of_categories DESC;
