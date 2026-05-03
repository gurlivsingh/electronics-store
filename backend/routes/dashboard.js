// ============================================================
// routes/dashboard.js — Dashboard KPIs & Quick Stats
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET dashboard stats
router.get('/stats', async (req, res) => {
    try {
        const [products] = await db.query('SELECT COUNT(*) AS count FROM PRODUCT WHERE is_active = TRUE');
        const [customers] = await db.query('SELECT COUNT(*) AS count FROM CUSTOMER');
        const [orders] = await db.query('SELECT COUNT(*) AS count FROM ORDERS');
        const [revenue] = await db.query("SELECT COALESCE(SUM(total_amount), 0) AS total FROM ORDERS WHERE order_status != 'Cancelled'");
        const [lowStock] = await db.query('SELECT COUNT(*) AS count FROM INVENTORY i WHERE i.quantity_in_stock < i.reorder_level');
        const [pendingOrders] = await db.query("SELECT COUNT(*) AS count FROM ORDERS WHERE order_status = 'Pending'");
        const [employees] = await db.query('SELECT COUNT(*) AS count FROM EMPLOYEE');
        const [categories] = await db.query('SELECT COUNT(*) AS count FROM CATEGORY');

        res.json({
            total_products: products[0].count,
            total_customers: customers[0].count,
            total_orders: orders[0].count,
            total_revenue: revenue[0].total,
            low_stock_items: lowStock[0].count,
            pending_orders: pendingOrders[0].count,
            total_employees: employees[0].count,
            total_categories: categories[0].count
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET recent orders
router.get('/recent-orders', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT o.order_id, o.order_date, o.total_amount, o.order_status, o.payment_method,
                   CONCAT(c.first_name, ' ', c.last_name) AS customer_name
            FROM ORDERS o
            JOIN CUSTOMER c ON o.customer_id = c.customer_id
            ORDER BY o.order_date DESC
            LIMIT 10
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET stock alerts
router.get('/alerts', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT p.product_name, p.brand, i.quantity_in_stock, i.reorder_level,
                   c.category_name
            FROM INVENTORY i
            JOIN PRODUCT p ON i.product_id = p.product_id
            JOIN CATEGORY c ON p.category_id = c.category_id
            WHERE i.quantity_in_stock < i.reorder_level AND p.is_active = TRUE
            ORDER BY (i.reorder_level - i.quantity_in_stock) DESC
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET monthly revenue data for chart
router.get('/monthly-revenue', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT 
                DATE_FORMAT(order_date, '%Y-%m') AS month,
                COUNT(*) AS order_count,
                SUM(total_amount) AS revenue
            FROM ORDERS
            WHERE order_status != 'Cancelled'
            GROUP BY DATE_FORMAT(order_date, '%Y-%m')
            ORDER BY month
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
