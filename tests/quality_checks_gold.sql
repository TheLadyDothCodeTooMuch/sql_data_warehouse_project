--   This query compares gender information between the CRM and ERP sources
--   to identify mismatches and determine which value should be retained.

SELECT
    ci.cst_gndr,
    ca.gen,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- crm_cust_info is the master file for gender info
        ELSE coalesce(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.CID

LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.dwh_cid

WHERE cst_gndr != gen

ORDER BY 1, 2
;


-- Validate Customer Key Integrity
-- Ensures that every customer_key in fact_sales exists in dim_customers
SELECT *
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;

-- Validate Product Key Integrity
-- Ensures that every product_key in fact_sales exists in dim_products
SELECT *
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON fs.product_key = dp.id
WHERE dp.id IS NULL;


SELECT
*
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
ON fs.customer_key = dc.customer_key
LEFT JOIN gold.dim_products AS dp
ON fs.product_key = dp.id
WHERE dp.id IS NULL
;
