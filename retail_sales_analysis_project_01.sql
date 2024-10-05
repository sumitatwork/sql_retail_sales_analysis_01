-- SQL Retail Sales Analysis Project

-- Dropping the retail_sales table if it exists to avoid duplication
DROP TABLE IF EXISTS retail_sales;

-- Creating the retail_sales table
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,    -- Unique ID for each transaction
    sale_date DATE,                     -- Date of the sale
    sale_time TIME,                     -- Time of the sale
    customer_id INT,                    -- ID of the customer
    gender VARCHAR(15),                 -- Customer's gender (Male/Female/Other)
    age INT,                            -- Customer's age
    category VARCHAR(15),               -- Product category (Clothing, Beauty, etc.)
    quantity INT,                       -- Quantity of items sold
    price_per_unit FLOAT,               -- Price per item unit
    cogs FLOAT,                         -- Cost of goods sold
    total_sale FLOAT                    -- Total sale amount (quantity * price_per_unit)
);

-- Creating indexes for performance improvement on frequently queried columns
CREATE INDEX idx_sale_date ON retail_sales(sale_date);    -- Index on sale_date for faster date-related queries
CREATE INDEX idx_category ON retail_sales(category);      -- Index on category for faster category-based queries
CREATE INDEX idx_customer_id ON retail_sales(customer_id);-- Index on customer_id for customer-related queries

-- Data Cleaning: Checking for NULL Values
-- This query retrieves any rows where one or more columns contain NULL values.
SELECT * 
FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

-- Data Cleaning: Deleting rows with NULL values
DELETE
FROM retail_sales
WHERE 
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

-- Data Exploration: How many sales have been made?
SELECT COUNT(*) AS total_sales
FROM retail_sales;

-- Data Exploration: How many unique customers are in the dataset?
SELECT 
    COUNT(DISTINCT(customer_id)) AS total_customers 
FROM retail_sales;

-- Data Exploration: How many unique categories of products are sold?
SELECT 
    DISTINCT(category) AS unique_categories 
FROM retail_sales;

-- Data Analysis and Business Insights

-- Q1: Retrieve all sales made on "2022-11-05"
SELECT * 
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2: Retrieve transactions where the category is 'Clothing', sale occurred in November 2022, and quantity is >= 4
SELECT * 
FROM retail_sales
WHERE category = 'Clothing'
    AND TO_CHAR(sale_date,'YYYY-MM') = '2022-11'
    AND quantity >= 4;

-- Q3: Calculate the total sales (total_sale) for each product category
SELECT 
    category,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;

-- Q4: Find the average age of customers who purchase items from the 'Beauty' category
SELECT 
    ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q5: Find all transactions where the total_sale is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q6: Find the total number of transactions (transactions_id) made by each gender for each product category
SELECT
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;

-- Q7: Calculate the average sale for each month and identify the best-selling month for each year
SELECT 
    t1.year,
    t1.month,
    t1.avg_sales
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sales,
        RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
    FROM retail_sales
    GROUP BY year, month
) AS t1
WHERE t1.rank = 1;

-- Q8: Find the top 5 customers based on the highest total sales
SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q9: Find the number of unique customers who purchase items from each category
SELECT
    category,
    COUNT(DISTINCT(customer_id)) AS unique_customers
FROM retail_sales
GROUP BY category;

-- Q10: Create shifts (Morning, Afternoon, Evening) and find the number of orders in each shift
SELECT
    t1.shift AS shift_name,
    COUNT(*) AS total_orders
FROM (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
) AS t1
GROUP BY shift_name;

-- Additional Query: Calculate the total revenue generated each month
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(total_sale) AS total_revenue
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;

-- End of Retail Sales Analysis Project
