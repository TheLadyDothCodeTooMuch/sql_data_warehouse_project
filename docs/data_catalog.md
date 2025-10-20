📘 Gold Layer Data Dictionary

This document describes the Gold Layer views used for analytics and reporting.
Each view is derived from cleaned and standardized Silver Layer data.

🧍‍♀️ gold.dim_customers

| **Column Name**   | **Data Type** | **Description**                                  | **Source (Silver Layer)**                      | **Transformation / Notes**                             |
| ----------------- | ------------- | ------------------------------------------------ | ---------------------------------------------- | ------------------------------------------------------ |
| `customer_key`    | INT           | Surrogate primary key for the customer dimension | Generated                                      | Sequential `ROW_NUMBER()` based on `cst_id`            |
| `customer_id`     | VARCHAR(50)   | Unique customer identifier                       | `crm_cust_info.cst_id`                         | Direct mapping                                         |
| `customer_number` | VARCHAR(50)   | Customer number used internally                  | `crm_cust_info.cst_key`                        | Direct mapping                                         |
| `first_name`      | VARCHAR(100)  | Customer’s first name                            | `crm_cust_info.cst_firstname`                  | Direct mapping                                         |
| `last_name`       | VARCHAR(100)  | Customer’s last name                             | `crm_cust_info.cst_lastname`                   | Direct mapping                                         |
| `country`         | VARCHAR(50)   | Customer’s country                               | `erp_loc_a101.cntry`                           | Joined via `ci.cst_key = la.dwh_cid`                   |
| `marital_status`  | VARCHAR(20)   | Customer’s marital status                        | `crm_cust_info.cst_marital_status`             | Direct mapping                                         |
| `gender`          | VARCHAR(10)   | Customer gender (CRM preferred)                  | `crm_cust_info.cst_gndr` / `erp_cust_az12.gen` | Uses CRM gender unless `'n/a'`, else falls back to ERP |
| `birthdate`       | DATE          | Customer’s birth date                            | `erp_cust_az12.bdate`                          | From ERP                                               |
| `create_date`     | DATE          | Record creation date                             | `crm_cust_info.cst_create_date`                | From CRM                                               |


📦 gold.dim_products

| **Column Name**      | **Data Type** | **Description**                             | **Source (Silver Layer)**     | **Transformation / Notes**                           |
| -------------------- | ------------- | ------------------------------------------- | ----------------------------- | ---------------------------------------------------- |
| `id`                 | INT           | Surrogate primary key for product dimension | Generated                     | `ROW_NUMBER()` ordered by product start date and key |
| `product_id`         | VARCHAR(50)   | Unique product identifier                   | `crm_prd_info.prd_id`         | Direct mapping                                       |
| `product_number`     | VARCHAR(50)   | Product number (trimmed key)                | `crm_prd_info.prd_key`        | Extracted with `SUBSTRING(prd_key, 7, LEN(prd_key))` |
| `product_name`       | VARCHAR(255)  | Product name                                | `crm_prd_info.prd_nm`         | Direct mapping                                       |
| `category_id`        | VARCHAR(50)   | Category foreign key                        | `crm_prd_info.dwh_cat_id`     | Direct mapping                                       |
| `category`           | VARCHAR(100)  | Product category                            | `erp_px_cat_g1v2.CAT`         | Joined on `dwh_cat_id = ID`                          |
| `subcategory`        | VARCHAR(100)  | Product subcategory                         | `erp_px_cat_g1v2.SUBCAT`      | From ERP                                             |
| `maintenance`        | VARCHAR(50)   | Maintenance type                            | `erp_px_cat_g1v2.MAINTENANCE` | From ERP                                             |
| `cost`               | DECIMAL(10,2) | Unit cost of product                        | `crm_prd_info.prd_cost`       | Direct mapping                                       |
| `product_line`       | VARCHAR(100)  | Product line classification                 | `crm_prd_info.prd_line`       | Direct mapping                                       |
| `product_start_date` | DATE          | Product activation/start date               | `crm_prd_info.prd_start_dt`   | Direct mapping                                       |
| *(Filter applied)*   | —             | Excludes inactive products                  | —                             | Records where `prd_end_dt IS NULL` only              |


💰 gold.fact_sales

| **Column Name** | **Data Type** | **Description**                                   | **Source (Silver Layer)**                                       | **Transformation / Notes**                  |
| --------------- | ------------- | ------------------------------------------------- | --------------------------------------------------------------- | ------------------------------------------- |
| `order_number`  | VARCHAR(50)   | Unique sales order identifier                     | `crm_sales_details.sls_ord_num`                                 | Direct mapping                              |
| `product_key`   | INT           | Foreign key to `dim_products`                     | `crm_sales_details.sls_prd_key` → `dim_products.product_number` | Joined via product number                   |
| `customer_key`  | INT           | Foreign key to `dim_customers`                    | `crm_sales_details.sls_cust_id` → `dim_customers.customer_id`   | Joined via customer ID                      |
| `order_date`    | DATE          | Date of order placement                           | `crm_sales_details.sls_order_dt`                                | Direct mapping                              |
| `shipping_date` | DATE          | Date order was shipped                            | `crm_sales_details.sls_ship_dt`                                 | Direct mapping                              |
| `due_date`      | DATE          | Expected delivery date                            | `crm_sales_details.sls_due_dt`                                  | Direct mapping                              |
| `sales_amount`  | DECIMAL(12,2) | Total value of the sale                           | `crm_sales_details.sls_sales`                                   | Direct mapping                              |
| `quantity`      | INT           | Number of units sold                              | `crm_sales_details.sls_quantity`                                | Direct mapping                              |
| `price`         | DECIMAL(10,2) | Unit sale price                                   | `crm_sales_details.sls_price`                                   | Direct mapping                              |
| *(Join notes)*  | —             | Links transactional data with dimensional context | —                                                               | LEFT JOINs used to retain unmatched records |


### 🔍 Summary

- **Dimensional Model:**  
  - `dim_customers` → Customer master data  
  - `dim_products` → Product master data  
  - `fact_sales` → Transactional sales data (linked to both dimensions)  

- **Join Strategy:**  
  All joins are **LEFT JOINs** to preserve completeness of the fact table even when dimension references are missing.

- **Data Source Layers:**  
  - Silver Layer = cleaned CRM and ERP data  
  - Gold Layer = analysis-ready, integrated data views
