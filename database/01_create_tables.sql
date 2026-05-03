-- ============================================================
-- ELECTRONICS STORE MANAGEMENT SYSTEM
-- 01_create_tables.sql — DDL Statements
-- Course: UCS310 – Database Management Systems
-- Group 2Q21 | Thapar Institute of Engineering & Technology
-- ============================================================

-- Drop existing tables (in reverse dependency order)
DROP TABLE IF EXISTS STOCK_ALERTS;
DROP TABLE IF EXISTS ORDER_ITEMS;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS INVENTORY;
DROP TABLE IF EXISTS PRODUCT;
DROP TABLE IF EXISTS CATEGORY;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS EMPLOYEE;

-- ============================================================
-- 1. CATEGORY TABLE
-- Stores product categories (e.g., Laptops, Smartphones, TVs, Audio, Tablets, Gaming)
-- ============================================================
CREATE TABLE CATEGORY (
    category_id     INT             AUTO_INCREMENT,
    category_name   VARCHAR(100)    NOT NULL,
    description     TEXT,
    created_at      DATETIME        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_category          PRIMARY KEY (category_id),
    CONSTRAINT uq_category_name     UNIQUE (category_name)
);

-- ============================================================
-- 2. PRODUCT TABLE
-- Stores electronic products with brand, specs, and pricing
-- ============================================================
CREATE TABLE PRODUCT (
    product_id      INT             AUTO_INCREMENT,
    product_name    VARCHAR(200)    NOT NULL,
    category_id     INT             NOT NULL,
    price           DECIMAL(12, 2)  NOT NULL,
    brand           VARCHAR(100)    NOT NULL,
    specifications  TEXT,
    date_added      DATE            DEFAULT (CURRENT_DATE),
    is_active       BOOLEAN         DEFAULT TRUE,

    CONSTRAINT pk_product           PRIMARY KEY (product_id),
    CONSTRAINT fk_product_category  FOREIGN KEY (category_id)
                                    REFERENCES CATEGORY(category_id)
                                    ON UPDATE CASCADE
                                    ON DELETE RESTRICT,
    CONSTRAINT chk_price_positive   CHECK (price > 0)
);

-- ============================================================
-- 3. INVENTORY TABLE
-- Tracks real-time stock levels for each product
-- ============================================================
CREATE TABLE INVENTORY (
    inventory_id        INT             AUTO_INCREMENT,
    product_id          INT             NOT NULL,
    quantity_in_stock   INT             NOT NULL DEFAULT 0,
    reorder_level       INT             NOT NULL DEFAULT 10,
    last_restocked      DATETIME,

    CONSTRAINT pk_inventory             PRIMARY KEY (inventory_id),
    CONSTRAINT fk_inventory_product     FOREIGN KEY (product_id)
                                        REFERENCES PRODUCT(product_id)
                                        ON UPDATE CASCADE
                                        ON DELETE CASCADE,
    CONSTRAINT uq_inventory_product     UNIQUE (product_id),
    CONSTRAINT chk_stock_nonneg         CHECK (quantity_in_stock >= 0),
    CONSTRAINT chk_reorder_nonneg       CHECK (reorder_level >= 0)
);

-- ============================================================
-- 4. CUSTOMER TABLE
-- Stores customer contact details and registration info
-- ============================================================
CREATE TABLE CUSTOMER (
    customer_id         INT             AUTO_INCREMENT,
    first_name          VARCHAR(100)    NOT NULL,
    last_name           VARCHAR(100)    NOT NULL,
    email               VARCHAR(150)    NOT NULL,
    phone               VARCHAR(15)     NOT NULL,
    address             TEXT,
    city                VARCHAR(100),
    registration_date   DATE            DEFAULT (CURRENT_DATE),

    CONSTRAINT pk_customer          PRIMARY KEY (customer_id),
    CONSTRAINT uq_customer_email    UNIQUE (email),
    CONSTRAINT uq_customer_phone    UNIQUE (phone),
    CONSTRAINT chk_email_format     CHECK (email LIKE '%_@_%.__%')
);

-- ============================================================
-- 5. EMPLOYEE TABLE
-- Stores employee records with role and salary
-- ============================================================
CREATE TABLE EMPLOYEE (
    employee_id     INT             AUTO_INCREMENT,
    first_name      VARCHAR(100)    NOT NULL,
    last_name       VARCHAR(100)    NOT NULL,
    role            VARCHAR(50)     NOT NULL DEFAULT 'Sales Associate',
    email           VARCHAR(150)    NOT NULL,
    phone           VARCHAR(15),
    hire_date       DATE            DEFAULT (CURRENT_DATE),
    salary          DECIMAL(10, 2)  NOT NULL,

    CONSTRAINT pk_employee          PRIMARY KEY (employee_id),
    CONSTRAINT uq_employee_email    UNIQUE (email),
    CONSTRAINT chk_salary_positive  CHECK (salary > 0),
    CONSTRAINT chk_role_valid       CHECK (role IN ('Manager', 'Sales Associate', 'Technician', 'Cashier', 'Inventory Clerk'))
);

-- ============================================================
-- 6. ORDERS TABLE
-- Stores order headers with customer, employee, payment info
-- ============================================================
CREATE TABLE ORDERS (
    order_id        INT             AUTO_INCREMENT,
    customer_id     INT             NOT NULL,
    employee_id     INT             NOT NULL,
    order_date      DATETIME        DEFAULT CURRENT_TIMESTAMP,
    total_amount    DECIMAL(12, 2)  DEFAULT 0.00,
    payment_method  VARCHAR(50)     NOT NULL DEFAULT 'Cash',
    order_status    VARCHAR(30)     NOT NULL DEFAULT 'Pending',

    CONSTRAINT pk_orders                PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer       FOREIGN KEY (customer_id)
                                        REFERENCES CUSTOMER(customer_id)
                                        ON UPDATE CASCADE
                                        ON DELETE RESTRICT,
    CONSTRAINT fk_orders_employee       FOREIGN KEY (employee_id)
                                        REFERENCES EMPLOYEE(employee_id)
                                        ON UPDATE CASCADE
                                        ON DELETE RESTRICT,
    CONSTRAINT chk_total_nonneg         CHECK (total_amount >= 0),
    CONSTRAINT chk_payment_method       CHECK (payment_method IN ('Cash', 'Credit Card', 'Debit Card', 'UPI', 'Net Banking')),
    CONSTRAINT chk_order_status         CHECK (order_status IN ('Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'))
);

-- ============================================================
-- 7. ORDER_ITEMS TABLE
-- Stores individual line items within an order
-- ============================================================
CREATE TABLE ORDER_ITEMS (
    order_item_id   INT             AUTO_INCREMENT,
    order_id        INT             NOT NULL,
    product_id      INT             NOT NULL,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(12, 2)  NOT NULL,
    subtotal        DECIMAL(12, 2)  GENERATED ALWAYS AS (quantity * unit_price) STORED,

    CONSTRAINT pk_order_items           PRIMARY KEY (order_item_id),
    CONSTRAINT fk_items_order           FOREIGN KEY (order_id)
                                        REFERENCES ORDERS(order_id)
                                        ON UPDATE CASCADE
                                        ON DELETE CASCADE,
    CONSTRAINT fk_items_product         FOREIGN KEY (product_id)
                                        REFERENCES PRODUCT(product_id)
                                        ON UPDATE CASCADE
                                        ON DELETE RESTRICT,
    CONSTRAINT chk_quantity_positive    CHECK (quantity > 0),
    CONSTRAINT chk_unit_price_positive  CHECK (unit_price > 0)
);

-- ============================================================
-- 8. STOCK_ALERTS TABLE (Logging table for triggers)
-- Logs warnings when stock falls below reorder level
-- ============================================================
CREATE TABLE STOCK_ALERTS (
    alert_id        INT             AUTO_INCREMENT,
    product_id      INT             NOT NULL,
    product_name    VARCHAR(200),
    current_stock   INT,
    reorder_level   INT,
    alert_message   TEXT,
    alert_date      DATETIME        DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_stock_alerts          PRIMARY KEY (alert_id),
    CONSTRAINT fk_alerts_product        FOREIGN KEY (product_id)
                                        REFERENCES PRODUCT(product_id)
                                        ON UPDATE CASCADE
                                        ON DELETE CASCADE
);

-- ============================================================
-- CREATE INDEXES for query performance
-- ============================================================
CREATE INDEX idx_product_category    ON PRODUCT(category_id);
CREATE INDEX idx_product_brand       ON PRODUCT(brand);
CREATE INDEX idx_inventory_stock     ON INVENTORY(quantity_in_stock);
CREATE INDEX idx_orders_customer     ON ORDERS(customer_id);
CREATE INDEX idx_orders_employee     ON ORDERS(employee_id);
CREATE INDEX idx_orders_date         ON ORDERS(order_date);
CREATE INDEX idx_order_items_order   ON ORDER_ITEMS(order_id);
CREATE INDEX idx_order_items_product ON ORDER_ITEMS(product_id);
CREATE INDEX idx_customer_name       ON CUSTOMER(last_name, first_name);

SELECT 'All tables created successfully!' AS status;
