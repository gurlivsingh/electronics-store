-- ============================================================
-- ELECTRONICS STORE MANAGEMENT SYSTEM
-- 07_complex_queries.sql — Joins, Subqueries, Aggregates, Views
-- Course: UCS310 – Database Management Systems
-- Group 2Q21 | Thapar Institute of Engineering & Technology
-- ============================================================

-- ============================================================
-- QUERY 1: INNER JOIN
-- Products with their category names and current stock levels
-- ============================================================
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    p.price,
    i.quantity_in_stock,
    i.reorder_level,
    CASE
        WHEN i.quantity_in_stock = 0 THEN 'Out of Stock'
        WHEN i.quantity_in_stock < i.reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM PRODUCT p
INNER JOIN CATEGORY c ON p.category_id = c.category_id
INNER JOIN INVENTORY i ON p.product_id = i.product_id
ORDER BY c.category_name, p.product_name;


-- ============================================================
-- QUERY 2: LEFT JOIN
-- All customers with their total orders count
-- (includes customers who have never ordered)
-- ============================================================
SELECT
    cust.customer_id,
    CONCAT(cust.first_name, ' ', cust.last_name) AS customer_name,
    cust.email,
    cust.city,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS total_spent
FROM CUSTOMER cust
LEFT JOIN ORDERS o ON cust.customer_id = o.customer_id
GROUP BY cust.customer_id, cust.first_name, cust.last_name, cust.email, cust.city
ORDER BY total_spent DESC;


-- ============================================================
-- QUERY 3: SUBQUERY
-- Products with stock below the average stock level
-- ============================================================
SELECT
    p.product_name,
    p.brand,
    i.quantity_in_stock,
    (SELECT ROUND(AVG(quantity_in_stock), 2) FROM INVENTORY) AS avg_stock
FROM PRODUCT p
JOIN INVENTORY i ON p.product_id = i.product_id
WHERE i.quantity_in_stock < (SELECT AVG(quantity_in_stock) FROM INVENTORY)
ORDER BY i.quantity_in_stock ASC;


-- ============================================================
-- QUERY 4: AGGREGATE + GROUP BY
-- Total revenue per category
-- ============================================================
SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id) AS products_count,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    ROUND(AVG(oi.unit_price), 2) AS avg_selling_price
FROM CATEGORY c
JOIN PRODUCT p ON c.category_id = p.category_id
JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;


-- ============================================================
-- QUERY 5: HAVING
-- Categories with total revenue exceeding ₹50,000
-- ============================================================
SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM CATEGORY c
JOIN PRODUCT p ON c.category_id = p.category_id
JOIN ORDER_ITEMS oi ON p.product_id = oi.product_id
GROUP BY c.category_id, c.category_name
HAVING total_revenue > 50000
ORDER BY total_revenue DESC;


-- ============================================================
-- QUERY 6: CORRELATED SUBQUERY
-- Customers whose total spend exceeds average customer spend
-- ============================================================
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    (SELECT SUM(o.total_amount) FROM ORDERS o WHERE o.customer_id = c.customer_id) AS total_spend
FROM CUSTOMER c
WHERE (
    SELECT SUM(o.total_amount)
    FROM ORDERS o
    WHERE o.customer_id = c.customer_id
) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(total_amount) AS customer_total
        FROM ORDERS
        GROUP BY customer_id
    ) AS avg_table
)
ORDER BY total_spend DESC;


-- ============================================================
-- QUERY 7: RIGHT JOIN
-- All employees with their sales performance
-- (includes employees who haven't processed any orders)
-- ============================================================
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.role,
    COUNT(o.order_id) AS orders_processed,
    COALESCE(SUM(o.total_amount), 0) AS total_sales_value
FROM ORDERS o
RIGHT JOIN EMPLOYEE e ON o.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.role
ORDER BY total_sales_value DESC;


-- ============================================================
-- QUERY 8: NESTED SUBQUERY
-- Top 5 best-selling products by revenue
-- ============================================================
SELECT
    p.product_name,
    p.brand,
    sub.total_qty_sold,
    sub.total_revenue
FROM PRODUCT p
JOIN (
    SELECT product_id,
           SUM(quantity) AS total_qty_sold,
           SUM(quantity * unit_price) AS total_revenue
    FROM ORDER_ITEMS
    GROUP BY product_id
) sub ON p.product_id = sub.product_id
ORDER BY sub.total_revenue DESC
LIMIT 5;


-- ============================================================
-- VIEW 1: vw_order_details
-- Comprehensive order view joining Orders, Items, Products, Customers
-- ============================================================
DROP VIEW IF EXISTS vw_order_details;

CREATE VIEW vw_order_details AS
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS customer_email,
    c.phone AS customer_phone,
    CONCAT(e.first_name, ' ', e.last_name) AS handled_by,
    p.product_name,
    p.brand,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.subtotal,
    o.total_amount AS order_total,
    o.payment_method,
    o.order_status
FROM ORDERS o
JOIN CUSTOMER c ON o.customer_id = c.customer_id
JOIN EMPLOYEE e ON o.employee_id = e.employee_id
JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id
JOIN PRODUCT p ON oi.product_id = p.product_id
JOIN CATEGORY cat ON p.category_id = cat.category_id;

-- Test the view
SELECT * FROM vw_order_details ORDER BY order_id, product_name;


-- ============================================================
-- VIEW 2: vw_inventory_status
-- Quick inventory dashboard showing stock health
-- ============================================================
DROP VIEW IF EXISTS vw_inventory_status;

CREATE VIEW vw_inventory_status AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    c.category_name,
    p.price,
    i.quantity_in_stock,
    i.reorder_level,
    i.last_restocked,
    CASE
        WHEN i.quantity_in_stock = 0 THEN 'OUT OF STOCK'
        WHEN i.quantity_in_stock < i.reorder_level THEN 'LOW STOCK'
        WHEN i.quantity_in_stock < i.reorder_level * 2 THEN 'MODERATE'
        ELSE 'HEALTHY'
    END AS stock_health,
    (i.quantity_in_stock * p.price) AS stock_value
FROM PRODUCT p
JOIN CATEGORY c ON p.category_id = c.category_id
JOIN INVENTORY i ON p.product_id = i.product_id
WHERE p.is_active = TRUE;

-- Test the view
SELECT * FROM vw_inventory_status ORDER BY stock_health, product_name;


-- ============================================================
-- VIEW 3: vw_customer_summary
-- Customer analytics view
-- ============================================================
DROP VIEW IF EXISTS vw_customer_summary;

CREATE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.city,
    c.registration_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS lifetime_spend,
    MAX(o.order_date) AS last_order_date
FROM CUSTOMER c
LEFT JOIN ORDERS o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.city, c.registration_date;

SELECT * FROM vw_customer_summary ORDER BY lifetime_spend DESC;


SELECT 'All complex queries and views created successfully!' AS status;
