# ⚡ Electronics Store Management System

**UCS310 — Database Management Systems Project**  
**Thapar Institute of Engineering & Technology**

| Field | Details |
|---|---|
| **Group** | 2Q21 |
| **Members** | GURLIV SINGH (1024170161), KESHAV SINGH (1024170166), ANUBHAV ROY (1024170150) |
| **Submitted To** | Ms. SHEFALI |
| **Program** | B.E. (2nd Year) — Computer Science (COPC) |

---

## 📋 Project Overview

An **Electronics Store Management System** that automates product cataloging, inventory tracking, customer management, sales & billing, and reporting — replacing manual record-keeping with a structured relational database.

**Core Focus:** Backend implementation using **SQL and PL/SQL** (stored procedures, functions, triggers, cursors, exception handling, and transaction management).

---

## 🛠 Technology Stack

| Layer | Technology |
|---|---|
| **Database** | MySQL 8.0+ |
| **Backend Logic** | SQL & PL/SQL (Procedures, Functions, Triggers, Cursors) |
| **API Bridge** | Node.js + Express.js (lightweight connector) |
| **Frontend** | HTML5, CSS3, Vanilla JavaScript |
| **Tools** | MySQL Workbench (schema + PL/SQL testing) |

---

## 📁 Project Structure

```
dbms project/
├── backend/
│   ├── server.js               # Express API server
│   ├── db.js                   # MySQL connection pool
│   ├── package.json            # Node dependencies
│   └── routes/
│       ├── products.js         # Product CRUD (calls sp_add_product)
│       ├── customers.js        # Customer CRUD (calls sp_register_customer)
│       ├── orders.js           # Orders (sp_place_order, sp_add_order_item)
│       ├── inventory.js        # Inventory (sp_update_stock, sp_check_low_stock)
│       ├── employees.js        # Employee CRUD
│       ├── categories.js       # Category CRUD
│       ├── reports.js          # Reports (sp_generate_sales_report, sp_category_sales_summary)
│       └── dashboard.js        # Dashboard KPI stats
│
├── frontend/
│   ├── index.html              # Single-page application
│   ├── css/styles.css          # Premium dark-mode design system
│   └── js/
│       ├── api.js              # Fetch wrappers & formatters
│       ├── app.js              # SPA routing, modals, toasts
│       ├── products.js         # Product UI
│       ├── customers.js        # Customer UI
│       ├── orders.js           # Orders & billing UI
│       ├── inventory.js        # Inventory UI
│       ├── employees.js        # Employee UI
│       └── reports.js          # Reports & analytics UI
│
├── database/
│   ├── 01_create_tables.sql    # DDL — 8 tables with constraints
│   ├── 02_triggers.sql         # 4 triggers
│   ├── 03_procedures.sql       # 6 stored procedures
│   ├── 04_functions.sql        # 4 stored functions
│   ├── 05_cursors.sql          # 3 cursor-based procedures
│   ├── 06_sample_data.sql      # 40 products, 20 customers, 18 orders
│   ├── 07_complex_queries.sql  # Joins, subqueries, views
│   └── 08_transactions.sql     # COMMIT, ROLLBACK, SAVEPOINT examples
│
└── README.md
```

---

## 🗄️ Database Schema (7+1 Tables)

| Table | Purpose | Key Constraints |
|---|---|---|
| `CATEGORY` | Product categories | PK, UNIQUE(name) |
| `PRODUCT` | Electronic items | PK, FK→CATEGORY, CHECK(price>0) |
| `INVENTORY` | Stock tracking | PK, FK→PRODUCT, UNIQUE(product_id), CHECK(stock≥0) |
| `CUSTOMER` | Customer records | PK, UNIQUE(email), UNIQUE(phone) |
| `EMPLOYEE` | Staff records | PK, UNIQUE(email), CHECK(salary>0) |
| `ORDERS` | Order headers | PK, FK→CUSTOMER, FK→EMPLOYEE |
| `ORDER_ITEMS` | Line items | PK, FK→ORDERS, FK→PRODUCT, CHECK(qty>0) |
| `STOCK_ALERTS` | Alert log (trigger) | PK, FK→PRODUCT |

**Normalization:** All tables are in **3NF** (no partial or transitive dependencies).

---

## ⚙️ PL/SQL Components

### Stored Procedures (6)
1. `sp_add_product` — Adds product + auto-creates inventory record
2. `sp_register_customer` — Registers with duplicate validation
3. `sp_place_order` — Creates order with SAVEPOINT
4. `sp_add_order_item` — Validates stock, adds item (trigger decrements)
5. `sp_update_stock` — Restocks inventory
6. `sp_generate_sales_report` — **CURSOR** iterates through date-range orders

### Stored Functions (4)
1. `fn_get_product_stock` — Returns stock level
2. `fn_calculate_order_total` — Sums order items
3. `fn_get_customer_total_spend` — Lifetime customer spend
4. `fn_get_category_revenue` — Category revenue total

### Triggers (4)
1. `trg_after_order_item_insert` — Auto-decrement stock on sale
2. `trg_after_order_item_delete` — Restore stock on cancellation
3. `trg_before_order_insert` — Validate & auto-set order date
4. `trg_stock_alert` — Log warning when stock < reorder level

### Cursor Procedures (3)
1. `sp_generate_sales_report` — Sales report with cursor loop
2. `sp_check_low_stock` — Low stock report with urgency levels
3. `sp_category_sales_summary` — Category-wise revenue breakdown

---

## 🚀 Setup Instructions

### 1. Database Setup (MySQL)

```sql
-- Connect to MySQL
mysql -u root -p

-- Create database
CREATE DATABASE electronics_store;
USE electronics_store;

-- Run SQL scripts in order:
SOURCE database/01_create_tables.sql;
SOURCE database/02_triggers.sql;
SOURCE database/03_procedures.sql;
SOURCE database/04_functions.sql;
SOURCE database/05_cursors.sql;
SOURCE database/06_sample_data.sql;
SOURCE database/07_complex_queries.sql;
-- (08_transactions.sql is for demonstration)
```

### 2. Backend Setup (Node.js)

```bash
cd backend
npm install
```

Edit `db.js` if your MySQL credentials differ:
```javascript
user: 'root',
password: 'your_password',
database: 'electronics_store'
```

### 3. Run the Application

```bash
cd backend
node server.js
```

Open `http://localhost:3000` in your browser.

---

## 🧪 Testing the PL/SQL Components

```sql
-- Test stored procedure: add a product
CALL sp_add_product('Test Laptop', 1, 79999.00, 'TestBrand', 'Test specs', @id);
SELECT @id;

-- Test stored function: check stock
SELECT fn_get_product_stock(1);

-- Test cursor procedure: sales report
CALL sp_generate_sales_report('2026-01-01', '2026-12-31');

-- Test cursor procedure: low stock check
CALL sp_check_low_stock();

-- Test trigger: add an order item and observe stock decrease
-- (First check stock, then insert, then check again)
SELECT quantity_in_stock FROM INVENTORY WHERE product_id = 1;
-- After inserting into ORDER_ITEMS, stock will auto-decrement

-- Test transaction with rollback (see 08_transactions.sql)
```

---

## 📝 License

This project is developed for academic purposes under UCS310, Thapar Institute of Engineering & Technology.
