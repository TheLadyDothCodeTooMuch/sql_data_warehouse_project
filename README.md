# 🏗️ SQL Data Warehouse Project

## 📖 Overview
This project is a collection of **T-SQL scripts** designed to build and maintain a **data warehouse**.  
It follows an **Extract, Transform, and Load (ETL)** methodology to process raw data from separate **CRM** and **ERP** source systems (Bronze Layer) into a unified, clean, and structured **analytics layer (Silver Layer)**.

The primary goal is to create a **single source of truth** — standardized, validated, and historically accurate — suitable for **business intelligence (BI)**, **reporting**, and **data analysis**.

---

## 📑 Table of Contents
- [Project Architecture](#project-architecture)
- [Data Model](#data-model)
- [Key Transformations & Business Logic](#key-transformations--business-logic)
  - [1. Data Cleaning & Standardization](#1-data-cleaning--standardization)
  - [2. Data Validation & Repair](#2-data-validation--repair)
  - [3. Key Standardization](#3-key-standardization)
  - [4. Historical Tracking (SCD Type 2)](#4-historical-tracking-scd-type-2)
- [How to Run](#how-to-run)

---

## 🧱 Project Architecture

This data warehouse follows a **multi-layered “medallion” architecture** to ensure data quality, traceability, and scalability.

### 🥉 Bronze Layer (Source)
**Purpose:** Raw data ingestion  
**Tables:** `bronze.crm_prd_info`, `bronze.crm_sales_details`, `bronze.erp_loc_a101`, etc.  
**Description:**  
Contains an **unfiltered copy of raw source data** from the CRM and ERP systems.  
This layer serves as a **staging and archival zone** — transformations never modify raw data.

---

### 🥈 Silver Layer (Cleaned & Conformed)
**Purpose:** The **validated, single source of truth** for analytics  
**Tables:** `silver.crm_prd_info`, `silver.crm_sales_details`, `silver.erp_loc_a101`, etc.  
**Description:**  
This layer applies **business rules, cleaning, and conformance** to integrate CRM and ERP data.  

---

### 🥇 Gold Layer (Aggregated)
**Purpose:** *(Future implementation)* Business-level aggregates  
**Description:**  
Planned for data marts such as `gold.monthly_sales_summary`, summarizing performance by product, region, or time period.
All **BI dashboards and reports** should query from this layer.


---

## 🧩 Data Model

The **Silver layer** is modeled as a simple **star schema** for efficient querying.

```
                ┌────────────────────┐
                │ silver.crm_cust_info│
                └───────────┬────────┘
                            │
┌────────────────────┐  ┌───▼───────────────────────┐  ┌────────────────────┐
│ silver.crm_prd_info│──▶ silver.crm_sales_details │◀─│ silver.erp_loc_a101│
└────────────────────┘  └───────────────────────────┘  └────────────────────┘
```

### Fact Tables (The “actions”)
- **`silver.crm_sales_details`** – Sales transactions with foreign keys to dimensions.

### Dimension Tables (The “context”)  
- **`silver.crm_cust_info`** – Unique list of customers.  
- **`silver.crm_prd_info`** – Historical list of products (SCD Type 2).  
- **`silver.erp_loc_a101`** – Customer or regional location mapping.

---

## ⚙️ Key Transformations & Business Logic

### 1. 🧹 Data Cleaning & Standardization

**Handling NULLs/Blanks**
```sql
CASE 
    WHEN NULLIF(gen, '') IS NULL THEN 'n/a'
    ELSE gen
END
```

**Decoding Abbreviations**
```sql
CASE
    WHEN UPPER(prd_line) = 'M' THEN 'Mountain'
    WHEN UPPER(prd_line) = 'R' THEN 'Road'
    ELSE 'n/a'
END
```

**Data Type Conversion**
```sql
CASE
    WHEN LEN(sls_order_dt) <> 8 THEN NULL
    ELSE TRY_CAST(sls_order_dt AS DATE)
END AS sls_order_dt
```

---

### 2. ✅ Data Validation & Repair

**Fact Integrity Check:**  
Ensures sales = quantity × price. If inconsistent, recalculates safely.

```sql
CASE 
    WHEN sls_sales <> (sls_quantity * sls_price) OR sls_sales IS NULL
    THEN ABS(sls_quantity * sls_price)
    ELSE sls_sales
END AS sls_sales
```

**Prevent Division by Zero**
```sql
ABS(sls_sales / NULLIF(sls_quantity, 0))
```

---

### 3. 🗝️ Key Standardization
Removes or adjusts inconsistent source keys.

```sql
STUFF(cid, 3, 1, '') AS dwh_cid
```

---

### 4. 🕰️ Historical Tracking (SCD Type 2)

Implements **Slowly Changing Dimension (SCD Type 2)** logic for `silver.crm_prd_info`.

**Calculate Product End Dates:**
```sql
CAST(
    DATEADD(day, -1, LEAD(prd_start_dt) OVER(
        PARTITION BY prd_key 
        ORDER BY prd_start_dt ASC
    )) 
AS DATE) AS prd_end_dt
```

**Audit Columns:**
Each table includes:
```sql
dwh_create_date DATETIME DEFAULT GETDATE()
```

---

## ▶️ How to Run

1. **Prerequisites:**  
   Ensure the Bronze tables (raw data) are loaded:
   ```sql
   SELECT * FROM bronze.crm_sales_details;
   ```

2. **Execution Order:**  
   Run the Silver-layer scripts in this sequence:
   ```
   1. silver.crm_cust_info.sql
   2. silver.crm_prd_info.sql
   3. silver.erp_loc_a101.sql
   4. silver.crm_sales_details.sql
   ```

3. **Rebuild Support:**  
   All scripts are **idempotent** and use:
   ```sql
   DROP TABLE IF EXISTS schema.table_name;
   ```

4. **Validation:**  
   Verify counts and relationships:
   ```sql
   SELECT COUNT(*) FROM silver.crm_sales_details;
   SELECT DISTINCT cust_key FROM silver.crm_cust_info;
   ```

---

## 🧰 Tools & Environment
- Microsoft SQL Server (T-SQL)
- ETL / Data Warehousing
- Git & GitHub for version control
- Optional BI Layer: Power BI, Tableau

---


# Data Analysis Project — Customer & Product Insights

## 📊 Project Summary
This project provides analytical SQL views for understanding business performance across customers and products.  
Using the **fact_sales**, **dim_customers**, and **dim_products** tables from the gold layer under the SQL Datawarehouse Project, these queries generate summarized metrics such as total sales, order frequency, customer lifetime value, and product performance categories.

The goal is to help analysts and stakeholders quickly identify high-value customers, top-performing products, and key revenue trends.

---

## 🧱 SQL Views

### 1. `data_analysis_customers`
This view aggregates **customer-level performance** metrics including:
- Total spend, order count, and product diversity
- Average revenue per order
- Customer recency and lifetime duration

**Purpose:**  
Identify high-value customers, inactive users, and potential retention opportunities.

### 2. `data_analysis_products`
This view aggregates **product-level insights** such as:
- Total orders, total sales, and quantity sold
- Number of unique customers purchasing each product
- Product lifespan, recency of last order, and revenue classification (High, Mid, Low Performer)

**Purpose:**  
Evaluate product performance, monitor sales trends, and inform inventory or marketing decisions.

---

## 🧠 SQL Design Highlights
- **CTEs (Common Table Expressions):** Used for cleaner logic separation between base queries and final aggregations.
- **Dynamic time calculations:** Functions like `DATEDIFF` and `GETDATE()` ensure up-to-date metrics.
- **Performance categorization:** Products and customers are grouped into tiers for quick business insight.
- **Error prevention:** Divisions are safely handled with `CASE` conditions to avoid division by zero.

---

## 📁 Folder Structure
```bash
Data-Analysis-Project/
├── advanced_data_analysis/
│   ├── data_analysis_customers.sql
│   ├── data_analysis_products.sql
├── exploratory_data_analysis/
│   ├── category_depth.sql
│   ├── cost_analysis.sql
│   ├── country_sales_volume.sql
│   ├── customer_age_span.sql
│   ├── customer_revenue_ranking.sql
│   ├── gender_insights.sql
│   ├── geographic_insights.sql
│   ├── least_products.sql
│   ├── low_order_count.sql
│   ├── monthly_revenue_trends.sql
│   ├── order_range.sql
│   ├── revenue_by_category.sql
│   ├── revenue_trends.sql
│   ├── running_totals.sql
│   ├── sales_span.sql
│   ├── sales_summary.sql


