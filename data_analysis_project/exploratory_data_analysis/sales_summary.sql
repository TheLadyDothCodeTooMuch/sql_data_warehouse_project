-- UNION ensures single output stream of multiple KPIs for flexible visualization layers.
SELECT
    'Total Sales:' AS measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION
SELECT
    'Total Quantity:' AS measure_name,
    COUNT(quantity) AS total_items
FROM gold.fact_sales
UNION
SELECT
   'Total No of Items:' AS measure_name,
    COUNT(DISTINCT order_number) AS no_of_orders
FROM gold.fact_sales
UNION
SELECT
    'Average Selling Price: ' AS measure_name,
    AVG(price) AS avg_selling_price
FROM gold.fact_sales
UNION
SELECT
    'No of Customers:' AS measure_name,
    COUNT(DISTINCT customer_key) AS no_of_customers
FROM gold.fact_sales;
