# Pizza Sales SQL Data Analysis

## Overview
This SQL project analyzes pizza sales data to uncover insights about order patterns, revenue distribution, and popular pizza categories. The dataset consists of multiple tables, including orders, pizzas, pizza types, and order details.

## Dataset
The analysis is performed on the following tables:
- **orders**: Contains order details with timestamps.
- **order_details**: Stores information about the quantity of pizzas ordered.
- **pizzas**: Includes pizza details such as size, price, and type.
- **pizza_types**: Provides additional details about pizza categories and names.

## SQL Queries and Insights

### 1. Total Orders
Retrieves the total number of orders placed.
```sql
SELECT COUNT(order_id) AS total_orders FROM orders;
```

### 2. Total Revenue
Calculates the total revenue generated from pizza sales.
```sql
SELECT ROUND(SUM(quantity * price), 0) AS total_revenue
FROM order_details p1
JOIN pizzas p2 ON p1.pizza_id = p2.pizza_id;
```

### 3. Highest-Priced Pizza
Finds the most expensive pizza.
```sql
WITH cte AS (
    SELECT name, price,
           DENSE_RANK() OVER(ORDER BY price DESC) AS r1
    FROM pizzas p1
    JOIN pizza_types p2 ON p1.pizza_type_id = p2.pizza_type_id
)
SELECT name, price FROM cte WHERE r1 = 1;
```

### 4. Most Common Pizza Size Ordered
Identifies the most frequently ordered pizza size.
```sql
SELECT size, COUNT(size) AS common_size
FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY common_size DESC;
```

### 5. Most Common Pizza Quantity Ordered
```sql
SELECT quantity, COUNT(quantity) AS common_quantity
FROM order_details
GROUP BY quantity
ORDER BY common_quantity DESC;
```

### 6. Top 5 Most Ordered Pizza Types
Retrieves the top 5 most frequently ordered pizza types.
```sql
SELECT name, SUM(quantity) AS no_of_quantity
FROM pizza_types p1
JOIN pizzas p2 ON p1.pizza_type_id = p2.pizza_type_id
JOIN order_details p3 ON p2.pizza_id = p3.pizza_id
GROUP BY name
ORDER BY no_of_quantity DESC
LIMIT 5;
```

### 7. Total Quantity Ordered Per Pizza Category
```sql
SELECT category, SUM(quantity) AS total_quantity
FROM pizza_types p1
JOIN pizzas p2 ON p1.pizza_type_id = p2.pizza_type_id
JOIN order_details p3 ON p2.pizza_id = p3.pizza_id
GROUP BY category
ORDER BY total_quantity DESC;
```

### 8. Orders Distribution by Hour
Finds the number of orders placed at each hour of the day.
```sql
SELECT HOUR(order_time) AS hour_time, COUNT(order_id) AS no_of_orders
FROM orders
GROUP BY hour_time;
```

### 9. Category-wise Distribution of Pizza Names
```sql
SELECT category, GROUP_CONCAT(name SEPARATOR ', ') AS pizzas
FROM pizza_types
GROUP BY category;
```

### 10. Average Number of Pizzas Ordered Per Day
```sql
SELECT ROUND(AVG(total_pizzas), 0) AS Avg_no_of_pizza_ordered_per_day
FROM (
    SELECT order_date, SUM(quantity) AS total_pizzas
    FROM orders o1
    JOIN order_details o2 ON o1.order_id = o2.order_id
    GROUP BY order_date
) AS order_quantity;
```

### 11. Top 3 Most Ordered Pizza Types by Revenue
```sql
SELECT name, SUM(quantity * price) AS revenue
FROM order_details p1
JOIN pizzas p2 ON p1.pizza_id = p2.pizza_id
JOIN pizza_types p3 ON p2.pizza_type_id = p3.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;
```

### 12. Percentage Contribution of Each Pizza Type to Total Revenue
```sql
SELECT category,
       ROUND((SUM(quantity * price) /
       (SELECT ROUND(SUM(quantity * price), 0) FROM order_details p1
        JOIN pizzas p2 ON p1.pizza_id = p2.pizza_id)) * 100, 2) AS revenue_percentage
FROM order_details p1
JOIN pizzas p2 ON p1.pizza_id = p2.pizza_id
JOIN pizza_types p3 ON p2.pizza_type_id = p3.pizza_type_id
GROUP BY category
ORDER BY revenue_percentage DESC;
```

### 13. Cumulative Revenue Over Time
```sql
SELECT order_date,
       ROUND(SUM(quantity * price), 2) AS revenue,
       ROUND(SUM(ROUND(SUM(quantity * price), 2)) OVER(ORDER BY order_date), 2) AS cumulative_revenue
FROM orders p1
JOIN order_details p2 ON p1.order_id = p2.order_id
JOIN pizzas p3 ON p2.pizza_id = p3.pizza_id
GROUP BY order_date;
```

### 14. Top 3 Most Ordered Pizza Types by Revenue Per Category
```sql
SELECT category, name, revenue
FROM (
    SELECT category, name, revenue,
           ROW_NUMBER() OVER(PARTITION BY category ORDER BY revenue DESC) AS r
    FROM (
        SELECT category, name, ROUND(SUM(quantity * price), 2) AS revenue
        FROM order_details p1
        JOIN pizzas p2 ON p1.pizza_id = p2.pizza_id
        JOIN pizza_types p3 ON p2.pizza_type_id = p3.pizza_type_id
        GROUP BY category, name
    ) AS a
) AS b
WHERE r <= 3;
```

## Conclusion
This project provides insights into pizza sales performance, customer ordering trends, and revenue distribution. The SQL queries highlight key business metrics, such as the most popular pizzas, revenue-generating items, and sales trends over time.

## How to Use
1. Clone this repository.
2. Import the dataset into MySQL.
3. Run the SQL queries to generate insights.

## Tools Used
- MySQL
- SQL Window Functions
- Aggregate Functions
- Common Table Expressions (CTEs)

## Author
[Hrithick barani]
[hrithicbarani555@gmail.com]

