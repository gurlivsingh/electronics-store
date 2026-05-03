-- ============================================================
-- ELECTRONICS STORE MANAGEMENT SYSTEM
-- 02_triggers.sql — Trigger Definitions
-- Course: UCS310 – Database Management Systems
-- Group 2Q21 | Thapar Institute of Engineering & Technology
-- ============================================================

DELIMITER $$

-- ============================================================
-- TRIGGER 1: trg_after_order_item_insert
-- Fires AFTER a new item is added to an order.
-- Automatically decrements the inventory stock by the
-- quantity ordered. This ensures real-time stock tracking.
-- ============================================================
DROP TRIGGER IF EXISTS trg_after_order_item_insert$$

CREATE TRIGGER trg_after_order_item_insert
AFTER INSERT ON ORDER_ITEMS
FOR EACH ROW
BEGIN
    -- Decrement the inventory stock for the purchased product
    UPDATE INVENTORY
    SET quantity_in_stock = quantity_in_stock - NEW.quantity
    WHERE product_id = NEW.product_id;

    -- Update the order total amount
    UPDATE ORDERS
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM ORDER_ITEMS
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$

-- ============================================================
-- TRIGGER 2: trg_after_order_item_delete
-- Fires AFTER an order item is removed (cancelled).
-- Restores the inventory stock by the cancelled quantity.
-- ============================================================
DROP TRIGGER IF EXISTS trg_after_order_item_delete$$

CREATE TRIGGER trg_after_order_item_delete
AFTER DELETE ON ORDER_ITEMS
FOR EACH ROW
BEGIN
    -- Restore the inventory stock
    UPDATE INVENTORY
    SET quantity_in_stock = quantity_in_stock + OLD.quantity
    WHERE product_id = OLD.product_id;

    -- Recalculate the order total amount
    UPDATE ORDERS
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM ORDER_ITEMS
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END$$

-- ============================================================
-- TRIGGER 3: trg_before_order_insert
-- Fires BEFORE a new order is created.
-- Automatically sets the order_date to the current timestamp
-- and validates that the customer and employee exist.
-- ============================================================
DROP TRIGGER IF EXISTS trg_before_order_insert$$

CREATE TRIGGER trg_before_order_insert
BEFORE INSERT ON ORDERS
FOR EACH ROW
BEGIN
    DECLARE v_cust_count INT;
    DECLARE v_emp_count INT;

    -- Auto-set order date if not provided
    IF NEW.order_date IS NULL THEN
        SET NEW.order_date = NOW();
    END IF;

    -- Validate customer exists
    SELECT COUNT(*) INTO v_cust_count
    FROM CUSTOMER
    WHERE customer_id = NEW.customer_id;

    IF v_cust_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Customer ID does not exist.';
    END IF;

    -- Validate employee exists
    SELECT COUNT(*) INTO v_emp_count
    FROM EMPLOYEE
    WHERE employee_id = NEW.employee_id;

    IF v_emp_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Employee ID does not exist.';
    END IF;

    -- Default the status to Pending
    IF NEW.order_status IS NULL OR NEW.order_status = '' THEN
        SET NEW.order_status = 'Pending';
    END IF;
END$$

-- ============================================================
-- TRIGGER 4: trg_stock_alert
-- Fires AFTER an UPDATE on INVENTORY.
-- When stock falls below the reorder level, a warning is
-- logged into the STOCK_ALERTS table for management review.
-- ============================================================
DROP TRIGGER IF EXISTS trg_stock_alert$$

CREATE TRIGGER trg_stock_alert
AFTER UPDATE ON INVENTORY
FOR EACH ROW
BEGIN
    DECLARE v_product_name VARCHAR(200);

    -- Only fire when stock has decreased and is now below reorder level
    IF NEW.quantity_in_stock < NEW.reorder_level
       AND NEW.quantity_in_stock < OLD.quantity_in_stock THEN

        -- Fetch the product name for a readable alert
        SELECT product_name INTO v_product_name
        FROM PRODUCT
        WHERE product_id = NEW.product_id;

        -- Insert alert record
        INSERT INTO STOCK_ALERTS (
            product_id,
            product_name,
            current_stock,
            reorder_level,
            alert_message,
            alert_date
        ) VALUES (
            NEW.product_id,
            v_product_name,
            NEW.quantity_in_stock,
            NEW.reorder_level,
            CONCAT('LOW STOCK WARNING: "', v_product_name,
                   '" has only ', NEW.quantity_in_stock,
                   ' units left (reorder level: ', NEW.reorder_level, ')'),
            NOW()
        );
    END IF;
END$$

DELIMITER ;

SELECT 'All triggers created successfully!' AS status;
