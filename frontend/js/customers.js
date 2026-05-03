// ============================================================
// customers.js — Customer Management UI
// ============================================================

async function loadCustomers() {
    const tbody = document.getElementById('customersBody');
    tbody.innerHTML = '<tr><td colspan="8"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        const customers = await apiGet('/customers');

        if (customers.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state"><span class="icon">👥</span><h3>No customers yet</h3><p>Register your first customer</p></div></td></tr>';
            return;
        }

        tbody.innerHTML = customers.map(c => `
            <tr>
                <td>${c.customer_id}</td>
                <td><strong>${c.first_name} ${c.last_name}</strong></td>
                <td>${c.email}</td>
                <td>${c.phone}</td>
                <td>${c.city || '—'}</td>
                <td>${c.total_orders || 0}</td>
                <td class="font-mono">${formatCurrency(c.lifetime_spend)}</td>
                <td>
                    <button class="btn btn-ghost btn-sm btn-icon" onclick="viewCustomerHistory(${c.customer_id})" title="View History">📋</button>
                    <button class="btn btn-ghost btn-sm btn-icon" onclick="deleteCustomer(${c.customer_id})" title="Delete">🗑️</button>
                </td>
            </tr>
        `).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="8" class="text-center text-danger" style="padding:30px">Failed to load: ${err.message}</td></tr>`;
    }
}

async function submitCustomer(e) {
    e.preventDefault();
    try {
        await apiPost('/customers', {
            first_name: document.getElementById('cust_fname').value,
            last_name: document.getElementById('cust_lname').value,
            email: document.getElementById('cust_email').value,
            phone: document.getElementById('cust_phone').value,
            address: document.getElementById('cust_address').value,
            city: document.getElementById('cust_city').value
        });
        showToast('Customer registered successfully!', 'success');
        closeModal('customerModal');
        document.getElementById('customerForm').reset();
        loadCustomers();
        loadDashboard();
    } catch (err) {
        showToast(err.message, 'error');
    }
    return false;
}

async function deleteCustomer(id) {
    if (!confirm('Delete this customer? This cannot be undone.')) return;
    try {
        await apiDelete(`/customers/${id}`);
        showToast('Customer deleted', 'warning');
        loadCustomers();
    } catch (err) {
        showToast(err.message, 'error');
    }
}

async function viewCustomerHistory(customerId) {
    try {
        const data = await apiGet(`/reports/customer-history/${customerId}`);
        const content = document.getElementById('orderDetailsContent');

        let html = `<h3 class="mb-2">Order History</h3>`;

        if (data.orders && data.orders.length > 0) {
            html += `
                <div class="kpi-grid mb-2" style="grid-template-columns: 1fr 1fr;">
                    <div class="kpi-card"><div class="kpi-header"><div>
                        <div class="kpi-value text-primary">${data.summary.total_orders}</div>
                        <div class="kpi-label">Total Orders</div>
                    </div></div></div>
                    <div class="kpi-card"><div class="kpi-header"><div>
                        <div class="kpi-value text-accent">${formatCurrency(data.summary.lifetime_spend)}</div>
                        <div class="kpi-label">Lifetime Spend</div>
                    </div></div></div>
                </div>
                <table class="data-table">
                    <thead><tr><th>Order #</th><th>Date</th><th>Amount</th><th>Status</th><th>Items</th></tr></thead>
                    <tbody>
                        ${data.orders.map(o => `
                            <tr>
                                <td>#${o.order_id}</td>
                                <td>${formatDateTime(o.order_date)}</td>
                                <td class="font-mono">${formatCurrency(o.total_amount)}</td>
                                <td>${statusBadge(o.order_status)}</td>
                                <td>${o.items_count}</td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
        } else {
            html += '<div class="empty-state"><span class="icon">📋</span><h3>No orders found</h3></div>';
        }

        content.innerHTML = html;
        openModal('orderDetailsModal');
    } catch (err) {
        showToast(err.message, 'error');
    }
}
