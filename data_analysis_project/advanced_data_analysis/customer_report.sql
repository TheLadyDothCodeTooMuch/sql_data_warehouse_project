CREATE VIEW data_analysis_customers AS 

    --=============================================================
    -- CTE 1: cte_base_query
    -- Gathers raw transactional data joined with customer details.
    -- Prepares a unified base including customer demographics 
    -- and sales activity for further aggregation.
    --=============================================================
    WITH cte_base_query AS (
        SELECT
            fs.order_number,
            fs.quantity,
            fs.customer_key,
            dc.customer_number,
            fs.product_key,
            fs.order_date,
            fs.sales_amount,
            CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
            DATEDIFF(YEAR, dc.birthdate, GETDATE()) AS age -- derive customer's current age dynamically
        FROM gold.fact_sales AS fs
        LEFT JOIN gold.dim_customers AS dc
        ON fs.customer_key = dc.customer_key
        WHERE order_date IS NOT NULL -- exclude incomplete or untracked sales records
    ),

    --=============================================================
    -- CTE 2: cte_customers_report
    -- Aggregates the base data at the customer level to produce
    -- total sales metrics, purchase behavior, and lifespan info.
    -- Acts as the foundation for segmentation and trend analysis.
    --=============================================================
    cte_customers_report AS (
        SELECT
            customer_key,
            customer_number,
            customer_name,  
            age,
            COUNT(DISTINCT order_number) AS total_orders,
            SUM(sales_amount) AS total_sales,
            SUM(quantity) AS total_quantity_purchased,
            COUNT(DISTINCT product_key) AS total_products,
            DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_in_months,
            MAX(order_date) AS last_order
        FROM cte_base_query
        GROUP BY customer_key,
                customer_number,
                customer_name,
                age
        )

    --=============================================================
    -- Final SELECT: Produces the cleaned customer summary.
    -- Adds derived metrics (recency, spend rates) and classifies
    -- each customer by age and engagement category.
    --=============================================================
    SELECT
        customer_key,
        customer_number,
        customer_name,  
        age,
        CASE
            WHEN age < 20 THEN 'Under 20'
            WHEN age BETWEEN 20 AND 29 THEN '20 - 29'
            WHEN age BETWEEN 30 AND 39 THEN '30 - 39'
            WHEN age BETWEEN 40 AND 49 THEN '40 - 49'
            ELSE '50 and above'
        END AS age_category,
        CASE
            WHEN lifespan_in_months >= 12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifespan_in_months >= 12 AND total_sales <= 5000 THEN 'Regular'
            WHEN lifespan_in_months < 12 THEN 'New'
        END AS customer_category,
        total_orders,
        total_sales,
        total_quantity_purchased,
        total_products,
        lifespan_in_months,
        DATEDIFF(MONTH, last_order, GETDATE()) AS recency,
        CASE
            WHEN total_orders = 0 THEN 0
            ELSE total_sales/total_orders
        END AS average_order_value,
        CASE
            WHEN lifespan_in_months = 0 THEN 0
            ELSE total_sales/lifespan_in_months
        END AS average_monthly_spend
    FROM cte_customers_report

;
