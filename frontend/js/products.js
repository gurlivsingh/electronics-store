// ============================================================
// products.js — Product Management UI
// ============================================================

async function loadProducts() {
    const tbody = document.getElementById('productsBody');
    tbody.innerHTML = '<tr><td colspan="8"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        let products = await apiGet('/products');

        // Apply category filter
        const filter = document.getElementById('productCategoryFilter').value;
        if (filter) {
            products = products.filter(p => p.category_id == filter);
        }

        if (products.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state"><span class="icon">📦</span><h3>No products found</h3><p>Add your first product to get started</p></div></td></tr>';
            return;
        }

        tbody.innerHTML = products.map(p => `
            <tr>
                <td>${p.product_id}</td>
                <td>
                    <strong>${p.product_name}</strong>
                    ${p.specifications ? `<br><small class="text-muted truncate">${p.specifications}</small>` : ''}
                </td>
                <td>${p.brand}</td>
                <td><span class="badge badge-purple">${p.category_name}</span></td>
                <td class="font-mono">${formatCurrency(p.price)}</td>
                <td><strong>${p.quantity_in_stock ?? 0}</strong></td>
                <td>${statusBadgeForStock(p.stock_status)}</td>
                <td>
                    <button class="btn btn-ghost btn-sm btn-icon" onclick="deleteProduct(${p.product_id})" title="Deactivate">🗑️</button>
                </td>
            </tr>
        `).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="8" class="text-center text-danger" style="padding:30px">Failed to load products: ${err.message}</td></tr>`;
    }
}

function statusBadgeForStock(status) {
    const map = {
        'In Stock': 'stock-healthy',
        'Low Stock': 'stock-low',
        'Out of Stock': 'stock-out'
    };
    return `<span class="badge ${map[status] || 'badge-info'}">${status || 'Unknown'}</span>`;
}

async function submitProduct(e) {
    e.preventDefault();
    try {
        await apiPost('/products', {
            product_name: document.getElementById('prod_name').value,
            category_id: document.getElementById('prod_category').value,
            price: document.getElementById('prod_price').value,
            brand: document.getElementById('prod_brand').value,
            specifications: document.getElementById('prod_specs').value
        });
        showToast('Product added successfully!', 'success');
        closeModal('productModal');
        document.getElementById('productForm').reset();
        loadProducts();
        loadDashboard();
    } catch (err) {
        showToast(err.message, 'error');
    }
    return false;
}

async function deleteProduct(id) {
    if (!confirm('Are you sure you want to deactivate this product?')) return;
    try {
        await apiDelete(`/products/${id}`);
        showToast('Product deactivated', 'warning');
        loadProducts();
    } catch (err) {
        showToast(err.message, 'error');
    }
}
