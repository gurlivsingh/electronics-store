// ============================================================
// ELECTRONICS STORE MANAGEMENT SYSTEM
// server.js — Express API Server
// ============================================================

const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// CORS — Allow all origins (needed for Vercel deployment)
app.use(cors({ origin: '*' }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static frontend files
// Works both locally (root/frontend) and on Vercel
const frontendPath = path.join(__dirname, '..', 'frontend');
app.use(express.static(frontendPath));

// Import routes
const productRoutes = require('./routes/products');
const customerRoutes = require('./routes/customers');
const orderRoutes = require('./routes/orders');
const inventoryRoutes = require('./routes/inventory');
const employeeRoutes = require('./routes/employees');
const reportRoutes = require('./routes/reports');
const categoryRoutes = require('./routes/categories');
const dashboardRoutes = require('./routes/dashboard');

// API Routes
app.use('/api/products', productRoutes);
app.use('/api/customers', customerRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/employees', employeeRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Serve frontend for all other routes (SPA support)
app.get('*', (req, res) => {
    res.sendFile(path.join(frontendPath, 'index.html'));
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Server Error:', err.message);
    res.status(500).json({ error: err.message || 'Internal Server Error' });
});

app.listen(PORT, () => {
    console.log(`🚀 Electronics Store API running on http://localhost:${PORT}`);
    console.log(`📁 Frontend served from: ${path.join(__dirname, '..', 'frontend')}`);
});
