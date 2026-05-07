// ============================================================
// app.js — Main Application Logic, Routing, Toasts
// ============================================================

let currentPage = 'dashboard';

// ============ NAVIGATION ============
function navigateTo(page) {
    // Hide all pages
    document.querySelectorAll('.page-section').forEach(s => s.classList.remove('active'));
    // Deactivate all nav items
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));

    // Show selected page
    const target = document.getElementById(`page-${page}`);
    if (target) target.classList.add('active');

    // Activate nav item
    const navItem = document.querySelector(`.nav-item[data-page="${page}"]`);
    if (navItem) navItem.classList.add('active');

    // Update header
    const titles = {
        dashboard: 'Dashboard',
        products: 'Product Management',
        inventory: 'Inventory Management',
        orders: 'Orders & Billing',
        customers: 'Customer Management',
        employees: 'Employee Directory',
        reports: 'Reports & Analytics'
    };
    document.getElementById('pageTitle').textContent = titles[page] || page;
    document.getElementById('pageBreadcrumb').textContent = `Home / ${titles[page] || page}`;

    currentPage = page;

    // Load data for the page
    loadPageData(page);

    // Close mobile sidebar
    document.getElementById('sidebar').classList.remove('open');
}

function loadPageData(page) {
    switch (page) {
        case 'dashboard': loadDashboard(); break;
        case 'products': loadProducts(); break;
        case 'inventory': loadInventory(); break;
        case 'orders': loadOrders(); break;
        case 'customers': loadCustomers(); break;
        case 'employees': loadEmployees(); break;
        case 'reports':
            loadCategorySummary();
            loadTopProducts();
            // Small delay so canvases are rendered before Chart.js runs
            setTimeout(() => loadAllCharts(), 100);
            break;
    }
}

// ============ TOAST NOTIFICATIONS ============
function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    const icons = {
        success: '✅', error: '❌', warning: '⚠️', info: 'ℹ️'
    };
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <span class="toast-icon">${icons[type]}</span>
        <span class="toast-message">${message}</span>
    `;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 4000);
}

// ============ MODAL MANAGEMENT ============
function openModal(modalId) {
    document.getElementById(modalId).classList.add('active');
    // Load dropdown data
    if (modalId === 'productModal') loadCategoryDropdown();
    if (modalId === 'orderModal') { loadCustomerDropdown(); loadEmployeeDropdown(); }
    if (modalId === 'orderItemModal') loadProductDropdownForOrder();
    if (modalId === 'restockModal') loadProductDropdownForRestock();
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

// Close modal on overlay click
document.addEventListener('click', (e) => {
    if (e.target.classList.contains('modal-overlay')) {
        e.target.classList.remove('active');
    }
});

// Close modal on ESC key
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        document.querySelectorAll('.modal-overlay.active').forEach(m => m.classList.remove('active'));
    }
});

// ============ STATUS BADGES ============
function statusBadge(status) {
    const map = {
        'Delivered': 'badge-success',
        'Confirmed': 'badge-info',
        'Shipped': 'badge-primary',
        'Pending': 'badge-warning',
        'Cancelled': 'badge-danger'
    };
    return `<span class="badge ${map[status] || 'badge-info'}">${status}</span>`;
}

function stockBadge(health) {
    const map = {
        'HEALTHY': 'stock-healthy',
        'MODERATE': 'stock-moderate',
        'LOW STOCK': 'stock-low',
        'OUT OF STOCK': 'stock-out'
    };
    return `<span class="badge ${map[health] || 'badge-info'}">${health}</span>`;
}

// ============ DROPDOWN LOADERS ============
async function loadCategoryDropdown() {
    try {
        const categories = await apiGet('/categories');
        const select = document.getElementById('prod_category');
        select.innerHTML = '<option value="">Select category</option>';
        categories.forEach(c => {
            select.innerHTML += `<option value="${c.category_id}">${c.category_name}</option>`;
        });
        // Also update filter dropdown
        const filter = document.getElementById('productCategoryFilter');
        if (filter) {
            filter.innerHTML = '<option value="">All Categories</option>';
            categories.forEach(c => {
                filter.innerHTML += `<option value="${c.category_id}">${c.category_name}</option>`;
            });
        }
    } catch (err) { console.error(err); }
}

async function loadCustomerDropdown() {
    try {
        const customers = await apiGet('/customers');
        const select = document.getElementById('order_customer');
        select.innerHTML = '<option value="">Select customer</option>';
        customers.forEach(c => {
            select.innerHTML += `<option value="${c.customer_id}">${c.first_name} ${c.last_name} (${c.email})</option>`;
        });
    } catch (err) { console.error(err); }
}

async function loadEmployeeDropdown() {
    try {
        const employees = await apiGet('/employees');
        const select = document.getElementById('order_employee');
        select.innerHTML = '<option value="">Select employee</option>';
        employees.forEach(e => {
            select.innerHTML += `<option value="${e.employee_id}">${e.first_name} ${e.last_name} (${e.role})</option>`;
        });
    } catch (err) { console.error(err); }
}

async function loadProductDropdownForOrder() {
    try {
        const products = await apiGet('/products');
        const select = document.getElementById('item_product');
        select.innerHTML = '<option value="">Select product</option>';
        products.filter(p => p.quantity_in_stock > 0).forEach(p => {
            select.innerHTML += `<option value="${p.product_id}">${p.product_name} (${p.brand}) — Stock: ${p.quantity_in_stock} — ${formatCurrency(p.price)}</option>`;
        });
    } catch (err) { console.error(err); }
}

async function loadProductDropdownForRestock() {
    try {
        const products = await apiGet('/products');
        const select = document.getElementById('restock_product');
        select.innerHTML = '<option value="">Select product</option>';
        products.forEach(p => {
            select.innerHTML += `<option value="${p.product_id}">${p.product_name} (${p.brand}) — Current: ${p.quantity_in_stock || 0}</option>`;
        });
    } catch (err) { console.error(err); }
}

// ============ DASHBOARD ============
async function loadDashboard() {
    try {
        const stats = await apiGet('/dashboard/stats');
        document.getElementById('kpi-products').textContent = stats.total_products;
        document.getElementById('kpi-customers').textContent = stats.total_customers;
        document.getElementById('kpi-revenue').textContent = formatCurrency(stats.total_revenue);
        document.getElementById('kpi-orders').textContent = stats.total_orders;

        // Update low stock badge
        const badge = document.getElementById('lowStockBadge');
        if (stats.low_stock_items > 0) {
            badge.textContent = stats.low_stock_items;
            badge.style.display = '';
        } else {
            badge.style.display = 'none';
        }
    } catch (err) {
        console.error('Dashboard stats failed:', err);
    }

    // Load recent orders
    try {
        const recent = await apiGet('/dashboard/recent-orders');
        const tbody = document.getElementById('recentOrdersBody');
        if (recent.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted" style="padding:30px">No orders yet</td></tr>';
        } else {
            tbody.innerHTML = recent.map(o => `
                <tr>
                    <td>#${o.order_id}</td>
                    <td>${o.customer_name}</td>
                    <td>${formatCurrency(o.total_amount)}</td>
                    <td>${statusBadge(o.order_status)}</td>
                </tr>
            `).join('');
        }
    } catch (err) { console.error(err); }

    // Load alerts
    try {
        const alerts = await apiGet('/dashboard/alerts');
        const tbody = document.getElementById('alertsBody');
        if (alerts.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted" style="padding:30px">All stock levels healthy ✅</td></tr>';
        } else {
            tbody.innerHTML = alerts.map(a => `
                <tr>
                    <td>${a.product_name}</td>
                    <td><strong class="text-danger">${a.quantity_in_stock}</strong></td>
                    <td>${a.reorder_level}</td>
                    <td>${stockBadge(a.quantity_in_stock === 0 ? 'OUT OF STOCK' : 'LOW STOCK')}</td>
                </tr>
            `).join('');
        }
    } catch (err) { console.error(err); }
}

// ============ INIT ============
document.addEventListener('DOMContentLoaded', () => {
    // Nav click handlers
    document.querySelectorAll('.nav-item').forEach(item => {
        item.addEventListener('click', () => navigateTo(item.dataset.page));
    });

    // Mobile menu toggle
    document.getElementById('menuToggle').addEventListener('click', () => {
        document.getElementById('sidebar').classList.toggle('open');
    });

    // Initial load
    loadDashboard();
    loadCategoryDropdown();
});
