-- ============================================================
-- ELECTRONICS STORE MANAGEMENT SYSTEM
-- 05_cursors.sql — Cursor-Based Procedures
-- Course: UCS310 – Database Management Systems
-- Group 2Q21 | Thapar Institute of Engineering & Technology
-- ============================================================

DELIMITER $$

-- ============================================================
-- CURSOR PROCEDURE 1: sp_check_low_stock
-- Uses a CURSOR to iterate through all inventory records
-- and identify products below their reorder level.
-- Outputs a report of products needing restocking.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_check_low_stock$$

CREATE PROCEDURE sp_check_low_stock()
BEGIN
    DECLARE v_product_id        INT;
    DECLARE v_product_name      VARCHAR(200);
    DECLARE v_stock             INT;
    DECLARE v_reorder           INT;
    DECLARE v_brand             VARCHAR(100);
    DECLARE v_low_stock_count   INT DEFAULT 0;
    DECLARE v_done              INT DEFAULT 0;

    -- Cursor: Select products where stock is below reorder level
    DECLARE low_stock_cursor CURSOR FOR
        SELECT p.product_id, p.product_name, p.brand,
               i.quantity_in_stock, i.reorder_level
        FROM PRODUCT p
        JOIN INVENTORY i ON p.product_id = i.product_id
        WHERE i.quantity_in_stock < i.reorder_level
          AND p.is_active = TRUE
        ORDER BY (i.reorder_level - i.quantity_in_stock) DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Temporary table for report output
    DROP TEMPORARY TABLE IF EXISTS tmp_low_stock_report;
    CREATE TEMPORARY TABLE tmp_low_stock_report (
        product_id      INT,
        product_name    VARCHAR(200),
        brand           VARCHAR(100),
        current_stock   INT,
        reorder_level   INT,
        deficit         INT,
        urgency         VARCHAR(20)
    );

    -- Open cursor and iterate
    OPEN low_stock_cursor;

    stock_loop: LOOP
        FETCH low_stock_cursor
        INTO v_product_id, v_product_name, v_brand, v_stock, v_reorder;

        IF v_done THEN
            LEAVE stock_loop;
        END IF;

        -- Determine urgency
        INSERT INTO tmp_low_stock_report VALUES (
            v_product_id,
            v_product_name,
            v_brand,
            v_stock,
            v_reorder,
            v_reorder - v_stock,
            CASE
                WHEN v_stock = 0 THEN 'CRITICAL'
                WHEN v_stock <= v_reorder * 0.3 THEN 'HIGH'
                ELSE 'MEDIUM'
            END
        );

        SET v_low_stock_count = v_low_stock_count + 1;
    END LOOP;

    CLOSE low_stock_cursor;

    -- Output report
    SELECT * FROM tmp_low_stock_report ORDER BY deficit DESC;

    SELECT v_low_stock_count AS total_low_stock_items,
           CONCAT(v_low_stock_count, ' product(s) need restocking.') AS summary;

    DROP TEMPORARY TABLE IF EXISTS tmp_low_stock_report;
END$$


-- ============================================================
-- CURSOR PROCEDURE 2: sp_category_sales_summary
-- Uses a CURSOR to iterate through all categories and
-- calculate sales metrics for each category.
-- Demonstrates: Nested cursor with aggregate queries
-- ============================================================
DROP PROCEDURE IF EXISTS sp_category_sales_summary$$

CREATE PROCEDURE sp_category_sales_summary()
BEGIN
    DECLARE v_cat_id            INT;
    DECLARE v_cat_name          VARCHAR(100);
    DECLARE v_total_products    INT;
    DECLARE v_total_revenue     DECIMAL(12,2);
    DECLARE v_total_units_sold  INT;
    DECLARE v_done              INT DEFAULT 0;

    -- Cursor: Iterate over all categories
    DECLARE cat_cursor CURSOR FOR
        SELECT category_id, category_name
        FROM CATEGORY
        ORDER BY category_name;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Temp table for output
    DROP TEMPORARY TABLE IF EXISTS tmp_category_summary;
    CREATE TEMPORARY TABLE tmp_category_summary (
        category_id         INT,
        category_name       VARCHAR(100),
        total_products      INT,
        total_units_sold    INT,
        total_revenue       DECIMAL(12,2),
        avg_product_price   DECIMAL(12,2)
    );

    OPEN cat_cursor;

    cat_loop: LOOP
        FETCH cat_cursor INTO v_cat_id, v_cat_name;

        IF v_done THEN
            LEAVE cat_loop;
        END IF;

        -- Count products in category
        SELECT COUNT(*) INTO v_total_products
        FROM PRODUCT
        WHERE category_id = v_cat_id;

        -- Calculate revenue and units sold
        SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0),
               COALESCE(SUM(oi.quantity), 0)
        INTO v_total_revenue, v_total_units_sold
        FROM ORDER_ITEMS oi
        JOIN PRODUCT p ON oi.product_id = p.product_id
        WHERE p.category_id = v_cat_id;

        INSERT INTO tmp_category_summary VALUES (
            v_cat_id,
            v_cat_name,
            v_total_products,
            v_total_units_sold,
            v_total_revenue,
            CASE WHEN v_total_products > 0
                 THEN (SELECT ROUND(AVG(price), 2) FROM PRODUCT WHERE category_id = v_cat_id)
                 ELSE 0
            END
        );
    END LOOP;

    CLOSE cat_cursor;

    SELECT * FROM tmp_category_summary ORDER BY total_revenue DESC;

    DROP TEMPORARY TABLE IF EXISTS tmp_category_summary;
END$$


-- ============================================================
-- CURSOR PROCEDURE 3: sp_customer_order_history
-- Uses a cursor to build a detailed order history for a
-- specific customer, including item-level breakdown.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_customer_order_history$$

CREATE PROCEDURE sp_customer_order_history(IN p_customer_id INT)
BEGIN
    DECLARE v_order_id      INT;
    DECLARE v_order_date    DATETIME;
    DECLARE v_total         DECIMAL(12,2);
    DECLARE v_status        VARCHAR(30);
    DECLARE v_payment       VARCHAR(50);
    DECLARE v_order_count   INT DEFAULT 0;
    DECLARE v_lifetime      DECIMAL(12,2) DEFAULT 0;
    DECLARE v_done          INT DEFAULT 0;

    DECLARE order_cursor CURSOR FOR
        SELECT order_id, order_date, total_amount, order_status, payment_method
        FROM ORDERS
        WHERE customer_id = p_customer_id
        ORDER BY order_date DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- Temp table for output
    DROP TEMPORARY TABLE IF EXISTS tmp_order_history;
    CREATE TEMPORARY TABLE tmp_order_history (
        order_id        INT,
        order_date      DATETIME,
        total_amount    DECIMAL(12,2),
        order_status    VARCHAR(30),
        payment_method  VARCHAR(50),
        items_count     INT
    );

    OPEN order_cursor;

    hist_loop: LOOP
        FETCH order_cursor INTO v_order_id, v_order_date, v_total, v_status, v_payment;

        IF v_done THEN
            LEAVE hist_loop;
        END IF;

        INSERT INTO tmp_order_history
        SELECT v_order_id, v_order_date, v_total, v_status, v_payment,
               (SELECT COUNT(*) FROM ORDER_ITEMS WHERE order_id = v_order_id);

        SET v_order_count = v_order_count + 1;
        SET v_lifetime = v_lifetime + v_total;
    END LOOP;

    CLOSE order_cursor;

    SELECT * FROM tmp_order_history;
    SELECT v_order_count AS total_orders, v_lifetime AS lifetime_spend;

    DROP TEMPORARY TABLE IF EXISTS tmp_order_history;
END$$

DELIMITER ;

SELECT 'All cursor-based procedures created successfully!' AS status;
