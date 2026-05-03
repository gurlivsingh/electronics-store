// ============================================================
// routes/orders.js — Sales & Billing (uses stored procedures)
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET all orders with customer info
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT o.*, 
                   CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                   c.email AS customer_email,
                   CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
                   (SELECT COUNT(*) FROM ORDER_ITEMS WHERE order_id = o.order_id) AS items_count
            FROM ORDERS o
            JOIN CUSTOMER c ON o.customer_id = c.customer_id
            JOIN EMPLOYEE e ON o.employee_id = e.employee_id
            ORDER BY o.order_date DESC
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single order with items
router.get('/:id', async (req, res) => {
    try {
        const [order] = await db.query(`
            SELECT o.*, 
                   CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                   c.email, c.phone, c.address,
                   CONCAT(e.first_name, ' ', e.last_name) AS employee_name
            FROM ORDERS o
            JOIN CUSTOMER c ON o.customer_id = c.customer_id
            JOIN EMPLOYEE e ON o.employee_id = e.employee_id
            WHERE o.order_id = ?
        `, [req.params.id]);

        if (order.length === 0) return res.status(404).json({ error: 'Order not found' });

        const [items] = await db.query(`
            SELECT oi.*, p.product_name, p.brand, c.category_name
            FROM ORDER_ITEMS oi
            JOIN PRODUCT p ON oi.product_id = p.product_id
            JOIN CATEGORY c ON p.category_id = c.category_id
            WHERE oi.order_id = ?
        `, [req.params.id]);

        // Use stored function
        const [total] = await db.query('SELECT fn_calculate_order_total(?) AS calculated_total', [req.params.id]);

        res.json({
            ...order[0],
            items,
            calculated_total: total[0].calculated_total
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST create new order (calls sp_place_order)
router.post('/', async (req, res) => {
    try {
        const { customer_id, employee_id, payment_method } = req.body;
        await db.query(
            'CALL sp_place_order(?, ?, ?, @order_id)',
            [customer_id, employee_id, payment_method]
        );
        const [result] = await db.query('SELECT @order_id AS order_id');
        res.json({ id: result[0].order_id, message: 'Order created successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// POST add item to order (calls sp_add_order_item)
router.post('/:id/items', async (req, res) => {
    try {
        const { product_id, quantity } = req.body;
        await db.query(
            'CALL sp_add_order_item(?, ?, ?)',
            [req.params.id, product_id, quantity]
        );
        res.json({ message: 'Item added to order successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// PUT update order status
router.put('/:id/status', async (req, res) => {
    try {
        const { order_status } = req.body;
        await db.query(
            'UPDATE ORDERS SET order_status = ? WHERE order_id = ?',
            [order_status, req.params.id]
        );
        res.json({ message: 'Order status updated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// DELETE order item
router.delete('/:orderId/items/:itemId', async (req, res) => {
    try {
        await db.query('DELETE FROM ORDER_ITEMS WHERE order_item_id = ? AND order_id = ?',
            [req.params.itemId, req.params.orderId]);
        res.json({ message: 'Order item removed (stock restored via trigger)' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
