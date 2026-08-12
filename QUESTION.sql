-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS TOTAL_ORDERS
FROM
    ORDERS;
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS TOTAL_REVENUE
FROM
    orders_details
        JOIN
    PIZZAS ON pizzas.pizza_id = orders_details.PIZZA_ID;
-- Identify the highest-priced pizza.
SELECT 
    PIZZA_TYPES.NAME, PIZZAS.PRICE
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZAS.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
ORDER BY PIZZAS.PRICE DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    PIZZAS.SIZE, SUM(ORDERS_DETAILS.QUANTITY) AS TOTAL_ORDERED
FROM
    PIZZAS
        JOIN
    ORDERS_DETAILS ON PIZZAS.PIZZA_ID = ORDERS_DETAILS.PIZZA_ID
GROUP BY PIZZAS.SIZE
ORDER BY TOTAL_ORDERED DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    PIZZA_TYPES.NAME AS PIZZA_NAME,
    SUM(ORDERS_DETAILS.QUANTITY) AS TOTAL_ORDERED
FROM
    PIZZA_TYPES
        JOIN
    PIZZAS ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
        JOIN
    ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_NAME
ORDER BY TOTAL_ORDERED DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(orders_details.quantity) As Total_Orders
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;

-- Determine the distribution of orders by hour of the day.
SELECT HOUR(ORDER_TIME) AS HOUR, COUNT(ORDER_ID) AS ORDER_COUNT
FROM ORDERS
GROUP BY HOUR(ORDER_TIME);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pizza_types.category,
    COUNT(pizzas.pizza_id) AS total_pizza_variants
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category
ORDER BY total_pizza_variants DESC;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Total_Order), 0) AS Avg_order_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS Total_Order
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) order_orders;
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS Total_Revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT PIZZA_TYPES.CATEGORY,
ROUND(SUM(ORDERS_DETAILS.QUANTITY*PIZZAS.PRICE) / (
SELECT 
    SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id)*100,2) as REVENUE
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZAS.PIZZA_TYPE_ID = PIZZA_TYPES.PIZZA_TYPE_ID JOIN ORDERS_DETAILS
ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.CATEGORY order by REVENUE DESC;
-- Analyze the cumulative revenue generated over time.

SELECT ORDER_DATE, SUM(REVENUE) OVER(ORDER BY ORDER_DATE)AS CUM_REVENUE FROM
(SELECT ORDERS.ORDER_DATE, SUM(ORDERS_DETAILS.QUANTITY * PIZZAS.PRICE) AS REVENUE FROM
ORDERS_DETAILS JOIN PIZZAS ON PIZZAS.PIZZA_ID = ORDERS_DETAILS.PIZZA_ID
JOIN ORDERS ON ORDERS.ORDER_ID = ORDERS_DETAILS.ORDER_ID
group by ORDERS.ORDER_DATE) AS SALES;
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT NAME, REVENUE FROM
(SELECT CATEGORY, NAME, REVENUE,
RANK() OVER(PARTITION BY CATEGORY ORDER BY REVENUE DESC) as RN
FROM
(SELECT PIZZA_TYPES.CATEGORY, PIZZA_TYPES.NAME, SUM((ORDERS_DETAILS.QUANTITY * PIZZAS.PRICE)) AS REVENUE
FROM PIZZA_TYPES JOIN PIZZAS
ON PIZZA_TYPES.PIZZA_TYPE_ID = PIZZAS.PIZZA_TYPE_ID
JOIN ORDERS_DETAILS ON ORDERS_DETAILS.PIZZA_ID = PIZZAS.PIZZA_ID
GROUP BY PIZZA_TYPES.CATEGORY, PIZZA_TYPES.NAME) AS A) AS B
where RN <= 3;