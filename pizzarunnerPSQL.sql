-- my solution for the 2nd case: pizza runner
--first we need to create the database and tables in PostgreSQL

-- for runners table
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INT,
  "registration_date" DATE
);

INSERT INTO runners 
    ("runner_id", "registration_date")
VALUES
    ('1', '1/1/2021'),
    ('2', '1/3/2021'),
    ('3', '1/8/2021'),
    ('4', '1/15/2021');

-- for customer_orders table
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INT,
  "customer_id" INT,
  "pizza_id" INT,
  "exclusions" VARCHAR(5),
  "extras" VARCHAR(5),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
    ("order_id","customer_id","pizza_id","exclusions","extras","order_time")
VALUES
    ('1', '101', '1', '', '', '1/1/2021  18:05:02'),
    ('2', '101', '1', '', '', '1/1/2021  19:00:52'),
    ('3', '102', '1', '', '', '1/2/2021  23:51:23'),
    ('3', '102', '2', '', 'NaN', '1/2/2021  23:51:23'),
    ('4', '103', '1', '4', '', '1/4/2021  13:23:46'),
    ('4', '103', '1', '4', '', '1/4/2021  13:23:46'),
    ('4', '103', '2', '4', '', '1/4/2021  13:23:46'),
    ('5', '104', '1', 'null', '1', '1/8/2021  21:00:29'),
    ('6', '101', '2', 'null', 'null', '1/8/2021  21:03:13'),
    ('7', '105', '2', 'null', '1', '1/8/2021  21:20:29'),
    ('8', '102', '1', 'null', 'null', '1/9/2021  23:54:33'),
    ('9', '103', '1', '4', '1, 5', '1/10/2021  11:22:59'),
    ('10', '104', '1', 'null', 'null', '1/11/2021  18:34:49'),
    ('10', '104', '1', '2, 6', '1, 4', '1/11/2021  18:34:49');

-- for runner_orders
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INT,
  "runner_id" INT,
  "pickup_time" VARCHAR(25),
  "distance" VARCHAR(10),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(25),
   PRIMARY KEY (order_id)
);

INSERT INTO runner_orders
    ("order_id","runner_id","pickup_time","distance","duration","cancellation")
VALUES
    ('1', '1', '1/1/2021  18:15:34', '20km', '32 minutes', ''),
    ('2', '1', '1/1/2021  19:10:54', '20km', '27 minutes', ''),
    ('3', '1', '1/3/2021  00:12:37', '13.4km', '20 mins', 'NaN'),
    ('4', '2', '1/4/2021  13:53:03', '23.4', '40', 'NaN'),
    ('5', '3', '1/8/2021  21:10:57', '10', '15', 'NaN'),
    ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
    ('7', '2', '1/8/2021  21:30:45', '25km', '25mins', 'null'),
    ('8', '2', '1/10/2021  00:15:02', '23.4 km', '15 minute', 'null'),
    ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
    ('10', '1', '1/11/2021  18:50:20', '10km', '10minutes', 'null');

-- for pizza_names table

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names(
    "pizza_id" INT NOT NULL, 
    "pizza_name" TEXT NOT NULL,
    PRIMARY KEY (pizza_id));

INSERT INTO pizza_names
    ("pizza_id","pizza_name")
VALUES 
    ('1', 'Meat Lovers'),
    ('2', 'Vegetarian');
    
-- SELECT * FROM pizza_names;

-- for pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes(
    "pizza_id" INT NOT NULL, 
    "toppings" TEXT NOT NULL,
    PRIMARY KEY (pizza_id));

INSERT INTO pizza_recipes
    ("pizza_id","toppings")
VALUES 
    ('1', '1, 2, 3, 4, 5, 6, 8, 10'),
    ('2', '4, 6, 7, 9, 11, 12');

-- for pizza_toppings table
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings(
    "topping_id" int NOT NULL, 
    "topping_name" text NOT NULL,
    PRIMARY KEY (topping_id));

INSERT INTO pizza_toppings
    ("topping_id","topping_name")
VALUES 
    ('1', 'Bacon'),
    ('2', 'BBQ Sauce'),
    ('3', 'Beef'),
    ('4', 'Cheese'),
    ('5', 'Chicken'),
    ('6', 'Mushrooms'),
    ('7', 'Onions'),
    ('8', 'Pepperoni'),
    ('9', 'Peppers'),
    ('10', 'Salami'),
    ('11', 'Tomatoes'),
    ('12', 'Tomato Sauce');

/*
Business Questions in this case study are divided into several sections
I .     Pizza Metrics
II.     Runner and Customer Experience
III.    Ingredient Optimisation
IV.     Pricing and Ratings
V.      Bonus DML Challenges (DML = Data Manipulation Language)
Questions are picked, not all will be answered
*/

-- First of all, lets clean the data first :) especially on the customer_orders table and runner_orders table
-- customer_orders table: problem is in exclusion and extras column,  
-- Blank cells, NaN and 'null' are to be specified into NULL
UPDATE customer_orders
    SET exclusions = NULL
    WHERE exclusions IN ('null','') ;

UPDATE customer_orders
    SET extras=NULL
    WHERE extras IN ('null','', 'NaN');

-- runner_orders table
-- trim the km in the distance
UPDATE runner_orders 
    SET distance = CASE 
        WHEN distance LIKE '%?km' THEN TRIM(' km' FROM distance)
        WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
        ELSE distance END; 
        
-- trim the minutes in the duration
UPDATE runner_orders
    SET duration = TRIM(SUBSTRING(duration, 3, 8)FROM duration)
    WHERE duration LIKE '%m%';
-- this command needs to be improved if duration is more than 2 digits

-- update to Null in pickup_time, distance, duration and cancellation
UPDATE runner_orders
    SET pickup_time = NULL, distance = NULL, duration = NULL
    WHERE pickup_time = 'null' ; -- no need to put all condition since 
    -- if pickup_time is null others are null as well

UPDATE runner_orders
    SET cancellation=NULL
    WHERE cancellation IN ('null','', 'NaN');
-- Now that is cleaned, perhaps the duration and the distance can be changed into integer and numeric. 
ALTER TABLE runner_orders
ALTER COLUMN distance TYPE NUMERIC(8,2) USING distance::numeric(8,2);

ALTER TABLE runner_orders
ALTER COLUMN duration TYPE INT USING duration::INTEGER; 


-- check!
SELECT * FROM runner_orders ORDER BY order_id;

-- I. Pizza Metrics 
-- I.1 How many unique customer orders were made? 
-- in this question, I defined that unique customer orders are unique pizza
SELECT * FROM customer_orders ORDER BY order_id; -- only to preview

SELECT 
    COUNT(DISTINCT CONCAT(pizza_id,exclusions,extras)) unique_order
FROM customer_orders;
 
--I.2 How many successful orders were delivered by each runner?
SELECT
    runner_id, 
    COUNT(*) success_order
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY 1
ORDER BY 1;

--I.3 How many of each type of pizza was delivered?
SELECT 
    c.pizza_id,
    COUNT(r.order_id) delivered_pizza
FROM runner_orders r
INNER JOIN customer_orders c
    ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY 1;

-- I.4 How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
    c.customer_id,
    pn.pizza_name,
    COUNT(*) ordered_pizza
FROM customer_orders c
INNER JOIN pizza_names pn
    ON c.pizza_id = pn.pizza_id
GROUP BY 1,2
ORDER BY 1,2;
-- not easy to read, need to transpose the pizza_name :)

SELECT
    c.customer_id,
    SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) meatlovers, 
    SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) vegetarian
FROM customer_orders c
GROUP BY 1 
ORDER BY 1;
    
-- I.5 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- probably the term 'change' means 'customization', so I prefer it's to be pizza that had at least 
-- 1 customization i.e. with the exclusions of certain -- toppings or with the addition (extras) of certain toppings

WITH cte AS ( 
SELECT 
    r.order_id,
    c.customer_id,
    c.pizza_id,
    c.exclusions,
    c.extras
FROM customer_orders c
LEFT JOIN runner_orders r
    ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
)
SELECT
    customer_id,
    SUM(CASE 
        WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 
        ELSE 0 END) customized_pizza, 
    SUM(CASE WHEN exclusions IS NULL AND extras IS NULL THEN 1 
        ELSE 0 END) normal_pizza 
FROM cte
GROUP BY 1 
ORDER BY 1;

-- I.6 What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    DATE_PART('hour', order_time::TIMESTAMP) AS order_hour, 
    COUNT(*) AS pizza_ordered
FROM customer_orders
GROUP BY 1
ORDER BY 1;

-- I.7 What was the volume of orders for each day of the week?
SELECT 
    TO_CHAR(order_time, 'Day') order_day, 
    COUNT(*) pizza_ordered
FROM customer_orders
GROUP BY 1, DATE_PART('DOW', order_time::TIMESTAMP)
ORDER BY DATE_PART('DOW', order_time::TIMESTAMP);


-- PART II. Runner and Customer Experience
--II.1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- I tried use DATE_PART but week 53 appeared :(, here using DATE_TRUNC so the date the week start will appear
-- (not only the week ID)
SELECT 
    DATE_TRUNC('week', registration_date)::DATE + 4 week_start,
    DATE_TRUNC('week', registration_date)::DATE + 10 week_end,
    COUNT(runner_id) runner_signed
FROM runners
GROUP BY week_start, week_end
ORDER BY week_start;


--II.2 What was the average time in minutes it took for each runner to arrive at the 
-- Pizza Runner HQ to pickup the order?
-- be aware that the original data from the website has pickup time on year 2020 that will result in 
-- negative when substract with the order time. 
WITH cte AS (
    SELECT
        r.runner_id,
        c.order_id,
        ROUND(((EXTRACT(minutes FROM CAST(r.pickup_time AS timestamp) - c.order_time)*60 + 
        EXTRACT(seconds FROM CAST(r.pickup_time AS timestamp)- c.order_time))/60),2) pickup_interval
    FROM runner_orders r
    JOIN customer_orders c
        ON c.order_id = r.order_id
    WHERE r.cancellation IS NULL
    GROUP BY 2,1, pickup_interval
)
SELECT 
    runner_id,
    COUNT(*) number_orders,
    ROUND(AVG(pickup_interval),2) avg_pickup_time
FROM cte
GROUP BY 1;
-- this is for average per runner, if want to see the average for all runner, we can just remove the 
-- runner_id and COUNT(*)


--II.3 Is there any relationship between the number of pizzas and how long the order takes to prepare?
    SELECT
        r.runner_id,
        c.order_id,
        COUNT(c.pizza_id) pizza_per_order,
        ROUND(((EXTRACT(minutes FROM CAST(r.pickup_time AS timestamp) - c.order_time)*60 + 
        EXTRACT(seconds FROM CAST(r.pickup_time AS timestamp)- c.order_time))/60),2) pickup_interval
    FROM runner_orders r
    JOIN customer_orders c
        ON c.order_id = r.order_id
    WHERE r.cancellation IS NULL
    GROUP BY 2,1, pickup_interval;
    
-- I can say in general yes there is a relationship, however to be totally sure the correlation analysis
-- needs to be done

--II.4 What was the average distance travelled for each customer?
-- perhaps the question a bit vague, as customer doesnt travel to the HQ. 
-- it would be preferable if the question is 'What was the average distance from the HQ to each customer?'
-- with the assumption when customers order the pizza, they can order them from different locations

WITH cte AS (
    SELECT 
        c.customer_id,
        r.order_id, 
        ROUND(AVG(r.distance),2) avg_distance
    FROM runner_orders r
    JOIN customer_orders c
        ON c.order_id = r.order_id
     WHERE r.cancellation IS NULL
    GROUP BY 1,2
)
SELECT 
    customer_id,
    ROUND(AVG(avg_distance),2) avg_distance
FROM cte
GROUP BY 1
ORDER BY 1;


--II.5 What was the difference between the longest and shortest delivery times for all orders?
SELECT
    MAX(duration) - MIN(duration) max_diff_time
FROM runner_orders
WHERE cancellation IS NULL;

--II.6 What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- if we want to see trend, this is similar to asking relationship
-- might have add another parameter such as time of the day when delivery happens and the customer_id
WITH cte AS (
    SELECT
        runner_id,
        order_id,
        DATE_PART('hour', pickup_time::timestamp) hour_of_the_day,
        distance,
        duration,
        ROUND(AVG((distance/duration)*60),2) avg_speed
    FROM runner_orders
    WHERE cancellation IS NULL
    GROUP BY 1,2
    ORDER BY 2,1
)
SELECT 
    DISTINCT c.customer_id,
    cte.*
FROM cte
JOIN customer_orders c
    ON c.order_id = cte.order_id
ORDER BY cte.order_id, cte.runner_id;

-- speed in km/h
-- it is difficult to see the trend without any visualization and the number of data is too small, 
-- but in a glance I can see that it is probably more challenging for a runner to deliver to customer 103 during the day? 
-- perhaps there is traffic or the terrain to place 103 is more difficult. 
-- Runner 2 can deliver faster during the night to the other 2 customers.
-- Also for runner 1 and 2, it seems that their speed increases the more they take the orders. 

--II.7 What is the successful delivery percentage for each runner?
-- I decided to pass this question because all the cancellation is due to customers or restaurant cancellation.
-- If a customer cancels the order because they wait too long, then it is still runner's duty to deliver
-- the pizza and then restaurant can give some sort of voucher for next order. In such cases, the pickup_time, 
-- duration and distance still need to have figures

-- Part III. Ingredient Optimisation
-- III.1 What are the standard ingredients for each pizza?
-- to approach this I use the temp table first to split the topping_id
DROP TABLE IF EXISTS temp_topping;
CREATE TEMP TABLE temp_topping AS     
SELECT 
    pizza_id,
    CAST(REGEXP_SPLIT_TO_TABLE(toppings, ',\s+' ) AS integer) topping_id
FROM pizza_recipes ;

WITH cte AS(
    SELECT 
        tt.*,
        pt.topping_name
    FROM temp_topping tt
    INNER JOIN pizza_toppings pt
    ON pt.topping_id = tt.topping_id
)
SELECT 
    pn.pizza_name,
    STRING_AGG(cte.topping_name::text, ', ') std_ingridients
FROM cte 
INNER JOIN pizza_names pn
    ON pn.pizza_id = cte.pizza_id
GROUP BY 1
ORDER BY 1;


-- III.2 What was the most commonly added extra?
WITH cte AS (
    SELECT 
        CAST(REGEXP_SPLIT_TO_TABLE(extras, ',\s+' ) AS integer) topping_added
    FROM customer_orders
    WHERE extras IS NOT NULL
)
SELECT
    pt.topping_name,
    COUNT(cte.*) frequency_extras
FROM cte
JOIN pizza_toppings pt
ON pt.topping_id = cte.topping_added
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- III.3 What was the most common exclusion?
-- in this questions, I tried to use UNNEST functions (as part of learning)
WITH cte AS (
    SELECT
        CAST(UNNEST(string_to_array(exclusions, ', ')) AS integer) topping_exclude
    FROM customer_orders
    WHERE exclusions IS NOT NULL
)
SELECT
    pt.topping_name,
    COUNT(cte.*) frequency_exclude
FROM cte
JOIN pizza_toppings pt
ON pt.topping_id = cte.topping_exclude
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

/* III.4 Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */

-- first of all good to have in mind that when doing a lookp we need 
-- to make a unique row, which can be achieved using row_number

SELECT * FROM customer_orders;

-- first lets number the row of customer_orders
DROP TABLE IF EXISTS customer_orders_row;
CREATE TEMP TABLE customer_orders_row AS 
SELECT *,
    ROW_NUMBER() OVER(ORDER BY order_id) row_num
FROM customer_orders
ORDER BY order_id;

-- lets split text to table and union with the null in exclusion and extras
DROP TABLE IF EXISTS temp_name_order;
CREATE TEMP TABLE temp_name_order AS 
WITH cte AS (
SELECT 
    order_id,
    customer_id,
    pizza_id, 
    CAST(REGEXP_SPLIT_TO_TABLE(exclusions, ',\s+' ) AS integer) exclude_id,
    CAST(REGEXP_SPLIT_TO_TABLE(extras, ',\s+' ) AS integer) extra_id,
    order_time,
    ROW_NUMBER() OVER() row_num
FROM customer_orders_row
    UNION
SELECT
    order_id,
    customer_id,
    pizza_id,
    NULL AS exclude_id,
    NULL AS extra_id,
    order_time,
    row_num
FROM customer_orders_row
WHERE exclusions IS NULL AND extras IS NULL    
    )
SELECT 
    cte.order_id,
    cte.customer_id,
    pn.pizza_name, 
    STRING_AGG(pt1.topping_name,', ') as topping_exclude,
    STRING_AGG(pt2.topping_name, ', ') as topping_extra,
    cte.order_time,
    cte.row_num
FROM cte
LEFT JOIN pizza_toppings pt1
ON pt1.topping_id = cte.exclude_id 
LEFT JOIN pizza_toppings pt2
ON pt2.topping_id = cte.extra_id
LEFT JOIN pizza_names pn
ON pn.pizza_id = cte.pizza_id
GROUP BY 
    cte.order_id,
    cte.customer_id,
    pn.pizza_name, 
    cte.order_time,
    cte.row_num;

-- now lets concat the text
SELECT
    order_id,
    customer_id,
    CASE 
        WHEN topping_exclude IS NULL AND topping_extra IS NULL THEN pizza_name
        WHEN topping_exclude IS NOT NULL AND topping_extra IS NULL THEN CONCAT(pizza_name, ' - Exclude ', topping_exclude)
        WHEN topping_exclude IS NULL AND topping_extra IS NOT NULL THEN CONCAT(pizza_name, ' - Extra ', topping_extra)
        ELSE CONCAT(pizza_name, ' - Exclude ', topping_exclude, ' - Extra ', topping_extra)
    END order_name, 
    order_time,
    row_num
FROM temp_name_order;
-- this conditional solution may not be good if there are more than 4 variations. I will learn more on this to make it better.

-- III.5 Generate an alphabetically ordered comma separated ingredient list for each pizza order 
-- from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- approach is by breaking down all toppings for each row, dropping the exclusions, adding the extras and then count the topping_id
-- temp table is created as final 'custom' recipes (and with count topping as well)

DROP TABLE IF EXISTS temp_final_custom ; 
CREATE TEMP TABLE temp_final_custom AS 
WITH cte_recipes AS(
SELECT
    pizza_id, 
    CAST(regexp_split_to_table(toppings, ',\s+') AS integer) topping_id 
FROM pizza_recipes    
), cte_order_recipe AS(
SELECT 
    c.order_id,
    c.customer_id,
    pn.pizza_name, 
    pt.topping_name topping_name,
    c.order_time,
    c.row_num
FROM customer_orders_row c
    LEFT JOIN cte_recipes cr
    ON c.pizza_id = cr.pizza_id
    INNER JOIN pizza_names pn
    ON cr.pizza_id = pn.pizza_id
    INNER JOIN pizza_toppings pt
    ON cr.topping_id = pt.topping_id
), cte_exclusions AS( 
SELECT 
    order_id,
    customer_id,
    pizza_name, 
    CAST(REGEXP_SPLIT_TO_TABLE(topping_exclude, ',\s+' ) AS text)topping_name,
    order_time,
    row_num
    FROM temp_name_order
    WHERE topping_exclude IS NOT NULL
), cte_extras AS (
SELECT
    order_id,
    customer_id,
    pizza_name, 
    CAST(REGEXP_SPLIT_TO_TABLE(topping_extra, ',\s+' ) AS text)topping_name,
    order_time,
    row_num
    FROM temp_name_order
    WHERE topping_extra IS NOT NULL
), cte_union_all AS (
    SELECT * FROM 
        cte_order_recipe
    EXCEPT -- to return the distinct only vs cte_exclusions table
    SELECT * FROM 
        cte_exclusions
    UNION ALL -- adding the records from cte extras
    SELECT * FROM cte_extras
), cte_count_toppings AS (
SELECT *,
    COUNT(*) count_topping
FROM cte_union_all
GROUP BY 
    order_id,
    customer_id,
    pizza_name,
    topping_name,
    order_time,
    row_num
)
SELECT * 
FROM cte_count_toppings 
ORDER BY row_num, order_id, topping_name;

-- STRING AGG & CONCAT TIME!
WITH cte_frequency_topping AS(
SELECT
    order_id,
    customer_id,
    pizza_name,
    CASE WHEN count_topping > 1 THEN CONCAT(count_topping, 'x ', topping_name)
        ELSE topping_name
    END topping_name,
    order_time,
    row_num,
    count_topping
FROM temp_final_custom
ORDER BY row_num, order_id    
), cte_concat_topping AS(
SELECT 
    order_id,
    customer_id,
    pizza_name, -- cannot concat yet
    STRING_AGG(topping_name, ', ') final_recipe,
    order_time,
    row_num
FROM cte_frequency_topping
GROUP BY 
    row_num,
    order_id,
    customer_id,
    pizza_name,
    order_time
)
SELECT
    order_id,
    customer_id,
    CONCAT(pizza_name, ': ', final_recipe) order_detail,
    row_num,
    order_time
FROM cte_concat_topping
ORDER BY row_num, order_id;


-- III.6 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-- key words: 'in all delivered pizza'. Join with runner_orders table and count from the temp table : temp_final_custom
SELECT 
    topping_name,
    SUM(count_topping) total_topping
FROM temp_final_custom
WHERE order_id NOT IN ( 
    SELECT order_id 
    FROM runner_orders
    WHERE cancellation IS NOT NULL
    )
GROUP BY 1
ORDER BY 2 DESC;

-- if the question is 'in all ordered pizza', then it is only counted from the temp table : temp_final_custom
SELECT 
    topping_name,
    SUM(count_topping) total_topping
FROM temp_final_custom
GROUP BY 1
ORDER BY 2 DESC;

-- Part IV. Pricing and Ratings
-- IV.1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
-- how much money has Pizza Runner made so far if there are no delivery fees?
SELECT 
    SUM(CASE WHEN pizza_id = 1 THEN 12
        ELSE 10 END) revenue_from_delivered 
        -- in a bigger database case where pizza variation is many, 
        -- it may need to create a new dimension table for pricing reference
FROM customer_orders
    WHERE order_id NOT IN ( 
    SELECT order_id 
    FROM runner_orders
    WHERE cancellation IS NOT NULL
    );

-- IV.2 What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
-- because the condition of the cheese costs $1 extra, then row_number approach shall be used again
-- also I answer this only for 'delivered' pizza not 'ordered' pizza
WITH cte_split_extras AS ( 
SELECT
    order_id,
    customer_id,
    pizza_name, 
    CAST(REGEXP_SPLIT_TO_TABLE(topping_extra, ',\s+' ) AS text)topping_extra,
    order_time,
    row_num
    FROM temp_name_order
    WHERE topping_extra IS NOT NULL
), cte_cost_extras AS (
SELECT 
    order_id,
    customer_id,
    CASE WHEN topping_extra = 'Cheese' THEN 1+1 
        ELSE 1 END add_cost,
    order_time,
    row_num
FROM cte_split_extras 
    WHERE order_id NOT IN ( 
    SELECT order_id 
    FROM runner_orders
    WHERE cancellation IS NOT NULL)
), cte_base_cost AS (
SELECT 
    order_id,
    customer_id,
    CASE WHEN pizza_name='Meat Lovers' THEN 12
        ELSE 10 END add_cost,
    order_time,
    row_num
FROM temp_name_order
    WHERE order_id NOT IN ( 
    SELECT order_id 
    FROM runner_orders
    WHERE cancellation IS NOT NULL)
), cte_joint_cost AS (
SELECT * FROM cte_base_cost
    UNION ALL 
SELECT * FROM cte_cost_extras
)
SELECT SUM(add_cost) total_cost
    FROM cte_joint_cost;
    
-- IV.3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - generate a schema for this new table and 
-- insert your own data for ratings for each successful customer order between 1 to 5.

-- lets input ratings based on the delivery time, for assumption. 
-- 0-10 minutes = 5, 10-15 minutes = 4, 15-20 = 3, 20-30 = 2, else is 1

DROP TABLE IF EXISTS runner_ratings;
CREATE TABLE runner_ratings ("order_id" int, "runner_id" int, "rating" int);

INSERT INTO runner_ratings
SELECT
    order_id,
    runner_id,
    CASE WHEN duration BETWEEN 0 AND 10 THEN 5
        WHEN duration BETWEEN 11 AND 15 THEN 4
        WHEN duration BETWEEN 16 AND 20 THEN 3
        WHEN duration BETWEEN 21 AND 30 THEN 2
    ELSE 1 END rating
FROM runner_orders
WHERE cancellation IS NULL;

/* IV.4 Using your newly generated table - can you join all of the information together to form a table 
which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
*/ 

-- let's use AGE function to substract pickup_time with order_time. I can use the table on previous question
-- with EXTRACT function but I will try this function
SELECT 
    c.order_id,
    ro.runner_id,
    rr.rating,
    c.order_time,
    ro.pickup_time,
    DATE_PART('minute', AGE(ro.pickup_time::timestamp,c.order_time)) AS processing_time,
    ro.duration,
    ROUND(AVG((ro.distance/ro.duration)*60),2) avg_speed,
    COUNT(c.*) num_pizza
FROM customer_orders c
INNER JOIN runner_orders ro
    ON c.order_id = ro.order_id
LEFT JOIN runner_ratings rr
    ON c.order_id = rr.order_id
WHERE ro.cancellation IS NULL
GROUP BY 
    c.order_id,
    ro.runner_id,
    rr.rating,
    c.order_time,
    ro.pickup_time,
    ro.duration,
    ro.distance ; 

-- IV.5 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is 
-- paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH cte_co AS (
SELECT 
    *,
    CASE WHEN pizza_id = 1 THEN 12
        ELSE 10 END pizza_revenue
FROM customer_orders
), cte_runner_orders AS ( 
SELECT 
    ro.order_id,
    SUM(cte_co.pizza_revenue) pizza_revenue, 
    ROUND(ro.distance*0.3,2) delivery_fee,
    (cte_co.pizza_revenue - ROUND(ro.distance*0.3,2)) revenue_left
FROM cte_co
INNER JOIN runner_orders ro
    ON cte_co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY ro.order_id,
    ro.distance,
    cte_co.pizza_revenue
ORDER BY 1
)
SELECT SUM(revenue_left) leftover_revenue
    FROM cte_runner_orders


-- BONUS QUESTIONS: If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
-- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added 
-- to the Pizza Runner menu?

-- In my solution, the pricing part where the conditional command is limited to only Meatlovers and Vegetarian
-- will be impacted if additional type of pizza is added. Thus, it needs to be modified with a new dimension table and joins function.

-- Anyway, one of my notes in this study case is currently I have limited knowledge about REGEX 
-- so I need to get used to it and practice more
