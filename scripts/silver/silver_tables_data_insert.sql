-- ====================================
-- Adds cleaned up data into the tables
-- ====================================

-- ============================================
-->> silver.crm_cust_info table values insert
-- ============================================

INSERT INTO silver.crm_cust_info(cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (SELECT
            *,
            ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info) AS t
    WHERE flag_last = 1;

;


-- ============================================
-->> silver.crm_cust_info table values insert
-- ============================================

-- Step 1: Ensure the script is re-runnable by dropping the table if it exists.
DROP TABLE IF EXISTS silver.crm_prd_info;

-- Step 2: Define the schema for the cleaned, silver-layer product table.
-- The dwh_cat_id column is a created column for the first five digit of the prd_key to be used in referencing other tables
-- The dwh_create_date column tracks when the record was inserted into the warehouse.
CREATE TABLE silver.crm_prd_info (
	prd_id int NULL,
    dwh_cat_id varchar(50) NULL,
	prd_key varchar(50) NULL,
	prd_nm varchar(50) NULL,
	prd_cost INT NULL,
	prd_line varchar(50) NULL,
	prd_start_dt date NULL,
	prd_end_dt date NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Step 3: Insert and transform data from the bronze layer.
INSERT INTO silver.crm_prd_info (
    prd_id, 
    prd_key, 
    dwh_cat_id, 
    prd_nm, 
    prd_cost, 
    prd_line, 
    prd_start_dt, 
    prd_end_dt)
        SELECT
            prd_id,
            prd_key,
            -- Extract the first 5 characters as a standardized category ID.
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS dwh_cat_id,
            --REPLACE(SUBSTRING(prd_key, 7, (LEN(prd_key)-6)), '-', '_') AS prd_key_2,
            prd_nm,
            -- Replace any missing costs with 0 to prevent calculation errors.
            COALESCE(prd_cost, 0) AS prd_cost,
            -- Change the product line for better readability in reports.
            CASE
                WHEN UPPER(prd_line) = 'M' THEN 'Mountain'
                WHEN UPPER(prd_line) = 'R' THEN 'Road'
                WHEN UPPER(prd_line) = 'S' THEN 'Others'
                WHEN UPPER(prd_line) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            -- Standardize the start date by removing any time component from the bronze layer.
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            -- Calculate the end date. This is the day the next version of the same product record starts.
            -- The most current record will have a NULL end date.
            CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt ASC) AS DATE) AS prd_end_dt
            -- ROW_NUMBER() OVER(PARTITION BY prd_key ORDER BY prd_start_dt DESC) AS flag_last
    FROM bronze.crm_prd_info
    --WHERE flag_last != 1;
    --WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN
    /*WHERE REPLACE(SUBSTRING(prd_key, 7, (LEN(prd_key)-6)), '-', '_') NOT IN
    (SELECT DISTINCT
        id
    FROM bronze.erp_px_cat_g1v2);
    */
;


-- ===============================================
-->> silver.crm_sales_details table values insert
-- ===============================================

DROP TABLE IF EXISTS silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
	sls_ord_num varchar(50) NULL,
	sls_prd_key varchar(50) NULL,
	sls_cust_id INT NULL,
	sls_order_dt DATE NULL,
	sls_ship_dt DATE NULL,
	sls_due_dt DATE NULL,
	sls_sales INT NULL,
	sls_quantity INT NULL,
	sls_price INT NULL,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);


-- Use a CTE to perform cleaning in logical steps
WITH CleanedSales AS (
    -- Step 1: Clean only the sls_sales column first, leave others as is.
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
     	-- Validate and convert the order date.
        CASE
			-- First, handle obviously bad data: set to NULL if the date is zero or not 8 characters long (expected format: YYYYMMDD).
            WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
			-- If the basic format is reasonable, safely attempt to cast the string to a DATE. 
			-- TRY_CAST returns NULL on failure instead of crashing.
            ELSE TRY_CAST(sls_order_dt AS DATE)
        END AS sls_order_dt,
		-- Repeat the same validation and conversion logic for the ship date.
        CASE
            WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
            ELSE TRY_CAST(sls_ship_dt AS DATE)
        END AS sls_ship_dt,
		-- Repeat the same validation and conversion logic for the due date.
        CASE
            WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
            ELSE TRY_CAST(sls_due_dt AS DATE)
        END AS sls_due_dt,
        -- Correct the sales value based on original quantity and price
        CASE 
            WHEN sls_sales <> (sls_quantity * sls_price) OR sls_sales IS NULL
            THEN ABS(sls_quantity * sls_price)
            ELSE sls_sales
        END AS sls_sales,
        -- Pass through the original quantity and price for the next step
        sls_quantity,
        sls_price
    FROM
        bronze.crm_sales_details
)

-- Step 2: Insert into the silver table, now using the cleaned data from the CTE.
INSERT INTO silver.crm_sales_details (
    sls_ord_num, 
    sls_prd_key, 
    sls_cust_id, 
    sls_order_dt, 
    sls_ship_dt, 
    sls_due_dt,
    sls_sales, 
    sls_quantity, 
    sls_price
)
SELECT 
    sls_ord_num, 
    sls_prd_key, 
    sls_cust_id, 
    sls_order_dt, 
    sls_ship_dt, 
    sls_due_dt,
    -- This sls_sales is now the CLEANED value from the CTE
    sls_sales,
    -- The quantity and price can now be cleaned using the corrected sls_sales
    CASE
        WHEN sls_quantity IS NULL OR sls_quantity <> (sls_sales / NULLIF(sls_price, 0))
        THEN ABS(sls_sales / NULLIF(sls_price, 0))
        ELSE sls_quantity
    END AS sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <> (sls_sales / NULLIF(sls_quantity, 0))
        THEN ABS(sls_sales / NULLIF(sls_quantity, 0))
        ELSE sls_price
    END AS sls_price
FROM 
    CleanedSales;


-- ===============================================
-->> silver.erp_cust_az12 table values insert
-- ===============================================

DROP TABLE IF EXISTS silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
    CID VARCHAR(50),
    bdate DATE,
    gen VARCHAR(10)
);

INSERT INTO silver.erp_cust_az12 (
    CID, 
    bdate, 
    gen)
SELECT
    CASE
        WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, len(CID)) 
        ELSE CID
    END AS CID,
    CASE
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,
    CASE
        WHEN TRIM(UPPER(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN TRIM(UPPER(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;
/*WHERE CASE
        WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, len(CID)) 
        ELSE CID
    END NOT IN (
                SELECT DISTINCT
                    cst_key
                FROM silver.crm_cust_info)
*/
