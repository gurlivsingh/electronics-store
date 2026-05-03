// ============================================================
// routes/products.js — Product Management (uses stored procedure)
// ============================================================
const express = require('express');
const router = express.Router();
const db = require('../db');

// GET all products with category and stock info
router.get('/', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT p.*, c.category_name, 
                   i.quantity_in_stock, i.reorder_level, i.last_restocked,
                   CASE
                       WHEN i.quantity_in_stock = 0 THEN 'Out of Stock'
                       WHEN i.quantity_in_stock < i.reorder_level THEN 'Low Stock'
                       ELSE 'In Stock'
                   END AS stock_status
            FROM PRODUCT p
            JOIN CATEGORY c ON p.category_id = c.category_id
            LEFT JOIN INVENTORY i ON p.product_id = i.product_id
            ORDER BY p.product_id DESC
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET single product
router.get('/:id', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT p.*, c.category_name, 
                   i.quantity_in_stock, i.reorder_level
            FROM PRODUCT p
            JOIN CATEGORY c ON p.category_id = c.category_id
            LEFT JOIN INVENTORY i ON p.product_id = i.product_id
            WHERE p.product_id = ?
        `, [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Product not found' });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST new product (calls sp_add_product stored procedure)
router.post('/', async (req, res) => {
    try {
        const { product_name, category_id, price, brand, specifications } = req.body;
        await db.query(
            'CALL sp_add_product(?, ?, ?, ?, ?, @product_id)',
            [product_name, category_id, price, brand, specifications]
        );
        const [result] = await db.query('SELECT @product_id AS product_id');
        res.json({ id: result[0].product_id, message: 'Product added successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// PUT update product
router.put('/:id', async (req, res) => {
    try {
        const { product_name, category_id, price, brand, specifications, is_active } = req.body;
        await db.query(`
            UPDATE PRODUCT 
            SET product_name = ?, category_id = ?, price = ?, 
                brand = ?, specifications = ?, is_active = ?
            WHERE product_id = ?
        `, [product_name, category_id, price, brand, specifications, is_active !== false, req.params.id]);
        res.json({ message: 'Product updated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// DELETE product
router.delete('/:id', async (req, res) => {
    try {
        await db.query('UPDATE PRODUCT SET is_active = FALSE WHERE product_id = ?', [req.params.id]);
        res.json({ message: 'Product deactivated successfully' });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
});

// GET products by category
router.get('/category/:categoryId', async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT p.*, i.quantity_in_stock 
            FROM PRODUCT p
            LEFT JOIN INVENTORY i ON p.product_id = i.product_id
            WHERE p.category_id = ? AND p.is_active = TRUE
        `, [req.params.categoryId]);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
