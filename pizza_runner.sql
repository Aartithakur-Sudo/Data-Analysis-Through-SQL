CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

USE pizza_runner;
SHOW TABLES;

SELECT * FROM runners;
SELECT * FROM customer_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
SELECT * FROM runner_orders;


DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 12:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 12:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-02 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  

  /**Queries**/
SHOW TABLES;

/*Treatment of null Values*/

SELECT * FROM customer_orders;
SELECT * FROM runner_orders;

SELECT order_id,customer_id,exclusions,extras,
CASE 
WHEN extras IS NOT NULL THEN extras
ELSE 'N/A'
END as extras
FROM customer_orders
order by customer_id;


/**Pizza Metrics**/

/*1.How many pizzas were ordered?**/

show tables;

SELECT COUNT(*) as total_no_of_orders FROM  customer_orders;


/**How many unique customer orders were made?**/

SELECT COUNT(DISTINCT order_id) AS unique_cust_order FROM customer_orders;

/**How many successful orders were delivered by each runner?**/

SELECT COUNT(*) FROM runner_orders
WHERE cancellation ='' OR cancellation IS NULL;

/**How many of each type of pizza was delivered?**/

SELECT count(*),c.pizza_id FROM customer_orders c
JOIN runner_orders r
on c.order_id=r.order_id
WHERE cancellation ='' OR cancellation IS NULL
group by 2;

/**How many Vegetarian and Meatlovers were ordered by each customer?**/
SELECT p.pizza_name,c.customer_id,count(*) FROM pizza_names p
JOIN customer_orders c
ON c.pizza_id=p.pizza_id
group by 2
order by 1;

/*or*/
SELECT pn.pizza_name, COUNT(*)
FROM customer_orders co JOIN pizza_names pn 
ON co.pizza_id = pn.pizza_id 
GROUP BY pn.pizza_name;

/**What was the maximum number of pizzas delivered in a single order?**/
SELECT c.order_id,count(*)  AS counts FROM customer_orders c
JOIN runner_orders r
on c.order_id=r.order_id
WHERE cancellation =''
GROUP BY 1
order by counts desc
limit 1;

/**For each customer, how many delivered pizzas had at least 1 change and how many had no changes?**/

SELECT customer_id,changes, count(*) as counts
 FROM 
 (SELECT c.customer_id,
 CASE WHEN exclusions <> '' OR extras <> ''THEN 'yes'
 ELSE 'no'
 END changes
 FROM customer_orders c
 JOIN runner_orders r
 ON r.order_id=c.order_id
 WHERE r.cancellation = '') as customer
 GROUP BY customer_id ,changes;
 
 /**How many pizzas were delivered that had both exclusions and extras?**/
 SELECT * FROM customer_orders c
JOIN runner_orders r
on c.order_id=r.order_id
WHERE r.cancellation ='' and c.exclusions <> '' and c.extras <> '';

 /**What was the total volume of pizzas ordered for each hour of the day?**/

SELECT hour(order_time) as hours,count(*) 
FROM customer_orders c
group by hours;

/**What was the volume of orders for each day of the week?**/
SELECT day(order_time) as days, week(order_time) as week ,count(*) 
FROM customer_orders c
group by days
order by days;
 
