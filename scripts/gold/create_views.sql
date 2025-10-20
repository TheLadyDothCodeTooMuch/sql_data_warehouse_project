/******************************************************************************************
Purpose: Create dimension views for Customers and Products in the gold layer.
Notes:
- Views consolidate and clean data from silver-layer CRM and ERP sources.
- Designed for use in analytics and reporting.
******************************************************************************************/

-----------------------------------------------------------------------------------
-- View: gold.dim_customers  
-- Purpose: Create a unified customer dimension for analytics by combining CRM and ERP
--           data.  
-- Notes: CRM is treated as the master source for gender and customer identity.
-----------------------------------------------------------------------------------


CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id ASC) AS customer_key,  -- surrogate key for dimensional modeling
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
  -- prioritize CRM gender if valid, otherwise use ERP or 'n/a'
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- crm_cust_info is the master file for gender info
        ELSE coalesce(ca.gen, 'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.cst_key = ca.CID

LEFT JOIN silver.erp_loc_a101 AS la
ON ci.cst_key = la.dwh_cid

;

--------------------------------------------------------------------------------------
-- View: gold.dim_products  
-- Purpose: Build a product dimension combining CRM and ERP product data for analytics
--           and reporting.  
-- Notes: Excludes inactive (historical) products by filtering out records with 
--         a non-null end date.
---------------------------------------------------------------------------------------

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt ASC, pn.prd_key ASC) AS id,
    pn.prd_id AS product_id,
    SUBSTRING(pn.prd_key, 7, LEN(pn.prd_key)) AS product_number,
    pn.prd_nm AS product_name,
    pn.dwh_cat_id AS category_id,
	pc.CAT AS category,
    pc.SUBCAT AS subcategory,
	pc.MAINTENANCE AS maintenance,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS product_start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.dwh_cat_id = pc.ID

WHERE prd_end_dt IS NULL -- include only active products
;
