// ============================================================
// orders.js — Orders & Billing UI
// ============================================================

async function loadOrders() {
    const tbody = document.getElementById('ordersBody');
    tbody.innerHTML = '<tr><td colspan="9"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        const orders = await apiGet('/orders');

        if (orders.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9"><div class="empty-state"><span class="icon">🧾</span><h3>No orders yet</h3><p>Create your first order</p></div></td></tr>';
            return;
        }

        tbody.innerHTML = orders.map(o => `
            <tr>
                <td><strong>#${o.order_id}</strong></td>
                <td>${formatDateTime(o.order_date)}</td>
                <td>${o.customer_name}</td>
                <td>${o.employee_name}</td>
                <td>${o.items_count}</td>
                <td class="font-mono">${formatCurrency(o.total_amount)}</td>
                <td><span class="badge badge-info">${o.payment_method}</span></td>
                <td>${statusBadge(o.order_status)}</td>
                <td>
                    <button class="btn btn-ghost btn-sm btn-icon" onclick="viewOrderDetails(${o.order_id})" title="View Details">👁️</button>
                    <button class="btn btn-ghost btn-sm btn-icon" onclick="addItemToOrder(${o.order_id})" title="Add Item">➕</button>
                    <button class="btn btn-ghost btn-sm btn-icon" onclick="updateOrderStatus(${o.order_id}, '${o.order_status}')" title="Update Status">🔄</button>
                </td>
            </tr>
        `).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="9" class="text-center text-danger" style="padding:30px">${err.message}</td></tr>`;
    }
}

async function submitOrder(e) {
    e.preventDefault();
    try {
        const result = await apiPost('/orders', {
            customer_id: document.getElementById('order_customer').value,
            employee_id: document.getElementById('order_employee').value,
            payment_method: document.getElementById('order_payment').value
        });
        showToast(`Order #${result.id} created! Now add items.`, 'success');
        closeModal('orderModal');
        document.getElementById('orderForm').reset();
        loadOrders();
        loadDashboard();

        // Open add item modal for the new order
        setTimeout(() => addItemToOrder(result.id), 500);
    } catch (err) {
        showToast(err.message, 'error');
    }
    return false;
}

function addItemToOrder(orderId) {
    document.getElementById('item_order_id').value = orderId;
    openModal('orderItemModal');
}

async function submitOrderItem(e) {
    e.preventDefault();
    const orderId = document.getElementById('item_order_id').value;
    try {
        await apiPost(`/orders/${orderId}/items`, {
            product_id: document.getElementById('item_product').value,
            quantity: document.getElementById('item_quantity').value
        });
        showToast('Item added to order! (Stock auto-decremented via trigger)', 'success');
        closeModal('orderItemModal');
        document.getElementById('orderItemForm').reset();
        loadOrders();
        loadDashboard();
    } catch (err) {
        showToast(err.message, 'error');
    }
    return false;
}

async function viewOrderDetails(orderId) {
    const content = document.getElementById('orderDetailsContent');
    content.innerHTML = '<div class="loading-spinner"><div class="spinner"></div></div>';
    openModal('orderDetailsModal');

    try {
        const order = await apiGet(`/orders/${orderId}`);

        content.innerHTML = `
            <div class="invoice">
                <div class="invoice-header">
                    <h2>⚡ ElectraStore</h2>
                    <p class="text-muted" style="margin-top:4px">Electronics Store Management System</p>
                </div>
                <div class="invoice-details">
                    <div>
                        <p><strong>Order:</strong> #${order.order_id}</p>
                        <p><strong>Date:</strong> ${formatDateTime(order.order_date)}</p>
                        <p><strong>Status:</strong> ${statusBadge(order.order_status)}</p>
                    </div>
                    <div>
                        <p><strong>Customer:</strong> ${order.customer_name}</p>
                        <p><strong>Email:</strong> ${order.email || '—'}</p>
                        <p><strong>Payment:</strong> ${order.payment_method}</p>
                    </div>
                </div>
                
                <table class="data-table" style="margin-bottom:0">
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Brand</th>
                            <th>Qty</th>
                            <th>Price</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${order.items && order.items.length > 0 ? order.items.map(item => `
                            <tr>
                                <td>${item.product_name}</td>
                                <td>${item.brand}</td>
                                <td>${item.quantity}</td>
                                <td class="font-mono">${formatCurrency(item.unit_price)}</td>
                                <td class="font-mono">${formatCurrency(item.subtotal)}</td>
                            </tr>
                        `).join('') : '<tr><td colspan="5" class="text-center text-muted">No items in this order</td></tr>'}
                    </tbody>
                </table>
                
                <div class="invoice-total">
                    <p class="text-secondary">Grand Total</p>
                    <p class="amount">${formatCurrency(order.total_amount)}</p>
                </div>
            </div>
        `;
    } catch (err) {
        content.innerHTML = `<div class="empty-state"><span class="icon">❌</span><h3>${err.message}</h3></div>`;
    }
}

async function updateOrderStatus(orderId, currentStatus) {
    const statuses = ['Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'];
    const nextIndex = (statuses.indexOf(currentStatus) + 1) % statuses.length;
    const newStatus = prompt(`Update order #${orderId} status to:`, statuses[nextIndex]);

    if (!newStatus || !statuses.includes(newStatus)) return;

    try {
        await apiPut(`/orders/${orderId}/status`, { order_status: newStatus });
        showToast(`Order #${orderId} status updated to "${newStatus}"`, 'success');
        loadOrders();
    } catch (err) {
        showToast(err.message, 'error');
    }
}
