// ============================================================
// inventory.js — Inventory Management UI
// ============================================================

async function loadInventory() {
    const tbody = document.getElementById('inventoryBody');
    tbody.innerHTML = '<tr><td colspan="9"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        const inventory = await apiGet('/inventory');

        if (inventory.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9"><div class="empty-state"><span class="icon">🏪</span><h3>No inventory records</h3></div></td></tr>';
            return;
        }

        tbody.innerHTML = inventory.map(i => `
            <tr>
                <td><strong>${i.product_name}</strong></td>
                <td>${i.brand}</td>
                <td><span class="badge badge-purple">${i.category_name}</span></td>
                <td class="font-mono">${formatCurrency(i.price)}</td>
                <td><strong class="${i.quantity_in_stock === 0 ? 'text-danger' : i.quantity_in_stock < i.reorder_level ? 'text-warning' : ''}">${i.quantity_in_stock}</strong></td>
                <td>${i.reorder_level}</td>
                <td class="font-mono">${formatCurrency(i.stock_value)}</td>
                <td>${stockBadge(i.stock_health)}</td>
                <td>
                    <button class="btn btn-accent btn-sm" onclick="quickRestock(${i.product_id}, '${i.product_name}')">📥 Restock</button>
                </td>
            </tr>
        `).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="9" class="text-center text-danger">${err.message}</td></tr>`;
    }
}

function quickRestock(productId, productName) {
    const qty = prompt(`Restock "${productName}" — Enter quantity to add:`);
    if (!qty || isNaN(qty) || qty <= 0) return;

    apiPost('/inventory/restock', { product_id: productId, quantity: parseInt(qty) })
        .then(() => {
            showToast(`Restocked "${productName}" with ${qty} units`, 'success');
            loadInventory();
            loadDashboard();
        })
        .catch(err => showToast(err.message, 'error'));
}

async function submitRestock(e) {
    e.preventDefault();
    try {
        await apiPost('/inventory/restock', {
            product_id: document.getElementById('restock_product').value,
            quantity: parseInt(document.getElementById('restock_qty').value)
        });
        showToast('Product restocked successfully!', 'success');
        closeModal('restockModal');
        document.getElementById('restockForm').reset();
        loadInventory();
        loadDashboard();
    } catch (err) {
        showToast(err.message, 'error');
    }
    return false;
}
