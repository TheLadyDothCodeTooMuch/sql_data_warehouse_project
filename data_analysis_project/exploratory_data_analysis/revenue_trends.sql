-- ===============================================
-- REVENUE TRENDS ANALYSIS
-- ===============================================

--=============================================================
-- CTE 1: cte_base_calculations
-- Aggregates yearly sales revenue per product.
-- Establishes the foundation for historical trend analysis.
--=============================================================
WITH cte_base_calculations AS (
    SELECT
        DATEPART(year, fs.order_date) AS order_date,  -- extract order year for aggregation
        dp.product_name AS product_name,
        SUM(fs.sales_amount) AS total_revenue          -- yearly revenue per product
    FROM gold.dim_products AS dp
    LEFT JOIN gold.fact_sales AS fs
        ON dp.id = fs.product_key
    WHERE order_date IS NOT NULL                      -- exclude incomplete or untracked sales
    GROUP BY DATEPART(year, fs.order_date), dp.product_name
),

--=============================================================
-- CTE 2: cte_lag_avg_calc
-- Uses window functions to find previous-year revenue 
-- and compute average performance per product.
--=============================================================
cte_lag_avg_calc AS (
    SELECT
        order_date,
        product_name,
        total_revenue,
        LAG(total_revenue, 1) OVER(
            PARTITION BY product_name 
            ORDER BY order_date
        ) AS total_revenue_previous_year,             -- previous year's revenue for trend comparison
        AVG(COALESCE(total_revenue, 0)) OVER(
            PARTITION BY product_name
        ) AS total_average_revenue                    -- overall average for product performance baseline
    FROM cte_base_calculations
)

--=============================================================
-- FINAL OUTPUT: PERFORMANCE CLASSIFICATION
-- Derives differences, labels performance, and compares 
-- revenue to average and previous year benchmarks.
--=============================================================
SELECT
    order_date,
    product_name,
    total_revenue,
    total_revenue_previous_year,
    total_revenue - total_revenue_previous_year AS diff_total,  -- year-over-year revenue change
    CASE
        WHEN total_revenue - total_revenue_previous_year > 0 THEN 'Great Performance'
        WHEN total_revenue - total_revenue_previous_year < 0 THEN 'Poor Performance'
        ELSE 'Average Performance'
    END AS notes_a,                                             -- interpret performance trend textually
    total_average_revenue,
    total_revenue - total_average_revenue AS diff_avg,           -- deviation from product’s long-term average
    CASE
        WHEN total_revenue - total_average_revenue > 0 THEN 'Above Average'
        WHEN total_revenue - total_average_revenue < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS notes
FROM cte_lag_avg_calc;
