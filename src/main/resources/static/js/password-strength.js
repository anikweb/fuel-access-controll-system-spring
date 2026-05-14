(function () {
    'use strict';

    const LABELS = ['', 'দুর্বল', 'মাঝারি', 'শক্তিশালী', 'খুব শক্তিশালী'];

    function score(pw) {
        if (!pw) return 0;
        let s = 0;
        if (pw.length >= 8) s++;
        if (/\d/.test(pw)) s++;
        if (/[a-z]/.test(pw) && /[A-Z]/.test(pw)) s++;
        if (/[^A-Za-z0-9]/.test(pw)) s++;
        return Math.min(s, 4);
    }

    document.querySelectorAll('[data-strength-meter]').forEach((meter) => {
        const input = document.getElementById(meter.getAttribute('data-target'));
        const bar = meter.querySelector('[data-strength-bar]');
        const label = meter.querySelector('[data-strength-label]');
        if (!input || !bar || !label) return;

        function update() {
            const s = score(input.value);
            bar.setAttribute('data-strength', String(s));
            label.setAttribute('data-strength', String(s));
            label.textContent = LABELS[s];
        }

        input.addEventListener('input', update);
        update();
    });
})();
