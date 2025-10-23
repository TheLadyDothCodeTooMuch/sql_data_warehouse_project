-- Sorting by descending order highlights top-performing markets for expansion focus.
SELECT
    country,
    COUNT(DISTINCT customer_key) AS no_of_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY no_of_customers DESC;
