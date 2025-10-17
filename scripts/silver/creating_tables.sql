-- Creating the six tables before import of the csv files --

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
cst_id INT,
cst_key VARCHAR(50),
cst_firstname VARCHAR(50),
cst_lastname VARCHAR(50),
cst_marital_status VARCHAR(2),
cst_gndr VARCHAR(2),
cst_create_date DATE,
-- Audit column to track when the record was loaded.
dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost DECIMAL(6,2),
    prd_line VARCHAR(2),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt VARCHAR(50),
    sls_ship_dt VARCHAR(50),
    sls_due_dt VARCHAR(50),
    sls_sales DECIMAL(10,2),
    sls_quantity DECIMAL(10,2),
    sls_price DECIMAL(10,2),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12(
    CID VARCHAR(50),
    BDATE DATE,
    GEN VARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101(
    CID VARCHAR(50),
    CNTRY VARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2(
    ID VARCHAR(10),
    CAT VARCHAR(50),
    SUBCAT VARCHAR(50),
    MAINTENANCE VARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
