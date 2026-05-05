-- Pizza Sales Data Analysis Queries
-- Author: Your Name

USE pizzahut;

--------------------------------------------------

-- 1. Total Number of Orders
SELECT COUNT(order_id) AS total_orders
FROM orders;

--------------------------------------------------

-- 2. Total Revenue
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON p.pizza_id = od.pizza_id;

--------------------------------------------------

-- 3. Highest Priced Pizza
SELECT pt.name, p.price
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

--------------------------------------------------

-- 4. Most Common Pizza Size
SELECT p.size, COUNT(od.order_details_id) AS order_count
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

--------------------------------------------------

-- 5. Top 5 Most Ordered Pizzas
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

--------------------------------------------------

-- 6. Category-wise Quantity
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_quantity DESC;

--------------------------------------------------

-- 7. Orders by Hour (Peak Time)
SELECT HOUR(order_time) AS hour, COUNT(order_id) AS total_orders
FROM orders
GROUP BY hour
ORDER BY total_orders DESC;

--------------------------------------------------

-- 8. Category Distribution
SELECT category, COUNT(name) AS total_pizzas
FROM pizza_types
GROUP BY category;

--------------------------------------------------

-- 9. Average Pizzas Ordered Per Day
SELECT ROUND(AVG(quantity), 0) AS avg_pizza_per_day
FROM (
    SELECT o.order_date, SUM(od.quantity) AS quantity
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date
) AS daily_orders;

--------------------------------------------------

-- 10. Top 3 Pizzas by Revenue
SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types pt
JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

--------------------------------------------------

-- 11. Revenue Contribution by Category (%)
SELECT pt.category,
ROUND(SUM(od.quantity * p.price) /
    (SELECT SUM(od.quantity * p.price)
     FROM order_details od
     JOIN pizzas p ON p.pizza_id = od.pizza_id) * 100, 2) AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;

--------------------------------------------------

-- 12. Cumulative Revenue Over Time
SELECT order_date,
SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT o.order_date,
           SUM(od.quantity * p.price) AS revenue
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN pizzas p ON p.pizza_id = od.pizza_id
    GROUP BY o.order_date
) AS daily_revenue;

--------------------------------------------------

-- 13. Top 3 Pizzas per Category (Revenue)
SELECT category, name, revenue
FROM (
    SELECT pt.category,
           pt.name,
           SUM(od.quantity * p.price) AS revenue,
           RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_num
    FROM pizza_types pt
    JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details od ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name
) ranked
WHERE rank_num <= 3;

--------------------------------------------------
