# Retail Sales SQL Analysis Project

## 📘 Project Overview
This project involves building a SQL-based analytical system to explore and derive insights from a fictional retail sales dataset. The tasks include setting up the database, cleaning the data, performing exploratory data analysis, and solving real-world business problems through SQL queries.

---

## 🛠️ Database & Table Setup
```sql
CREATE DATABASE p1_retail_db;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

---

## 📊 Data Exploration & Cleaning
```sql
-- View the dataset
SELECT * FROM retail_sales;

-- Check the total number of records
SELECT COUNT(*) FROM retail_sales;

-- Remove records with NULL values
DELETE FROM retail_sales
WHERE
    transactions_id IS NULL OR
    sale_date IS NULL OR
    sale_time IS NULL OR
    gender IS NULL OR
    category IS NULL OR
    quantity IS NULL OR
    price_per_unit IS NULL OR
    cogs IS NULL OR
    total_sale IS NULL;

-- Unique customers
SELECT COUNT(DISTINCT(customer_id)) FROM retail_sales;

-- Unique product categories
SELECT DISTINCT(category) FROM retail_sales;
```

---

## 📈 Business Problem Solving using SQL

### 1. 🔍 Sales on a Specific Date
```sql
SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';
```

### 2. 👗 Clothing Sales with High Quantity in Nov 2022
```sql
SELECT * FROM retail_sales
WHERE category = 'Clothing' AND quantity >= 4 AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
```

### 3. 📦 Total Sales by Category
```sql
SELECT category, SUM(total_sale), COUNT(*) AS total_orders
FROM retail_sales
GROUP BY category;
```

### 4. 👨‍👩‍👧 Average Age of Beauty Product Customers
```sql
SELECT gender, AVG(age) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY gender;
```

### 5. 🔢 Total Sales by Gender & Category
```sql
SELECT category, gender, SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

### 6. 📆 Best Selling Month Per Year
```sql
SELECT year, month, avg_sale FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY year, month
) AS t1
WHERE rnk = 1;
```

### 7. 🏆 Top 5 Customers by Sales
```sql
SELECT customer_id, SUM(total_sale)
FROM retail_sales
GROUP BY customer_id
ORDER BY SUM(total_sale) DESC
LIMIT 5;
```

### 8. 👥 Unique Customers per Category
```sql
SELECT category, COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY category;
```

### 9. 🌞 Transactions by Shift
```sql
SELECT shift, COUNT(*) AS total_orders FROM (
    SELECT *,
           CASE
               WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
               WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
               ELSE 'Evening'
           END AS shift
    FROM retail_sales
) AS t1
GROUP BY shift;
```

### 10. 🏷️ Top Selling Category per Month
```sql
WITH cte AS (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        category,
        SUM(total_sale) AS total_sale,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date) ORDER BY SUM(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY year, month, category
)
SELECT year, month, category, total_sale FROM cte WHERE rnk = 1;
```

### 11. 💸 Classify Customers by Spending Tiers
```sql
SELECT customer_id, SUM(total_sale) AS purchase_value,
       CASE
           WHEN SUM(total_sale) > 10000 THEN 'High'
           WHEN SUM(total_sale) BETWEEN 5000 AND 10000 THEN 'Mid'
           ELSE 'Low'
       END AS spending_tiers
FROM retail_sales
GROUP BY customer_id;
```

#### Customers per Tier
```sql
WITH cte AS (
    SELECT customer_id, SUM(total_sale) AS purchase_value,
           CASE
               WHEN SUM(total_sale) > 10000 THEN 'High'
               WHEN SUM(total_sale) BETWEEN 5000 AND 10000 THEN 'Mid'
               ELSE 'Low'
           END AS spending_tiers
    FROM retail_sales
    GROUP BY customer_id
)
SELECT spending_tiers, COUNT(customer_id), ROUND(SUM(purchase_value), 2)
FROM cte
GROUP BY spending_tiers;
```

### 12. ⏰ Peak Sale Hours by Category
```sql
WITH cte AS (
    SELECT category, EXTRACT(HOUR FROM sale_time) AS hr, COUNT(*) AS total_transaction,
           RANK() OVER(PARTITION BY category ORDER BY COUNT(*) DESC) AS rnk
    FROM retail_sales
    GROUP BY category, hr
)
SELECT category, hr, total_transaction FROM cte WHERE rnk = 1;
```

### 13. 🔄 Q1 to Q4 Sales Growth by Category
```sql
SELECT
    category,
    SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (1, 2, 3) THEN total_sale ELSE 0 END) AS Q1_sales,
    SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (10, 11, 12) THEN total_sale ELSE 0 END) AS Q4_sales,
    ROUND((
        SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (10, 11, 12) THEN total_sale ELSE 0 END) -
        SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (1, 2, 3) THEN total_sale ELSE 0 END)
    ) / NULLIF(SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (1, 2, 3) THEN total_sale ELSE 0 END), 0) * 100, 2) AS growth_percentage
FROM retail_sales
GROUP BY category;
```

### 14. 🗓️ Day of Week with Highest Average Sales
```sql
SELECT
    CASE
        WHEN weekday(sale_date) = '0' THEN 'Sunday'
        WHEN weekday(sale_date) = '1' THEN 'Monday'
        WHEN weekday(sale_date) = '2' THEN 'Tuesday'
        WHEN weekday(sale_date) = '3' THEN 'Wednesday'
        WHEN weekday(sale_date) = '4' THEN 'Thursday'
        WHEN weekday(sale_date) = '5' THEN 'Friday'
        WHEN weekday(sale_date) = '6' THEN 'Saturday'
    END AS day_of_week,
    AVG(total_sale) AS avg_sales
FROM retail_sales
GROUP BY day_of_week
ORDER BY avg_sales DESC;
```

> 💡 Interpretation: Customers prefer weekend shopping based on high average sales.

### 15. 👥 Top Spending Age Group
```sql
SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '>50'
    END AS age_group,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY age_group;
```

---



