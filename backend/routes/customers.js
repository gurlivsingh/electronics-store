// ============================================================
// routes/customers.js — Customer Management (uses stored procedure)
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET all customers with order stats
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT c.*, 
                   COUNT(DISTINCT o.order_id) AS total_orders,
                   COALESCE(SUM(o.total_amount), 0) AS lifetime_spend,
                   MAX(o.order_date) AS last_order_date
            FROM CUSTOMER c
            LEFT JOIN ORDERS o ON c.customer_id = o.customer_id AND o.order_status != 'Cancelled'
            GROUP BY c.customer_id
            ORDER BY c.customer_id DESC
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single customer with order history
router.get('/:id', async (req, res) => {
    try {
        const [customer] = await db.query('SELECT * FROM CUSTOMER WHERE customer_id = ?', [req.params.id]);
        if (customer.length === 0) return res.status(404).json({ error: 'Customer not found' });

        const [orders] = await db.query(`
            SELECT o.*, CONCAT(e.first_name, ' ', e.last_name) AS handled_by
            FROM ORDERS o 
            JOIN EMPLOYEE e ON o.employee_id = e.employee_id
            WHERE o.customer_id = ?
            ORDER BY o.order_date DESC
        `, [req.params.id]);

        // Use stored function
        const [spend] = await db.query('SELECT fn_get_customer_total_spend(?) AS total_spend', [req.params.id]);

        res.json({
            ...customer[0],
            orders,
            total_spend: spend[0].total_spend
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST new customer (calls sp_register_customer)
router.post('/', async (req, res) => {
    try {
        const { first_name, last_name, email, phone, address, city } = req.body;
        await db.query(
            'CALL sp_register_customer(?, ?, ?, ?, ?, ?, @customer_id)',
            [first_name, last_name, email, phone, address, city]
        );
        const [result] = await db.query('SELECT @customer_id AS customer_id');
        res.json({ id: result[0].customer_id, message: 'Customer registered successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// PUT update customer
router.put('/:id', async (req, res) => {
    try {
        const { first_name, last_name, email, phone, address, city } = req.body;
        await db.query(`
            UPDATE CUSTOMER SET first_name=?, last_name=?, email=?, phone=?, address=?, city=?
            WHERE customer_id=?
        `, [first_name, last_name, email, phone, address, city, req.params.id]);
        res.json({ message: 'Customer updated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// DELETE customer
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM CUSTOMER WHERE customer_id = ?', [req.params.id]);
        res.json({ message: 'Customer deleted successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
