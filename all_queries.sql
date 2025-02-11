-- Retrieve the total number of orders placed

use pizzahut

select count(order_id) as total_orders
from orders


-- Calculate the total revenue generated from pizza sales.

SELECT 
ROUND(SUM(quantity * price), 0) AS total_revenue
FROM
order_details p1
JOIN
pizzas p2 ON p1.pizza_id = p2.pizza_id

-- Identify the highest-priced pizza.

with cte as (select name ,price,
dense_rank() over(order by price desc) as r1
from pizzas p1
join pizza_types p2
on p1.pizza_type_id=p2.pizza_type_id
order by price desc)

select name,price
from cte
where r1=1

-- Identify the most common pizza size ordered.

SELECT 
    size, COUNT(size) AS common_size
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY common_size DESC;


-- Identify the most common pizza quantity ordered.

SELECT 
    quantity, COUNT(quantity) AS common_quantity
FROM
    order_details
GROUP BY quantity
ORDER BY common_quantity DESC

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, SUM(quantity) AS no_of_quantity
FROM
    pizza_types p1
        JOIN
    pizzas p2
        JOIN
    order_details p3 ON p1.pizza_type_id = p2.pizza_type_id
        AND p2.pizza_id = p3.pizza_id
GROUP BY name
ORDER BY no_of_quantity DESC

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    category, SUM(quantity) AS total_quantity
FROM
    pizza_types p1
        JOIN
    pizzas p2
        JOIN
    order_details p3 ON p1.pizza_type_id = p2.pizza_type_id
        AND p2.pizza_id = p3.pizza_id
GROUP BY category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day

select hour(order_time) as hour_time, count(order_id) as no_of_orders
from orders
group by hour_time 

-- Join relevant tables to find the category-wise distribution of pizzas
-- names
select category, group_concat(name separator ',') as pizzas
from pizza_types
group by category

-- numbers
select category, count(name) as pizzas
from pizza_types
group by category

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_pizzas), 0) Avg_no_of_pizza_ordered_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) AS total_pizzas
    FROM
        orders o1
    JOIN order_details o2 ON o1.order_id = o2.order_id
    GROUP BY order_date) AS order_quantity

-- Determine the top 3 most ordered pizza types based on revenue

select name, sum(quantity*price) as revenue
from order_details p1
join pizzas p2
on p1.pizza_id=p2.pizza_id
join pizza_types p3
on p2.pizza_type_id=p3.pizza_type_id
group by name
order by revenue desc
limit 3

-- Calculate the percentage contribution of each pizza type to total revenue

SELECT 
    category,
    ROUND((SUM(quantity * price) / (SELECT 
                    ROUND(SUM(quantity * price), 0) AS total_revenue
                FROM
                    order_details p1
                        JOIN
                    pizzas p2 ON p1.pizza_id = p2.pizza_id)) * 100,
            2) AS revenue_percentage
FROM
    order_details p1
        JOIN
    pizzas p2 ON p1.pizza_id = p2.pizza_id
        JOIN
    pizza_types p3 ON p2.pizza_type_id = p3.pizza_type_id
GROUP BY category
ORDER BY revenue_percentage DESC

-- Analyze the cumulative revenue generated over time.

select order_date, round(sum(quantity*price),2) as revenue,
round(sum(round(sum(quantity*price),2)) over(order by order_date),2) as cumulative_revenue
from orders p1
join order_details p2
on p1.order_id=p2.order_id
join pizzas p3
on p2.pizza_id=p3.pizza_id
group by order_date

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue from
(select category,name, revenue,
row_number() over(partition by category order by revenue desc) as r from
(SELECT 
    category, name, ROUND(SUM(quantity * price), 2) AS revenue
FROM
    order_details p1
        JOIN
    pizzas p2 ON p1.pizza_id = p2.pizza_id
        JOIN
    pizza_types AS p3 ON p2.pizza_type_id = p3.pizza_type_id
group by category, name) as a) as b
where r<=3
