-- Gender-based segmentation can reveal imbalance or target bias.
SELECT
    gender,
    COUNT(DISTINCT customer_key) AS no_of_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY no_of_customers DESC;
