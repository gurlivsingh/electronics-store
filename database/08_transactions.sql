-- ============================================================
-- ELECTRONICS STORE MANAGEMENT SYSTEM
-- 08_transactions.sql — Transaction Management Examples
-- Course: UCS310 – Database Management Systems
-- Group 2Q21 | Thapar Institute of Engineering & Technology
-- ============================================================
-- Demonstrates: COMMIT, ROLLBACK, SAVEPOINT, ACID Properties

-- ============================================================
-- TRANSACTION EXAMPLE 1: Successful Multi-Item Order
-- Demonstrates: COMMIT after successful operations
-- ACID Property: Atomicity — all items added, or none
-- ============================================================

-- Start a transaction for placing a complete order
START TRANSACTION;

    -- Step 1: Create a new order
    INSERT INTO ORDERS (customer_id, employee_id, payment_method, order_status)
    VALUES (9, 2, 'UPI', 'Pending');

    SET @new_order_id = LAST_INSERT_ID();

    SAVEPOINT after_order_creation;

    -- Step 2: Add item 1 — Sony Headphones
    INSERT INTO ORDER_ITEMS (order_id, product_id, quantity, unit_price)
    VALUES (@new_order_id, 15, 1, 29990.00);

    SAVEPOINT after_item_1;

    -- Step 3: Add item 2 — JBL Flip 6
    INSERT INTO ORDER_ITEMS (order_id, product_id, quantity, unit_price)
    VALUES (@new_order_id, 17, 2, 9999.00);

    SAVEPOINT after_item_2;

    -- Step 4: Update order status to Confirmed
    UPDATE ORDERS
    SET order_status = 'Confirmed'
    WHERE order_id = @new_order_id;

-- Everything succeeded — COMMIT the transaction
COMMIT;

SELECT CONCAT('Transaction 1 (SUCCESS): Order #', @new_order_id, ' committed.') AS result;
SELECT * FROM ORDERS WHERE order_id = @new_order_id;


-- ============================================================
-- TRANSACTION EXAMPLE 2: Partial Rollback using SAVEPOINT
-- Demonstrates: ROLLBACK TO SAVEPOINT
-- ACID Property: Consistency — database remains valid
-- ============================================================

START TRANSACTION;

    -- Insert a new customer
    INSERT INTO CUSTOMER (first_name, last_name, email, phone, address, city)
    VALUES ('Test', 'User', 'test.savepoint@email.com', '9999999999', 'Test Address', 'Test City');

    SET @test_customer = LAST_INSERT_ID();

    SAVEPOINT after_customer;

    -- Create order for test customer
    INSERT INTO ORDERS (customer_id, employee_id, payment_method, order_status)
    VALUES (@test_customer, 1, 'Cash', 'Pending');

    SET @test_order = LAST_INSERT_ID();

    SAVEPOINT after_test_order;

    -- Try to add item — simulating a scenario where we decide to cancel the order
    -- but keep the customer registration
    -- ROLLBACK TO after_customer: removes the order but keeps the customer
    ROLLBACK TO SAVEPOINT after_customer;

    -- The customer still exists, but the order was rolled back
COMMIT;

-- Verify: customer exists
SELECT CONCAT('Transaction 2 (PARTIAL ROLLBACK): Customer #', @test_customer, ' exists.') AS result;
SELECT * FROM CUSTOMER WHERE customer_id = @test_customer;

-- Verify: order does NOT exist (it was rolled back)
SELECT 'Order should not exist after rollback:' AS note;
SELECT * FROM ORDERS WHERE order_id = @test_order;

-- Clean up test data
DELETE FROM CUSTOMER WHERE email = 'test.savepoint@email.com';


-- ============================================================
-- TRANSACTION EXAMPLE 3: Full Rollback on Error
-- Demonstrates: ROLLBACK
-- ACID Property: Atomicity — nothing persists on failure
-- ============================================================

START TRANSACTION;

    -- Try to insert a customer with an email that already exists
    -- This will intentionally fail

    SAVEPOINT before_all;

    INSERT INTO CUSTOMER (first_name, last_name, email, phone, address, city)
    VALUES ('Duplicate', 'Test', 'aarav.sharma@email.com', '1111111111', 'Dup Address', 'Dup City');

    -- If we reach here, the insert succeeded (shouldn't with duplicate email)
    -- In practice, the CHECK/UNIQUE constraint will cause an error
    -- and the EXIT HANDLER in a procedure would trigger ROLLBACK

ROLLBACK;  -- Roll back the entire transaction

SELECT 'Transaction 3 (FULL ROLLBACK): No changes persisted.' AS result;


-- ============================================================
-- TRANSACTION EXAMPLE 4: Stock Update with Transaction Safety
-- Demonstrates: Isolation — concurrent stock updates
-- ============================================================

START TRANSACTION;

    -- Check current stock for Dyson Air Purifier (product_id = 24)
    SELECT product_name, quantity_in_stock
    FROM PRODUCT p
    JOIN INVENTORY i ON p.product_id = i.product_id
    WHERE p.product_id = 24;

    SAVEPOINT before_restock;

    -- Restock the product
    UPDATE INVENTORY
    SET quantity_in_stock = quantity_in_stock + 20,
        last_restocked = NOW()
    WHERE product_id = 24;

    -- Verify the new stock level
    SELECT 'After restock:' AS note;
    SELECT product_name, quantity_in_stock, last_restocked
    FROM PRODUCT p
    JOIN INVENTORY i ON p.product_id = i.product_id
    WHERE p.product_id = 24;

COMMIT;

SELECT 'Transaction 4 (STOCK UPDATE): Successfully restocked.' AS result;


-- ============================================================
-- SUMMARY: ACID Properties Demonstrated
-- ============================================================
-- Atomicity:    Transaction 1 & 3 — all-or-nothing semantics
-- Consistency:  Transaction 2 — partial rollback keeps DB valid
-- Isolation:    Transaction 4 — stock update in isolation
-- Durability:   All COMMIT statements ensure data persists

SELECT '=== ALL TRANSACTION EXAMPLES COMPLETED ===' AS status;
