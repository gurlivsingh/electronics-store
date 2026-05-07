// ============================================================
// clock.js — Real-time Date & Time Display
// ============================================================

function updateClock() {
    const now = new Date();

    // Time: HH:MM:SS
    const timeStr = now.toLocaleTimeString('en-IN', {
        hour:   '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: true
    });

    // Date: Mon, 08 May 2026
    const dateStr = now.toLocaleDateString('en-IN', {
        weekday: 'short',
        day:     '2-digit',
        month:   'short',
        year:    'numeric'
    });

    const timeEl = document.getElementById('clockTime');
    const dateEl = document.getElementById('clockDate');

    if (timeEl) timeEl.textContent = timeStr;
    if (dateEl) dateEl.textContent = dateStr;
}

// Update immediately, then every second
updateClock();
setInterval(updateClock, 1000);
