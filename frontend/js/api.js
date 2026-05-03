// ============================================================
// api.js — API Communication Layer
// ============================================================

const API_BASE = '/api';

async function apiGet(endpoint) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`);
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        return await response.json();
    } catch (err) {
        console.error(`GET ${endpoint}:`, err);
        throw err;
    }
}

async function apiPost(endpoint, data) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        return await response.json();
    } catch (err) {
        console.error(`POST ${endpoint}:`, err);
        throw err;
    }
}

async function apiPut(endpoint, data) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        return await response.json();
    } catch (err) {
        console.error(`PUT ${endpoint}:`, err);
        throw err;
    }
}

async function apiDelete(endpoint) {
    try {
        const response = await fetch(`${API_BASE}${endpoint}`, {
            method: 'DELETE'
        });
        if (!response.ok) {
            const err = await response.json();
            throw new Error(err.error || `HTTP ${response.status}`);
        }
        return await response.json();
    } catch (err) {
        console.error(`DELETE ${endpoint}:`, err);
        throw err;
    }
}

// Currency formatter for INR
function formatCurrency(amount) {
    if (amount == null || isNaN(amount)) return '₹0';
    return '₹' + Number(amount).toLocaleString('en-IN', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    });
}

// Format date nicely
function formatDate(dateStr) {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-IN', {
        day: '2-digit', month: 'short', year: 'numeric'
    });
}

function formatDateTime(dateStr) {
    if (!dateStr) return '—';
    const d = new Date(dateStr);
    return d.toLocaleDateString('en-IN', {
        day: '2-digit', month: 'short', year: 'numeric',
        hour: '2-digit', minute: '2-digit'
    });
}
