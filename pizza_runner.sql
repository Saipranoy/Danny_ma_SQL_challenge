-- CLEANING THE TABLE customer_orders

CREATE TEMP TABLE customer_orders AS (
SELECT
order_id,
customer_id,
pizza_id,
 CASE WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN  ' '
      ELSE exclusions END AS exclusions,
CASE WHEN  extras IS NULL OR extras LIKE 'null' THEN ' '
     ELSE extras END AS extras,
order_time
FROM pizza_runner.customer_orders
);

SELECT * FROM customer_orders;

-- CLEANING THE TABLE runner_orders

CREATE TEMP TABLE runner_orders AS (
SELECT 
order_id,
runner_id,
CASE WHEN pickup_time IS NULL OR pickup_time LIKE 'null'
     THEN ' '
     ELSE pickup_time
END AS pickup_time,
CASE WHEN distance IS NULL OR distance LIKE 'null' THEN ' '
     WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
     ELSE distance
END AS distance,
CASE WHEN duration IS NULL OR duration LIKE 'null' THEN ' '
     WHEN duration LIKE '%mins' THEN TRIM ('mins' FROM duration)
     WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
     WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
     ELSE duration
END AS duration,
CASE WHEN cancellation IS NULL OR cancellation LIKE 'null' THEN ' '
     ELSE cancellation
END AS cancellation
FROM pizza_runner.runner_orders
);