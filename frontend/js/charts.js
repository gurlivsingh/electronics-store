// ============================================================
// charts.js — Chart.js Analytics Charts for Reports Page
// ============================================================

let chartCategoryRevenue = null;
let chartOrderStatus     = null;
let chartMonthlySales    = null;

// Shared Chart.js defaults — dark theme
Chart.defaults.color = '#94a3b8';
Chart.defaults.borderColor = 'rgba(255,255,255,0.07)';
Chart.defaults.font.family = "'Inter', 'Segoe UI', sans-serif";

const PALETTE = [
    '#4F9CF7', '#00D4AA', '#A29BFE', '#FD79A8',
    '#FDCB6E', '#55EFC4', '#E17055', '#74B9FF'
];

// ── Destroy a chart instance safely ─────────────────────────
function destroyChart(instance) {
    if (instance) { instance.destroy(); }
    return null;
}

// ── 1. BAR CHART: Revenue by Category ───────────────────────
async function loadCategoryRevenueChart() {
    try {
        const data = await apiGet('/reports/categories');
        if (!data || data.length === 0) return;

        const labels   = data.map(c => c.category_name);
        const revenues = data.map(c => parseFloat(c.total_revenue || 0));

        chartCategoryRevenue = destroyChart(chartCategoryRevenue);
        const ctx = document.getElementById('chartCategoryRevenue').getContext('2d');

        chartCategoryRevenue = new Chart(ctx, {
            type: 'bar',
            data: {
                labels,
                datasets: [{
                    label: 'Revenue (₹)',
                    data: revenues,
                    backgroundColor: PALETTE,
                    borderRadius: 8,
                    borderSkipped: false,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => ' ₹' + ctx.parsed.y.toLocaleString('en-IN')
                        }
                    }
                },
                scales: {
                    x: { grid: { display: false }, ticks: { font: { size: 11 } } },
                    y: {
                        ticks: {
                            callback: v => '₹' + (v / 1000).toFixed(0) + 'K',
                            font: { size: 11 }
                        }
                    }
                }
            }
        });
    } catch (e) { console.warn('Category chart error:', e.message); }
}

// ── 2. DOUGHNUT CHART: Order Status ─────────────────────────
async function loadOrderStatusChart() {
    try {
        const data = await apiGet('/orders');
        if (!data || data.length === 0) return;

        // Count orders per status
        const counts = {};
        data.forEach(o => { counts[o.order_status] = (counts[o.order_status] || 0) + 1; });

        const labels = Object.keys(counts);
        const values = Object.values(counts);

        const statusColors = {
            'Delivered':  '#00D4AA',
            'Shipped':    '#4F9CF7',
            'Confirmed':  '#A29BFE',
            'Pending':    '#FDCB6E',
            'Cancelled':  '#E17055'
        };
        const bgColors = labels.map(l => statusColors[l] || '#74B9FF');

        chartOrderStatus = destroyChart(chartOrderStatus);
        const ctx = document.getElementById('chartOrderStatus').getContext('2d');

        chartOrderStatus = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels,
                datasets: [{
                    data: values,
                    backgroundColor: bgColors,
                    borderWidth: 2,
                    borderColor: '#1e293b',
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { padding: 16, font: { size: 12 }, usePointStyle: true }
                    },
                    tooltip: {
                        callbacks: {
                            label: ctx => ` ${ctx.label}: ${ctx.parsed} orders`
                        }
                    }
                }
            }
        });
    } catch (e) { console.warn('Order status chart error:', e.message); }
}

// ── 3. LINE CHART: Monthly Sales Trend ──────────────────────
async function loadMonthlySalesChart() {
    try {
        const data = await apiGet('/orders');
        if (!data || data.length === 0) return;

        // Group total_amount by month
        const monthly = {};
        const months  = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        months.forEach((m, i) => { monthly[i + 1] = 0; });

        data.forEach(o => {
            const month = new Date(o.order_date).getMonth() + 1;
            monthly[month] = (monthly[month] || 0) + parseFloat(o.total_amount || 0);
        });

        const values = months.map((_, i) => monthly[i + 1] || 0);

        chartMonthlySales = destroyChart(chartMonthlySales);
        const ctx = document.getElementById('chartMonthlySales').getContext('2d');

        // Gradient fill
        const gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(79, 156, 247, 0.4)');
        gradient.addColorStop(1, 'rgba(79, 156, 247, 0.0)');

        chartMonthlySales = new Chart(ctx, {
            type: 'line',
            data: {
                labels: months,
                datasets: [{
                    label: 'Revenue (₹)',
                    data: values,
                    borderColor: '#4F9CF7',
                    backgroundColor: gradient,
                    pointBackgroundColor: '#4F9CF7',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 8,
                    tension: 0.4,
                    fill: true,
                    borderWidth: 2.5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => ' ₹' + ctx.parsed.y.toLocaleString('en-IN')
                        }
                    }
                },
                scales: {
                    x: { grid: { display: false } },
                    y: {
                        ticks: {
                            callback: v => '₹' + (v / 1000).toFixed(0) + 'K'
                        }
                    }
                }
            }
        });
    } catch (e) { console.warn('Monthly sales chart error:', e.message); }
}

// ── Load all three charts ────────────────────────────────────
async function loadAllCharts() {
    await Promise.all([
        loadCategoryRevenueChart(),
        loadOrderStatusChart(),
        loadMonthlySalesChart()
    ]);
}

// Auto-load charts when Reports page becomes active
// Hook into app.js navigateTo by observing section visibility
document.addEventListener('DOMContentLoaded', () => {
    // Watch for reports page activation
    const observer = new MutationObserver(() => {
        const reportsPage = document.getElementById('page-reports');
        if (reportsPage && reportsPage.classList.contains('active')) {
            loadAllCharts();
        }
    });
    const target = document.getElementById('page-reports');
    if (target) {
        observer.observe(target, { attributes: true, attributeFilter: ['class'] });
    }
});
