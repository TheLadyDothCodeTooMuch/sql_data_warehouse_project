-- ================================================================
-- View Name: data_analysis_products
-- Purpose:
--     Aggregates key product performance indicators from sales data.
--     Helps analysts evaluate product demand, sales volume, customer reach,
--     and lifecycle performance over time.
--
-- Highlights:
--     - Combines fact_sales and dim_products for product-level insights.
--     - Calculates lifespan, recency, and normalized revenue metrics.
--     - Categorizes products dynamically based on total sales value.

-- Use Case Example:
-- SELECT TOP 10
--    *
-- FROM data_analysis_products
-- ORDER BY total_sales DESC
-- ================================================================

CREATE VIEW data_analysis_products AS
-- ------------------------------------------------------------
-- CTE #1: Base Product-Sales Mapping
-- Forms the foundational dataset by joining product and sales data.
-- Uses INNER JOIN to include only products with at least one sale.
-- Pulls relevant fields for later aggregation, including product launch date
-- (product_start_date) which supports lifecycle calculations.
-- ------------------------------------------------------------
WITH cte_base_query_products AS (
    SELECT
        dp.product_name,
        dp.category,
        dp.subcategory,
        dp.cost,
        fs.customer_key,
        fs.order_number,
        fs.order_date,
        fs.sales_amount,
        fs.quantity,
        dp.product_start_date
    FROM gold.fact_sales AS fs
    INNER JOIN gold.dim_products AS dp
        ON dp.id = fs.product_key
),

-- ------------------------------------------------------------
-- CTE #2: Aggregation Layer (cte_product_report)
-- Consolidates transaction-level data to product-level summaries:
--     • total_orders captures unique orders per product.
--     • total_sales and total_quantity_sold represent overall performance.
--     • total_unique_customers reflects reach and engagement.
--     • lifespan (in months) since launch gives a maturity measure.
--     • last_order_date enables recency and inactivity detection.
-- ------------------------------------------------------------
cte_product_report AS (
    SELECT
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity_sold,
        COUNT(DISTINCT customer_key) AS total_unique_customers,
        DATEDIFF(MONTH, product_start_date, GETDATE()) AS lifespan,
        MAX(order_date) AS last_order_date
    FROM cte_base_query_products
    GROUP BY
        product_name,
        category,
        subcategory,
        cost,
        DATEDIFF(MONTH, product_start_date, GETDATE())
)

-- ------------------------------------------------------------
-- Final SELECT: Derives additional metrics and classifications
--     • Adds performance tiering for business readability.
--     • Calculates recency (months since last sale).
--     • Computes average revenue per order and per month.
-- Includes division guards for robustness against zero or null values.
-- ------------------------------------------------------------
SELECT
    product_name,
    category,
    subcategory,
    cost,
    total_orders,
    total_sales,

   CASE
        WHEN total_sales > 10000 THEN 'High-Performer'
        WHEN total_sales BETWEEN 5000 AND 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_category,

    total_quantity_sold,
    total_unique_customers,
    lifespan,

    -- Measures how long it’s been since the product was last sold
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    -- Normalized performance metrics
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS average_order_revenue,

    CASE
        WHEN lifespan = 0 THEN 0
        ELSE total_sales / lifespan
    END AS average_monthly_revenue

FROM cte_product_report;
