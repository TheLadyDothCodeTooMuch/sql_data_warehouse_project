# SQL Data Warehouse Project
Building a modern data warehouse with SQL, including ETL processes, data modelling and analytics.




# Data Analysis Project — Customer & Product Insights

## 📊 Project Summary
This project provides analytical SQL views for understanding business performance across customers and products.  
Using the **fact_sales**, **dim_customers**, and **dim_products** tables from the gold layer under the SQL Datawarehouse Project, these queries generate summarized metrics such as total sales, order frequency, customer lifetime value, and product performance categories.

The goal is to help analysts and stakeholders quickly identify high-value customers, top-performing products, and key revenue trends.

---

## 🧱 SQL Views

### 1. `data_analysis_project`
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
│
├── sql/
│   ├── data_analysis_customers.sql
│   ├── data_analysis_products.sql
│
├── README.md
└── LICENSE

