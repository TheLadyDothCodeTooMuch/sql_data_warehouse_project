-- ======================================================================================
-- Run these codes for crm_cust_info after the data cleanup to test if all is as should be
-- ======================================================================================

--Checks for duplicate or multiple logs of the primary key (customer ID). The expected result is 0. Do this for the cst_id, which is supposed to be a unique value.
SELECT
    cst_id,
    COUNT(*) AS "Count"
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
;

--Checks for unwanted spaces in the names. The expected result is 0. Use for the firstname and lastname columns
SELECT
        cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

/*

SELECT DISTINCT
        cst_marital_status
FROM silver.crm_cust_info;




-- ======================================================================================
-- Run these codes for crm_prd_info after the data cleanup to test if all is as should be
-- ======================================================================================

--Checks for duplicate or multiple logs of the primary key. The expected result is 0. Do this for the cst_id, which is supposed to be a unique value.
SELECT
    prd_id
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
;

--Checks for unwanted spaces in the names. The expected result is 0. Use for the firstname and lastname columns
SELECT
        prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)
;

/*
--Checks for duplicate or multiple logs of a customer's ID after ordering from latest to earliest. The expected result is 0. Do this for the cst_id, which is supposed to be a unique value.
SELECT
*
FROM (SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM silver.crm_cust_info) AS t
WHERE flag_last != 1;
*/

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
