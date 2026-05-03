// ============================================================
// employees.js — Employee Management UI
// ============================================================

async function loadEmployees() {
    const tbody = document.getElementById('employeesBody');
    tbody.innerHTML = '<tr><td colspan="9"><div class="loading-spinner"><div class="spinner"></div></div></td></tr>';

    try {
        const employees = await apiGet('/employees');

        if (employees.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9"><div class="empty-state"><span class="icon">👔</span><h3>No employees</h3></div></td></tr>';
            return;
        }

        tbody.innerHTML = employees.map(e => `
            <tr>
                <td>${e.employee_id}</td>
                <td><strong>${e.first_name} ${e.last_name}</strong></td>
                <td><span class="badge badge-info">${e.role}</span></td>
                <td>${e.email}</td>
                <td>${e.phone || '—'}</td>
                <td>${formatDate(e.hire_date)}</td>
                <td class="font-mono">${formatCurrency(e.salary)}</td>
                <td>${e.orders_handled || 0}</td>
                <td>
                    <button class="btn btn-ghost btn-sm btn-icon" onclick="deleteEmployee(${e.employee_id})" title="Delete">🗑️</button>
                </td>
            </tr>
        `).join('');
    } catch (err) {
        tbody.innerHTML = `<tr><td colspan="9" class="text-center text-danger">${err.message}</td></tr>`;
    }
}

async function submitEmployee(e) {
    e.preventDefault();
    try {
        await apiPost('/employees', {
            first_name: document.getElementById('emp_fname').value,
            last_name: document.getElementById('emp_lname').value,
            role: document.getElementById('emp_role').value,
            email: document.getElementById('emp_email').value,
            phone: document.getElementById('emp_phone').value,
            salary: document.getElementById('emp_salary').value
        });
        showToast('Employee added successfully!', 'success');
        closeModal('employeeModal');
        document.getElementById('employeeForm').reset();
        loadEmployees();
    } catch (err) {
        showToast(err.message, 'error');
    }
    return false;
}

async function deleteEmployee(id) {
    if (!confirm('Delete this employee?')) return;
    try {
        await apiDelete(`/employees/${id}`);
        showToast('Employee deleted', 'warning');
        loadEmployees();
    } catch (err) {
        showToast(err.message, 'error');
    }
}
