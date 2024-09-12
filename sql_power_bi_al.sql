CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    warehouse_id INT
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(255)
);
CREATE TABLE warehouses (
    warehouse_id INT PRIMARY KEY,
    city VARCHAR(255)
);
SELECT DISTINCT o.customer_id
FROM orders o
JOIN order_lines ol ON o.order_id = ol.order_id
JOIN products p ON ol.product_id = p.product_id
WHERE o.order_date BETWEEN '2023-08-01' AND '2023-08-15'
AND p.category = 'Корм для животных'
AND p.product_name != 'Корм Kitekat для кошек, с кроликом в соусе, 85 г'
GROUP BY o.customer_id
HAVING COUNT(DISTINCT ol.product_id) >= 2;

SELECT p.product_name, COUNT(ol.product_id) AS product_count
FROM orders o
JOIN order_lines ol ON o.order_id = ol.order_id
JOIN products p ON ol.product_id = p.product_id
JOIN warehouses w ON o.warehouse_id = w.warehouse_id
WHERE o.order_date BETWEEN '2023-08-15' AND '2023-08-30'
AND w.city = 'Санкт-Петербург'
GROUP BY p.product_name
ORDER BY product_count DESC
LIMIT 5;


