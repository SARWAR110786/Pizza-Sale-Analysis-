-- ====================================================================
-- PIZZA SALES DATA ANALYTICS PROJECT (MYSQL SCRIPT)
-- ====================================================================

-- CREATE DATABASE
CREATE DATABASE IF NOT EXISTS pizza_db;
USE pizza_db;

-- --------------------------------------------------------------------
-- BASIC QUESTIONS
-- --------------------------------------------------------------------

-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders 
FROM 
    orders;


-- 2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM 
    order_details
JOIN 
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


-- 3. Identify the highest-priced pizza.
SELECT 
    pizza_types.name, 
    pizzas.price
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY 
    pizzas.price DESC
LIMIT 1;


-- 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size, 
    COUNT(order_details.order_details_id) AS order_count
FROM 
    order_details
JOIN 
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizzas.size
ORDER BY 
    order_count DESC
LIMIT 1;


-- 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, 
    SUM(order_details.quantity) AS total_quantity
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.name
ORDER BY 
    total_quantity DESC
LIMIT 5;


-- --------------------------------------------------------------------
-- INTERMEDIATE QUESTIONS
-- --------------------------------------------------------------------

-- 1. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category, 
    SUM(order_details.quantity) AS total_quantity
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    total_quantity DESC;


-- 2. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS order_hour, 
    COUNT(order_id) AS total_orders
FROM 
    orders
GROUP BY 
    HOUR(order_time)
ORDER BY 
    order_hour;


-- 3. Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, 
    COUNT(name) AS total_pizza_types
FROM 
    pizza_types
GROUP BY 
    category;


-- 4. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total_pizzas_per_day), 0) AS avg_pizzas_ordered_per_day
FROM (
    SELECT 
        orders.order_date, 
        SUM(order_details.quantity) AS total_pizzas_per_day
    FROM 
        orders
    JOIN 
        order_details ON orders.order_id = order_details.order_id
    GROUP BY 
        orders.order_date
) AS daily_sales_summary;


-- 5. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name, 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.name
ORDER BY 
    total_revenue DESC
LIMIT 3;


-- --------------------------------------------------------------------
-- ADVANCED QUESTIONS
-- --------------------------------------------------------------------

-- 1. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / 
          (SELECT SUM(order_details.quantity * pizzas.price) 
           FROM order_details 
           JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100, 2) AS percentage_revenue_contribution
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category
ORDER BY 
    percentage_revenue_contribution DESC;


-- 2. Analyze the cumulative revenue generated over time.
SELECT 
    order_date,
    ROUND(SUM(daily_revenue) OVER (ORDER BY order_date), 2) AS cumulative_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(order_details.quantity * pizzas.price) AS daily_revenue
    FROM 
        order_details
    JOIN 
        pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN 
        orders ON order_details.order_id = orders.order_id
    GROUP BY 
        orders.order_date
) AS daily_sales;


-- 3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH ranked_pizzas AS (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue,
        RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS revenue_rank
    FROM 
        pizza_types
    JOIN 
        pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN 
        order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY 
        pizza_types.category, 
        pizza_types.name
)
SELECT 
    category,
    name,
    ROUND(revenue, 2) AS revenue
FROM 
    ranked_pizzas
WHERE 
    revenue_rank <= 3;
