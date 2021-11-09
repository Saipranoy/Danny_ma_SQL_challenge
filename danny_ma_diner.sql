-- 1. What is the total amount each customer spent at the restaurant?

WITH joined_table AS (
SELECT
 *
FROM dannys_diner.sales s
JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
)

SELECT 
 j.customer_id,
 SUM(j.price) AS Total_amount
FROM joined_table j 
GROUP BY j.customer_id
ORDER BY j.customer_id;

-- A spent 76 dollars, B spent 74 dollars, C spent 36 dollars untill the end date of the data in the diner.

-- 2. How many days each customer visited the restaurant?

SELECT
 customer_id,
 COUNT(DISTINCT order_date) as Visited_total
FROM dannys_diner.sales 
GROUP BY customer_id;

-- A visited 4 times, B visited 6 times, C visited 2 times to the diner.

-- 3. What was the first item from the menu purchased by each customer?

WITH ranking_cte AS (
SELECT 
 *,
 DENSE_RANK() OVER (PARTITION BY customer_id
                    ORDER BY order_date)
                    AS dense_ranking
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
 ON s.product_id = m.product_id

)

SELECT
 customer_id,
 product_name
FROM ranking
WHERE dense_ranking = 1
GROUP BY customer_id, product_name;

-- A ordered curry and sushi, B oredered curry and C ordered ramen on their first visit ot the diner.

-- 4. What is the most purchased item on the menu and how many times was it purchased by the customers?

SELECT
 product_name,
 COUNT(s.product_id) as no_of_times_purchased
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
 ON s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY no_of_times_purchased DESC
LIMIT 1;

-- Ramen was purchased 8 times by the customer and is purchased frequently by all customers.

-- 5. which item was most popular for each customer?

WITH ranked_cte AS(
SELECT
 s.customer_id,
 m.product_name,
 COUNT(s.product_id) AS times,
 DENSE_RANK() OVER (PARTITION BY s.customer_id
                    ORDER BY COUNT(s.product_id) DESC)
                    AS ranks
FROM dannys_diner.sales s 
JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
)

SELECT 
 customer_id,
 times,
 product_name
FROM ranked_cte 
WHERE ranks  = 1; 

-- A & C love ramen most where as B loves all the items in the menu.
