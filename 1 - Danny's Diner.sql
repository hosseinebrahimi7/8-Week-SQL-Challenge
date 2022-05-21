
--Case Study #1 - Danny's Diner


-- ایجاد دیتابیس dannys_diner
 CREATE DATABASE dannys_diner
 GO

 --ایجاد جدول sales
 CREATE TABLE sales
 (
	customer_id VARCHAR(1),
	order_date DATE,
	product_id INT
 )
 GO

 -- وارد کردن داده ها به جدول sales
 INSERT INTO sales
 (customer_id,order_date,product_id)
 VALUES
 ('A','2021-01-01','1'),
 ('A','2021-01-01','2'),
 ('A','2021-01-07','2'),
 ('A','2021-01-10','3'),
 ('A','2021-01-11','3'),
 ('A','2021-01-11','3'),
 ('B','2021-01-01','2'),
 ('B','2021-01-02','2'),
 ('B','2021-01-04','1'),
 ('B','2021-01-11','1'),
 ('B','2021-01-16','3'),
 ('B','2021-02-01','3'),
 ('C','2021-01-01','3'),
 ('C','2021-01-01','3'),
 ('C','2021-01-07','3')
 GO

 --ایجاد جدول منو
 CREATE TABLE menu 
 (
	product_id INT,
	product_name VARCHAR(5),
	price INT
 )
 GO

 --وارد کردن داده ها به جدول منو
 INSERT INTO menu
 (product_id,product_name,price)
 VALUES
 ('1','sushi','10'),
 ('2','curry','15'),
 ('3','ramen','12')
 GO

 -- ایجاد جدول اعضا
 CREATE TABLE members
 (
	customer_id VARCHAR(1),
	join_date DATE
 )
 GO

 -- وارد کردن داده ها به جدول اعضا
 INSERT INTO members
 (customer_id,join_date)
 VALUES
 ('A','2021-01-07'),
 ('B','2021-01-09')
 GO


 /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant? ok
SELECT s.customer_id, SUM(m.price) AS total_amount
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY customer_id
GO


-- 2. How many days has each customer visited the restaurant? ok
SELECT customer_id, COUNT(DISTINCT(order_date)) AS visit
FROM sales
GROUP BY customer_id
GO


-- 3. What was the first item from the menu purchased by each customer? ok
WITH first_order AS (
SELECT s.customer_id,m.product_name,(s.order_date),
		DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY S.order_date) AS RANK
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM first_order 
WHERE RANK = 1
GROUP BY customer_id, product_name
GO


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? OK
SELECT m.product_id, COUNT(s.product_id) AS "most purchased"
FROM sales AS s
JOIN menu AS m
ON m.product_id = s.product_id
GROUP BY m.product_id
GO



-- 5. Which item was the most popular for each customer? OK
WITH popular_item AS
(
SELECT s.customer_id, m.product_name,
DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY count(s.customer_id) DESC) AS rank
FROM sales AS s
JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id , m.product_name
)
SELECT customer_id , product_name
FROM popular_item 
WHERE rank = 1
GO

-- 6. Which item was purchased first by the customer after they became a member? OK
WITH member_sales_cte AS 
(
 SELECT s.customer_id, m.join_date, s.order_date,   s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
  ORDER BY s.order_date) AS rank
     FROM sales AS s
 JOIN members AS m
  ON s.customer_id = m.customer_id
 WHERE s.order_date >= m.join_date
)
SELECT s.customer_id, s.order_date, m2.product_name 
FROM member_sales_cte AS s
JOIN menu AS m2
 ON s.product_id = m2.product_id
WHERE rank = 1;
GO

-- 7. Which item was purchased just before the customer became a member? OK
WITH purchased_before_member AS 
(
 SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
         DENSE_RANK() OVER(PARTITION BY s.customer_id
         ORDER BY s.order_date DESC) AS rank
 FROM sales AS s
 JOIN members AS m
  ON s.customer_id = m.customer_id
 WHERE s.order_date < m.join_date
)
SELECT s.customer_id, s.order_date, m2.product_name 
FROM purchased_before_member AS s
JOIN menu AS m2
 ON s.product_id = m2.product_id
WHERE rank = 1
GO


-- 8. What is the total items and amount spent for each member before they became a member? OK
SELECT s.customer_id, SUM(m.price) AS "total amount" ,count(m.product_id) AS "total item"
FROM sales AS s
JOIN menu AS m
ON s.product_id =  m.product_id
JOIN members AS me
ON s.customer_id = me.customer_id
WHERE  s.order_date < me.join_date
GROUP BY s.customer_id
GO

