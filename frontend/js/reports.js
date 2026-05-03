// ============================================================
// reports.js — Reports & Analytics UI
// ============================================================

async function loadSalesReport() {
    const startDate = document.getElementById('reportStartDate').value;
    const endDate = document.getElementById('reportEndDate').value;
    const tbody = document.getElementById('salesReportBody');
    const summaryDiv = document.getElementById('salesReportSummary');

    tbody.innerHTML = '<tr><td colspan="5"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        const data = await apiGet(`/reports/sales?start_date=${startDate}&end_date=${endDate}`);

        // Summary KPIs
        const s = data.summary || {};
        summaryDiv.innerHTML = `
            <div class="kpi-card">
                <div class="kpi-header">
                    <div>
                        <div class="kpi-value text-primary">${s.total_orders || 0}</div>
                        <div class="kpi-label">Total Orders</div>
                    </div>
                    <div class="kpi-icon" style="background:rgba(79,156,247,0.15);color:var(--primary)">🧾</div>
                </div>
            </div>
            <div class="kpi-card">
                <div class="kpi-header">
                    <div>
                        <div class="kpi-value text-accent">${formatCurrency(s.grand_total)}</div>
                        <div class="kpi-label">Grand Total</div>
                    </div>
                    <div class="kpi-icon" style="background:rgba(0,212,170,0.15);color:var(--accent)">💰</div>
                </div>
            </div>
            <div class="kpi-card">
                <div class="kpi-header">
                    <div>
                        <div class="kpi-value" style="color:#A29BFE">${formatCurrency(s.average_order_value)}</div>
                        <div class="kpi-label">Avg Order Value</div>
                    </div>
                    <div class="kpi-icon" style="background:rgba(162,155,254,0.15);color:#A29BFE">📊</div>
                </div>
            </div>
        `;

        // Orders table
        const orders = data.orders || [];
        if (orders.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:40px">No orders found in this date range</td></tr>';
            return;
        }

        tbody.innerHTML = orders.map(o => `
            <tr>
                <td><strong>#${o.order_id}</strong></td>
                <td>${o.customer_name}</td>
                <td>${formatDateTime(o.order_date)}</td>
                <td class="font-mono">${formatCurrency(o.total_amount)}</td>
                <td>${statusBadge(o.order_status)}</td>
            </tr>
        `).join('');

        showToast(`Sales report generated: ${orders.length} orders found`, 'success');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">${err.message}</td></tr>`;
        summaryDiv.innerHTML = '';
    }
}

async function loadCategorySummary() {
    const tbody = document.getElementById('categorySummaryBody');
    tbody.innerHTML = '<tr><td colspan="5"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        const data = await apiGet('/reports/categories');

        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted" style="padding:30px">No category data available</td></tr>';
            return;
        }

        tbody.innerHTML = data.map(c => `
            <tr>
                <td><span class="badge badge-purple">${c.category_name}</span></td>
                <td>${c.total_products}</td>
                <td>${c.total_units_sold}</td>
                <td class="font-mono"><strong>${formatCurrency(c.total_revenue)}</strong></td>
                <td class="font-mono">${formatCurrency(c.avg_product_price)}</td>
            </tr>
        `).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">${err.message}</td></tr>`;
    }
}

async function loadTopProducts() {
    const tbody = document.getElementById('topProductsBody');
    tbody.innerHTML = '<tr><td colspan="6"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        const data = await apiGet('/reports/top-products');

        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted" style="padding:30px">No sales data available</td></tr>';
            return;
        }

        const medals = ['🥇', '🥈', '🥉'];
        tbody.innerHTML = data.map((p, i) => `
            <tr>
                <td>${medals[i] || `#${i + 1}`}</td>
                <td><strong>${p.product_name}</strong></td>
                <td>${p.brand}</td>
                <td><span class="badge badge-purple">${p.category_name}</span></td>
                <td>${p.total_sold}</td>
                <td class="font-mono"><strong>${formatCurrency(p.total_revenue)}</strong></td>
            </tr>
        `).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">${err.message}</td></tr>`;
    }
}
