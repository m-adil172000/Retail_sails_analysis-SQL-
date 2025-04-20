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

select * from retail_sales;

select count(*) from retail_sales;

-- Data Exploration

delete from retail_sales
where 
transactions_id is null or
sale_date is null or
sale_time is null or
gender is null or
category is null or
quantity is null or
price_per_unit is null or
cogs is null or
total_sale is null;

-- How many unique customers are in the dataset
select count(distinct(customer_id)) from retail_sales;

-- How many unique categories of the products do we have?
select distinct(category) from retail_sales;


-- Data Analysis and Business problems and answers

-- 1. Write a SQL query to retrieve all columns for sales made on "2022-11-05"
select * from retail_sales
where sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is "clothing" and the quantity sold is more than 10 in
-- the month of Nov-2022
select * from retail_sales
where category = "Clothing" and quantity >=4 and sale_date between '2022-11-01' and '2022-11-30';

-- 3. Write a SQL query to calculate the total sales (total_sale) for each category.:
select category, sum(total_sale), count(*) as total_orders
from retail_sales
group by 1;

-- 4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
select gender, avg(age) as avg_age 
from retail_sales 
where category ='Beauty'
group by 1;

-- 5. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
select category, gender, sum(total_sale) as total_sale
from retail_sales
group by 1,2
order by 1;

-- 6. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
select year,month,avg_sale from 
(
	select 
		extract(year from sale_date) as year, 
		Extract(month from sale_date) as month, 
		avg(total_sale) as avg_sale,
		rank() over(partition by extract(year from sale_date) order by avg(total_sale) DESC) as rnk
	from retail_sales
	group by year,month 
) as t1
where rnk=1;

-- 7. Write a SQL query to find the top 5 customers based on the highest total sales
select customer_id, sum(total_sale) from retail_sales
group by 1
order by 2 desc
limit 5;

-- 8. Write a SQL query to find the number of unique customers who purchased items from each category.:
select category, count(distinct(customer_id)) from retail_sales
group by 1;

-- 9. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
select shift, count(*) as total_orders from
(
	select *,
		CASE 
			when extract(hour from sale_time) < 12 then "Morning"
			when extract(hour from sale_time) between 12 and 17 then "Afternoon"
			when extract(hour from sale_time) >17 then "Evening"
		END as shift
	from retail_sales
) as t1
group by 1;

-- 10. Write a SQL query to extract the monthly top selling category
with cte as
(
	select 
		EXTRACT(YEAR FROM sale_date) AS year,
		extract(month from sale_date) as month, 
		category, 
		sum(total_sale) as total_sale,
		rank() over(partition by EXTRACT(YEAR FROM sale_date), extract(month from sale_date) order by sum(total_sale) DESC) as rnk
	from retail_sales
	group by 1,2,3
)
select year, month, category, total_sale
from cte
where rnk=1;

-- 11. Write a SQL query to classify customers into spending tiers (Low, Mid, High) based on their total purchase value.
select customer_id, sum(total_sale) as purchase_value,
Case
	when sum(total_sale) > 10000  then "High"
    when sum(total_sale) between 5000 and 10000 then "Mid"
    when sum(total_sale) < 5000 then "Low"
end as spending_tiers
from retail_sales
group by 1;

-- From this spending tier, we can get the number of customers per spending tier and their total purchase value
with cte as
(
	select customer_id, sum(total_sale) as purchase_value,
	Case
		when sum(total_sale) > 10000  then "High"
		when sum(total_sale) between 5000 and 10000 then "Mid"
		when sum(total_sale) < 5000 then "Low"
	end as spending_tiers
	from retail_sales
	group by 1
)
select spending_tiers, count(customer_id) , round(sum(purchase_value),2)
from cte
group by 1;

-- 12. Write a SQL query to find at what time of day does each product category experience the highest number of transactions

with cte as
(
	select 
		category, 
		extract(hour from sale_time) as hr,  
		count(*) as total_transaction,
		rank() over(partition by category order by count(*) desc) as rnk
	from retail_sales
	group by 1,2
)
select category,hr,total_transaction
from cte
where rnk=1;

-- 13. write a SQL query to calculate by what percentage the total sales for each category change from Q1 (Jan-Mar) to Q4 (Oct-Dec)
SELECT 
  category,
  SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (1, 2, 3) THEN total_sale ELSE 0 END) AS Q1_sales,
  SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (10, 11, 12) THEN total_sale ELSE 0 END) AS Q4_sales,
  ROUND(
    (SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (10, 11, 12) THEN total_sale ELSE 0 END) - 
     SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (1, 2, 3) THEN total_sale ELSE 0 END)
    ) / NULLIF(SUM(CASE WHEN EXTRACT(MONTH FROM sale_date) IN (1, 2, 3) THEN total_sale ELSE 0 END), 0) * 100, 2
  ) AS growth_percentage
FROM retail_sales
GROUP BY category;

-- 14. Write a SQL query to find out which day of the week has the highest average sales, and what might that suggest about customer shopping behavior.
select 
    case
		WHEN weekday(sale_date) = '0' THEN 'Sunday'
        WHEN weekday(sale_date) = '1' THEN 'Monday'
        WHEN weekday(sale_date) = '2' THEN 'Tuesday'
        WHEN weekday(sale_date) = '3' THEN 'Wednesday'
        WHEN weekday(sale_date) = '4' THEN 'Thursday'
        WHEN weekday(sale_date) = '5' THEN 'Friday'
        WHEN weekday(sale_date) = '6' THEN 'Saturday'
    end as day_of_week,
    avg(total_sale)
from retail_sales
group by 1
order by 2 desc;

-- From the above analysis, we can see that the customers prefer to shop on weekends

-- 15. Write a SQL query to find which age group contributes the most to overall sales

select 
	case
        when age between '18' and '25' then '18-25'
        when age between '25' and '35' then '25-35'
        when age between '35' and '50' then '35-50'
        else '>50'
    end as age_group,
    sum(total_sale)
from retail_sales
group by 1;













