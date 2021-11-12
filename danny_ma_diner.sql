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

-- 6. Which item was purchased first by the customer after they became a member?

WITH ranked_cte AS (
SELECT
 s.customer_id,
 s.order_date,
 me.join_date,
 m.product_name,
 DENSE_RANK() OVER(PARTITION BY s.customer_id
                   ORDER BY s.order_date) AS ranks
FROM dannys_diner.sales s 
JOIN dannys_diner.members me 
 ON s.customer_id = me.customer_id
JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
WHERE s.order_date >= me.join_date
)

SELECT 
 customer_id,
 product_name
FROM ranked_cte
WHERE ranks = 1;

-- A ordered curry and B ordered sushi just before they became a member of danny's diner.

-- 7. Which item was purchased just before the customer became a member?

WITH ranked_cte AS (
SELECT
 s.customer_id,
 s.order_date,
 me.join_date,
 m.product_name,
 DENSE_RANK() OVER(PARTITION BY s.customer_id
                   ORDER BY s.order_date DESC) AS ranks
FROM dannys_diner.sales s 
JOIN dannys_diner.members me 
 ON s.customer_id = me.customer_id
JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
WHERE s.order_date < me.join_date
)

SELECT 
 customer_id,
 product_name
FROM ranked_cte
WHERE ranks = 1;

-- A ordered Sushi & Curry and B ordered Sushi before they became a member.

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT
 s.customer_id,
 COUNT( DISTINCT m.product_name) AS total_items,
 SUM(m.price) AS total_amount
FROM dannys_diner.sales s 
JOIN dannys_diner.members me 
 ON s.customer_id = me.customer_id
JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
WHERE s.order_date < me.join_date
GROUP BY s.customer_id;

-- A spent a total of 25 dollars on 2 items and B spent a toal of 40 dollars on 2 items before they became a member.

-- 9. If each 1$ spent equates to 10 points and sushi has a 2*points mutiplier- how many points would eacg customer have?

SELECT 
 s.customer_id,
 SUM(CASE when m.product_name = 'sushi' THEN 2*10*m.price ELSE 10*m.price END) AS total_points
FROM dannys_diner.sales s 
JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- A will have 860 total points, B will have 940 points and C will have 360 points

-- 10. In the first week after a customer joins the program (including their join date) they earn 2*points on all items, not just sushi - how many points do customer A and B have at the end of january?

SELECT
 s.customer_id,
 SUM (
  CASE 
   WHEN s.order_date BETWEEN me.join_date AND ((me.join_date + INTERVAL '6 DAYS')::DATE)
   THEN 2*10*m.price
   WHEN m.product_name = 'sushi'
   THEN 2*10*m.price 
   ELSE 10*m.price
  END
  ) AS total_points
FROM dannys_diner.sales s
JOIN dannys_diner.members me 
 ON s.customer_id = me.customer_id
JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
WHERE s.order_date < '2021-02-01'
GROUP BY s.customer_id;

-- A will have total_points of 1370 and B will have 820 points

-- 11.

SELECT 
 s.customer_id,
 s.order_date,
 m.product_name,
 m.price,
 (CASE WHEN s.order_date >= me.join_date THEN 'Y'
  ELSE 'N' END) AS member
FROM dannys_diner.sales s 
LEFT JOIN dannys_diner.members me 
 ON s.customer_id = me.customer_id
LEFT JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
ORDER BY s.customer_id,s.order_date;

 -- 12 . Need to check

 WITH members_list AS (
SELECT 
 s.customer_id,
 s.order_date,
 m.product_name,
 m.price,
 CASE WHEN s.order_date >= me.join_date THEN 'Y'
  ELSE 'N' END AS member
FROM dannys_diner.sales s 
LEFT JOIN dannys_diner.members me 
 ON s.customer_id = me.customer_id
LEFT JOIN dannys_diner.menu m 
 ON s.product_id = m.product_id
ORDER BY s.customer_id,s.order_date; 
)

SELECT *, 
CASE
 WHEN member = 'Y' THEN RANK () OVER(PARTITION BY customer_id, member) 
 ELSE NULL
 END AS ranking
FROM members_list;