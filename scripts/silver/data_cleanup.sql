-- ======================================================================================
-- Run these codes for crm_cust_info after the data cleanup to test if all is as should be
-- ======================================================================================
-- Checks for duplicate or multiple logs of the primary key (customer ID). The expected result is 0. Do this for the cst_id, 
-- which is supposed to be a unique value.
SELECT
    cst_id,
    COUNT(*) AS "Count"
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
;

-- Checks for unwanted spaces in the names. The expected result is 0. Use for the firstname and lastname columns
SELECT
        cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- Check the values in the column. Expected results should not include NULLS

SELECT DISTINCT
        cst_marital_status
FROM silver.crm_cust_info;


-- ======================================================================================
-- Run these codes for crm_prd_info after the data cleanup to test if all is as should be
-- ======================================================================================

-- Checks for duplicate or multiple logs of the primary key. The expected result is 0. Do this for the cst_id, 
-- which is supposed to be a unique value.
SELECT
    prd_id
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
;

-- Checks for unwanted spaces in the names. The expected result is 0. Use for the firstname and lastname columns
SELECT
        prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
;

-- Check the values in the column. Expected results should not include NULLS
SELECT DISTINCT
        prd_line
FROM silver.crm_prd_info
;

-- Check for NULLS and negative numbers. The expected result is 0
SELECT
        prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Check for invalid date orders. The expected result is 0
SELECT
        *
FROM silver.crm_prd_info
WHERE prd_start_dt !< prd_end_dt   
;



-- ===================================================================================================
-- Run these codes for silver.crm_sales_details after the data cleanup to test if all is as should be
-- ===================================================================================================

-- Checks for unwanted spaces in the names. The expected result is 0. Use for the sls_ord_num and sls_prd_key columns
SELECT
        sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key)
;

-- Check the values in the column. Expected results should not include NULLS
SELECT DISTINCT
        sls_prd_key
FROM silver.crm_sales_details
;

-- Check for NULLS and negative numbers in sls_sales, sls_quantity, sls_price. Change as appropriate. The expected result is 0
SELECT
        sls_price
FROM silver.crm_sales_details
WHERE sls_price < 0 OR sls_price IS NULL;


-- Check for invalid date orders. Change as appropriate. The expected result is 0
SELECT
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
FROM silver.crm_sales_details
-- Condition 1: Find rows where the order date is on or after the ship date (which is illogical).
WHERE sls_order_dt !< sls_ship_dt 
-- Condition 2: Find rows where the ship date is on or after the due date (also illogical).
OR sls_ship_dt !< sls_due_dt
;

-- Check for invalid dates i.e less than 0. The expected result is 0
SELECT
        *
FROM silver.crm_sales_details
WHERE 0 IN (sls_order_dt, sls_ship_dt,
   sls_due_dt)
;

-- Convert sls_due_dt values of 0 to NULL for records where sls_due_dt is 0, to handle invalid or missing dates. The expected result is 0
SELECT DISTINCT
        sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt = 0 OR LEN(sls_due_dt) <> 8
;

-- Identifies records where the total sales figure does not match the calculated value (quantity * price), or where the data is NULL. 
-- The expected result is 0
SELECT 
        sls_sales,
        sls_quantity,
        sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR sls_sales IS NULL OR sls_quantity IS NULL 
    OR sls_price IS NULL OR sls_sales = 0 OR sls_quantity = 0 OR sls_price = 0;


-- ===================================================================================================
-- Run these codes for silver.crm_sales_details after the data cleanup to test if all is as should be
-- ===================================================================================================

--Checks for duplicate or multiple logs of the primary key. The expected result is 0. Do this for the CID, 
-- which is supposed to be a unique value.
SELECT
    CID
FROM silver.erp_cust_az12
GROUP BY CID
HAVING COUNT(*) > 1 OR CID IS NULL
;

--Checks for unwanted spaces in CID and GEN. The expected result is 0. Use for the firstname and lastname columns
SELECT
        GEN
FROM silver.erp_cust_az12
WHERE GEN != TRIM(GEN)
;

-- Checks for duplicate or multiple logs of a customer's ID after ordering from latest to earliest. The expected result is 0. 
-- Do this for the cst_id, which is supposed to be a unique value.
SELECT
*
FROM (SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY CID ORDER BY bdate DESC) AS flag_last
        FROM silver.erp_cust_az12) AS t
WHERE flag_last != 1;

-- Check for invalid dates i.e birth days in the long past or the future. The expected result is 0
SELECT
        BDATE
FROM silver.erp_cust_az12
WHERE BDATE < '1925-01-01' or BDATE > GETDATE()
;

-- Check all genders listed. The expected result should be only Male, Female or n/a
SELECT DISTINCT
        gen
FROM silver.erp_cust_az12
--WHERE gen != TRIM(gen)
;


-- ===================================================================================================
-- Run these codes for silver.erp_loc_a101 after the data cleanup to test if all is as should be
-- ===================================================================================================

--Checks for duplicate or multiple logs of the primary key. The expected result is 0. Do this for the cst_id, which is supposed to be a unique value.
SELECT
    dwh_cid
FROM silver.erp_loc_a101
GROUP BY dwh_cid
HAVING COUNT(*) > 1 OR dwh_cid IS NULL
;

-- Same use as the above.
SELECT
*
FROM (SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY dwh_cid ORDER BY cntry DESC) AS flag_last
        FROM silver.erp_loc_a101) AS t
WHERE flag_last != 1;

--Checks for unwanted spaces in CNTRY. The expected result is 0.
SELECT
        CNTRY
FROM silver.erp_loc_a101
WHERE CNTRY != TRIM(CNTRY)
;

-- Check all countries listed. The expected result should be only be the full name of the countries or n/a
SELECT DISTINCT
        CNTRY
FROM silver.erp_loc_a101
ORDER BY cntry
--WHERE gen != TRIM(gen)
;


-- ===================================================================================================
-- Run these codes for silver.erp_px_cat_g1v2 after the data cleanup to test if all is as should be
-- ===================================================================================================
--Checks for duplicate or multiple logs of the primary key. The expected result is 0. 
SELECT
    ID,
    CAT,
    COUNT(ID)
FROM silver.erp_px_cat_g1v2
GROUP BY ID
HAVING COUNT(ID) > 1 OR ID IS NULL
;

--Checks for unwanted spaces. The expected result is 0.
SELECT
        *
FROM silver.erp_px_cat_g1v2
WHERE CAT != TRIM(CAT) OR 
SUBCAT != TRIM(SUBCAT) OR 
MAINTENANCE != TRIM(MAINTENANCE)
;


-- Check all subcategories or maintenance values listed. There should be no NULLs

SELECT DISTINCT
        MAINTENANCE
FROM silver.erp_px_cat_g1v2
--WHERE SUBCAT != TRIM(SUBCAT)
--ORDER BY SUBCAT
;
