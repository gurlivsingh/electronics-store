// ============================================================
// routes/reports.js — Reports (uses cursor procedures & functions)
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET sales report by date range (calls sp_generate_sales_report cursor procedure)
router.get('/sales', async (req, res) => {
    try {
        const { start_date, end_date } = req.query;
        const startDate = start_date || '2026-01-01';
        const endDate = end_date || '2026-12-31';

        const [results] = await db.query(
            'CALL sp_generate_sales_report(?, ?)',
            [startDate, endDate]
        );
        // results[0] = order rows, results[1] = summary
        res.json({
            orders: results[0] || [],
            summary: results[1] ? results[1][0] : {}
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET category sales summary (calls sp_category_sales_summary cursor procedure)
router.get('/categories', async (req, res) => {
    try {
        const [results] = await db.query('CALL sp_category_sales_summary()');
        res.json(results[0] || []);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET category revenue (uses stored function)
router.get('/category-revenue/:categoryId', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT fn_get_category_revenue(?) AS revenue',
            [req.params.categoryId]
        );
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET customer order history (calls sp_customer_order_history cursor procedure)
router.get('/customer-history/:customerId', async (req, res) => {
    try {
        const [results] = await db.query(
            'CALL sp_customer_order_history(?)',
            [req.params.customerId]
        );
        res.json({
            orders: results[0] || [],
            summary: results[1] ? results[1][0] : {}
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET top selling products
router.get('/top-products', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT p.product_name, p.brand, c.category_name,
                   SUM(oi.quantity) AS total_sold,
                   SUM(oi.quantity * oi.unit_price) AS total_revenue
            FROM ORDER_ITEMS oi
            JOIN PRODUCT p ON oi.product_id = p.product_id
            JOIN CATEGORY c ON p.category_id = c.category_id
            GROUP BY p.product_id, p.product_name, p.brand, c.category_name
            ORDER BY total_revenue DESC
            LIMIT 10
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
