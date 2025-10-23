-- Helps identify transactions with abnormal or duplicate order timelines.
SELECT
    order_number,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
FROM gold.fact_sales
GROUP BY order_number;
