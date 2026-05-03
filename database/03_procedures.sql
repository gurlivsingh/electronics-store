-- ============================================================
-- ELECTRONICS STORE MANAGEMENT SYSTEM
-- 03_procedures.sql — Stored Procedures
-- Course: UCS310 – Database Management Systems
-- Group 2Q21 | Thapar Institute of Engineering & Technology
-- ============================================================

DELIMITER $$

-- ============================================================
-- PROCEDURE 1: sp_add_product
-- Adds a new product and automatically creates an inventory
-- record with initial stock of 0.
-- Demonstrates: INSERT, Exception Handling, Transaction
-- ============================================================
DROP PROCEDURE IF EXISTS sp_add_product$$

CREATE PROCEDURE sp_add_product(
    IN p_name       VARCHAR(200),
    IN p_category   INT,
    IN p_price      DECIMAL(12,2),
    IN p_brand      VARCHAR(100),
    IN p_specs      TEXT,
    OUT p_product_id INT
)
BEGIN
    -- Exception Handling: Declare handlers
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Failed to add product. Transaction rolled back.';
    END;

    DECLARE EXIT HANDLER FOR 1062  -- Duplicate entry
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: A product with this name already exists in this category.';
    END;

    -- Validate inputs
    IF p_price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Price must be greater than zero.';
    END IF;

    IF p_name IS NULL OR p_name = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Product name cannot be empty.';
    END IF;

    -- Begin Transaction
    START TRANSACTION;

        -- Insert the product
        INSERT INTO PRODUCT (product_name, category_id, price, brand, specifications)
        VALUES (p_name, p_category, p_price, p_brand, p_specs);

        SET p_product_id = LAST_INSERT_ID();

        -- Automatically create inventory record with 0 stock
        INSERT INTO INVENTORY (product_id, quantity_in_stock, reorder_level)
        VALUES (p_product_id, 0, 10);

    COMMIT;

    SELECT CONCAT('Product "', p_name, '" added successfully with ID: ', p_product_id) AS result;
END$$


-- ============================================================
-- PROCEDURE 2: sp_register_customer
-- Registers a new customer with duplicate validation.
-- Demonstrates: Exception Handling for UNIQUE constraints
-- ============================================================
DROP PROCEDURE IF EXISTS sp_register_customer$$

CREATE PROCEDURE sp_register_customer(
    IN p_first_name     VARCHAR(100),
    IN p_last_name      VARCHAR(100),
    IN p_email          VARCHAR(150),
    IN p_phone          VARCHAR(15),
    IN p_address        TEXT,
    IN p_city           VARCHAR(100),
    OUT p_customer_id   INT
)
BEGIN
    DECLARE v_email_count INT DEFAULT 0;
    DECLARE v_phone_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Failed to register customer.';
    END;

    -- Check for duplicate email
    SELECT COUNT(*) INTO v_email_count FROM CUSTOMER WHERE email = p_email;
    IF v_email_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: A customer with this email already exists.';
    END IF;

    -- Check for duplicate phone
    SELECT COUNT(*) INTO v_phone_count FROM CUSTOMER WHERE phone = p_phone;
    IF v_phone_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: A customer with this phone number already exists.';
    END IF;

    -- Validate email format
    IF p_email NOT LIKE '%_@_%.__%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Invalid email format.';
    END IF;

    START TRANSACTION;

        INSERT INTO CUSTOMER (first_name, last_name, email, phone, address, city)
        VALUES (p_first_name, p_last_name, p_email, p_phone, p_address, p_city);

        SET p_customer_id = LAST_INSERT_ID();

    COMMIT;

    SELECT CONCAT('Customer "', p_first_name, ' ', p_last_name,
                  '" registered with ID: ', p_customer_id) AS result;
END$$


-- ============================================================
-- PROCEDURE 3: sp_place_order
-- Creates a new order header.
-- Demonstrates: Transaction with SAVEPOINT
-- ============================================================
DROP PROCEDURE IF EXISTS sp_place_order$$

CREATE PROCEDURE sp_place_order(
    IN p_customer_id    INT,
    IN p_employee_id    INT,
    IN p_payment_method VARCHAR(50),
    OUT p_order_id      INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Failed to place order. Transaction rolled back.';
    END;

    START TRANSACTION;

        SAVEPOINT before_order;

        -- Insert order header (trigger trg_before_order_insert validates customer/employee)
        INSERT INTO ORDERS (customer_id, employee_id, payment_method, order_status)
        VALUES (p_customer_id, p_employee_id, p_payment_method, 'Pending');

        SET p_order_id = LAST_INSERT_ID();

    COMMIT;

    SELECT CONCAT('Order #', p_order_id, ' created successfully.') AS result;
END$$


-- ============================================================
-- PROCEDURE 4: sp_add_order_item
-- Adds an item to an existing order with stock validation.
-- Demonstrates: Exception Handling, Stock check, SAVEPOINT
-- ============================================================
DROP PROCEDURE IF EXISTS sp_add_order_item$$

CREATE PROCEDURE sp_add_order_item(
    IN p_order_id       INT,
    IN p_product_id     INT,
    IN p_quantity       INT
)
BEGIN
    DECLARE v_available_stock    INT DEFAULT 0;
    DECLARE v_unit_price         DECIMAL(12,2) DEFAULT 0;
    DECLARE v_order_exists       INT DEFAULT 0;
    DECLARE v_product_exists     INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK TO SAVEPOINT before_item;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Failed to add item. Rolled back to savepoint.';
    END;

    -- Validate order exists
    SELECT COUNT(*) INTO v_order_exists FROM ORDERS WHERE order_id = p_order_id;
    IF v_order_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Order does not exist.';
    END IF;

    -- Validate product exists
    SELECT COUNT(*) INTO v_product_exists FROM PRODUCT WHERE product_id = p_product_id;
    IF v_product_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Product does not exist.';
    END IF;

    -- Validate quantity
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Quantity must be greater than zero.';
    END IF;

    -- Check available stock
    SELECT quantity_in_stock INTO v_available_stock
    FROM INVENTORY
    WHERE product_id = p_product_id;

    IF v_available_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Insufficient stock for this product.';
    END IF;

    -- Get the product price
    SELECT price INTO v_unit_price FROM PRODUCT WHERE product_id = p_product_id;

    START TRANSACTION;

        SAVEPOINT before_item;

        -- Insert order item (trigger will auto-decrement stock and update total)
        INSERT INTO ORDER_ITEMS (order_id, product_id, quantity, unit_price)
        VALUES (p_order_id, p_product_id, p_quantity, v_unit_price);

    COMMIT;

    SELECT CONCAT('Added ', p_quantity, ' unit(s) of product #', p_product_id,
                  ' to order #', p_order_id) AS result;
END$$


-- ============================================================
-- PROCEDURE 5: sp_update_stock
-- Restocks inventory for a given product.
-- Demonstrates: UPDATE, Timestamp management
-- ============================================================
DROP PROCEDURE IF EXISTS sp_update_stock$$

CREATE PROCEDURE sp_update_stock(
    IN p_product_id         INT,
    IN p_quantity_to_add    INT
)
BEGIN
    DECLARE v_product_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Failed to update stock.';
    END;

    -- Validate product exists
    SELECT COUNT(*) INTO v_product_exists FROM INVENTORY WHERE product_id = p_product_id;
    IF v_product_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No inventory record found for this product.';
    END IF;

    IF p_quantity_to_add <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Restock quantity must be greater than zero.';
    END IF;

    START TRANSACTION;

        UPDATE INVENTORY
        SET quantity_in_stock = quantity_in_stock + p_quantity_to_add,
            last_restocked = NOW()
        WHERE product_id = p_product_id;

    COMMIT;

    SELECT CONCAT('Restocked product #', p_product_id,
                  ' with ', p_quantity_to_add, ' units.') AS result;
END$$


-- ============================================================
-- PROCEDURE 6: sp_generate_sales_report
-- Uses a CURSOR to iterate through orders in a date range
-- and produce a detailed sales report.
-- Demonstrates: CURSOR, LOOP, Aggregate computation
-- ============================================================
DROP PROCEDURE IF EXISTS sp_generate_sales_report$$

CREATE PROCEDURE sp_generate_sales_report(
    IN p_start_date DATE,
    IN p_end_date   DATE
)
BEGIN
    DECLARE v_order_id          INT;
    DECLARE v_customer_name     VARCHAR(201);
    DECLARE v_order_date        DATETIME;
    DECLARE v_total             DECIMAL(12,2);
    DECLARE v_status            VARCHAR(30);
    DECLARE v_grand_total       DECIMAL(12,2) DEFAULT 0;
    DECLARE v_order_count       INT DEFAULT 0;
    DECLARE v_done              INT DEFAULT 0;

    -- Declare the CURSOR
    DECLARE sales_cursor CURSOR FOR
        SELECT o.order_id,
               CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
               o.order_date,
               o.total_amount,
               o.order_status
        FROM ORDERS o
        JOIN CUSTOMER c ON o.customer_id = c.customer_id
        WHERE DATE(o.order_date) BETWEEN p_start_date AND p_end_date
        ORDER BY o.order_date;

    -- Handler for cursor end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Create a temporary table for the report output
    DROP TEMPORARY TABLE IF EXISTS tmp_sales_report;
    CREATE TEMPORARY TABLE tmp_sales_report (
        order_id        INT,
        customer_name   VARCHAR(201),
        order_date      DATETIME,
        total_amount    DECIMAL(12,2),
        order_status    VARCHAR(30)
    );

    -- Open cursor and iterate
    OPEN sales_cursor;

    read_loop: LOOP
        FETCH sales_cursor INTO v_order_id, v_customer_name, v_order_date, v_total, v_status;

        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Insert each row into temp report table
        INSERT INTO tmp_sales_report
        VALUES (v_order_id, v_customer_name, v_order_date, v_total, v_status);

        -- Accumulate totals
        SET v_grand_total = v_grand_total + v_total;
        SET v_order_count = v_order_count + 1;
    END LOOP;

    CLOSE sales_cursor;

    -- Output the report
    SELECT * FROM tmp_sales_report;

    -- Output summary
    SELECT v_order_count AS total_orders,
           v_grand_total AS grand_total,
           CASE WHEN v_order_count > 0
                THEN ROUND(v_grand_total / v_order_count, 2)
                ELSE 0
           END AS average_order_value;

    DROP TEMPORARY TABLE IF EXISTS tmp_sales_report;
END$$

DELIMITER ;

SELECT 'All stored procedures created successfully!' AS status;
