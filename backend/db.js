// ============================================================
// ELECTRONICS STORE MANAGEMENT SYSTEM
// db.js — MySQL Connection Pool
// Supports both local MySQL and cloud MySQL (e.g., Railway)
// Configure DB credentials via environment variables on Vercel
// ============================================================

const mysql = require('mysql2/promise');

// For Vercel: set these in Project Settings → Environment Variables
// For local:  set DB_PASSWORD to your MySQL root password
const pool = mysql.createPool({
    host: process.env.MYSQL_HOST || process.env.DB_HOST || 'localhost',
    port: process.env.MYSQL_PORT || process.env.DB_PORT || 3306,
    user: process.env.MYSQL_USER || process.env.DB_USER || 'root',
    password: process.env.MYSQL_PASSWORD || process.env.DB_PASSWORD || '',
    database: process.env.MYSQL_DATABASE || process.env.DB_NAME || 'electronics_store',
    ssl: process.env.MYSQL_HOST && process.env.MYSQL_HOST !== 'localhost'
        ? { rejectUnauthorized: false }
        : undefined,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    multipleStatements: true
});

// Test connection on startup
async function testConnection() {
    try {
        const conn = await pool.getConnection();
        console.log('✅ MySQL connected to:', conn.config.database, 'at', conn.config.host);
        conn.release();
    } catch (err) {
        console.error('❌ MySQL connection failed:', err.message);
        console.log('💡 Set environment variables: MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE');
    }
}

testConnection();

module.exports = pool;
