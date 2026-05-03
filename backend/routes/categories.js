// ============================================================
// routes/categories.js — Category CRUD
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET all categories
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM CATEGORY ORDER BY category_name');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST new category
router.post('/', async (req, res) => {
    try {
        const { category_name, description } = req.body;
        const [result] = await db.query(
            'INSERT INTO CATEGORY (category_name, description) VALUES (?, ?)',
            [category_name, description]
        );
        res.json({ id: result.insertId, message: 'Category added successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// PUT update category
router.put('/:id', async (req, res) => {
    try {
        const { category_name, description } = req.body;
        await db.query(
            'UPDATE CATEGORY SET category_name = ?, description = ? WHERE category_id = ?',
            [category_name, description, req.params.id]
        );
        res.json({ message: 'Category updated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// DELETE category
router.delete('/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM CATEGORY WHERE category_id = ?', [req.params.id]);
        res.json({ message: 'Category deleted successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

module.exports = router;
