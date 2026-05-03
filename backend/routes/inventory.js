// ============================================================
// routes/inventory.js — Inventory Management (uses stored procedure)
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET full inventory status
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT p.product_id, p.product_name, p.brand, p.price,
                   c.category_name,
                   i.inventory_id, i.quantity_in_stock, i.reorder_level, i.last_restocked,
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
            WHERE p.is_active = TRUE
            ORDER BY i.quantity_in_stock ASC
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET stock for specific product (uses stored function)
router.get('/stock/:productId', async (req, res) => {
    try {
        const [rows] = await db.query(
            'SELECT fn_get_product_stock(?) AS stock',
            [req.params.productId]
        );
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST restock product (calls sp_update_stock)
router.post('/restock', async (req, res) => {
    try {
        const { product_id, quantity } = req.body;
        await db.query('CALL sp_update_stock(?, ?)', [product_id, quantity]);
        res.json({ message: `Restocked product #${product_id} with ${quantity} units` });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// PUT update reorder level
router.put('/reorder/:productId', async (req, res) => {
    try {
        const { reorder_level } = req.body;
        await db.query(
            'UPDATE INVENTORY SET reorder_level = ? WHERE product_id = ?',
            [reorder_level, req.params.productId]
        );
        res.json({ message: 'Reorder level updated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// GET low stock alerts
router.get('/alerts', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT * FROM STOCK_ALERTS ORDER BY alert_date DESC LIMIT 50
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET low stock products (calls cursor procedure)
router.get('/low-stock', async (req, res) => {
    try {
        const [rows] = await db.query('CALL sp_check_low_stock()');
        res.json(rows[0]); // first result set is the report
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
