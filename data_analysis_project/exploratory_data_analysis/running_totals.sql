-- Window function transforms static yearly data into trend progression.
SELECT
    order_year,
    total_revenue,
    SUM(total_revenue) OVER(ORDER BY order_year) AS running_sales
FROM (
SELECT
    DATETRUNC(year, order_date) AS order_year,
    SUM(sales_amount) AS total_revenue
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(year, order_date)
) AS t 
ORDER BY order_year;
