// ============================================================
// routes/employees.js — Employee Management
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET all employees with sales stats
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT e.*,
                   COUNT(o.order_id) AS orders_handled,
                   COALESCE(SUM(o.total_amount), 0) AS total_sales
            FROM EMPLOYEE e
            LEFT JOIN ORDERS o ON e.employee_id = o.employee_id
            GROUP BY e.employee_id
            ORDER BY e.employee_id
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single employee
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM EMPLOYEE WHERE employee_id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Employee not found' });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST new employee
router.post('/', async (req, res) => {
    try {
        const { first_name, last_name, role, email, phone, salary } = req.body;
        const [result] = await db.query(
            'INSERT INTO EMPLOYEE (first_name, last_name, role, email, phone, salary) VALUES (?, ?, ?, ?, ?, ?)',
            [first_name, last_name, role, email, phone, salary]
        );
        res.json({ id: result.insertId, message: 'Employee added successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// PUT update employee
router.put('/:id', async (req, res) => {
    try {
        const { first_name, last_name, role, email, phone, salary } = req.body;
        await db.query(`
            UPDATE EMPLOYEE SET first_name=?, last_name=?, role=?, email=?, phone=?, salary=?
            WHERE employee_id=?
        `, [first_name, last_name, role, email, phone, salary, req.params.id]);
        res.json({ message: 'Employee updated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// DELETE employee
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM EMPLOYEE WHERE employee_id = ?', [req.params.id]);
        res.json({ message: 'Employee deleted successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
