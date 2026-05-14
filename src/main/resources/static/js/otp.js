(function () {
    'use strict';

    const groups = document.querySelectorAll('[data-otp-group]');
    groups.forEach(wireGroup);

    function wireGroup(group) {
        const inputs = Array.from(group.querySelectorAll('input:not([type=hidden])'));
        const output = group.parentElement.querySelector('[data-otp-output]');
        if (inputs.length === 0) return;

        inputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                const v = input.value.replace(/\D/g, '').slice(0, 1);
                input.value = v;
                if (v && index < inputs.length - 1) inputs[index + 1].focus();
                sync();
            });

            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && !input.value && index > 0) {
                    inputs[index - 1].focus();
                    inputs[index - 1].value = '';
                    sync();
                    e.preventDefault();
                } else if (e.key === 'ArrowLeft' && index > 0) {
                    inputs[index - 1].focus();
                    e.preventDefault();
                } else if (e.key === 'ArrowRight' && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                    e.preventDefault();
                }
            });

            input.addEventListener('paste', (e) => {
                const data = (e.clipboardData || window.clipboardData).getData('text');
                const digits = (data || '').replace(/\D/g, '').slice(0, inputs.length);
                if (!digits) return;
                e.preventDefault();
                digits.split('').forEach((d, i) => { inputs[i].value = d; });
                const next = Math.min(digits.length, inputs.length - 1);
                inputs[next].focus();
                sync();
            });
        });

        function sync() {
            if (output) output.value = inputs.map((i) => i.value).join('');
        }
    }

    // Countdown timer — element with [data-otp-timer="120"] becomes a mm:ss display.
    document.querySelectorAll('[data-otp-timer]').forEach((el) => {
        let remaining = parseInt(el.getAttribute('data-otp-timer'), 10) || 0;
        const useBangla = el.getAttribute('data-digits') === 'bangla';
        render();
        const handle = setInterval(() => {
            remaining -= 1;
            render();
            if (remaining <= 0) {
                clearInterval(handle);
                el.dispatchEvent(new CustomEvent('otp:timeout', { bubbles: true }));
            }
        }, 1000);

        function render() {
            const mm = String(Math.max(0, Math.floor(remaining / 60))).padStart(2, '0');
            const ss = String(Math.max(0, remaining % 60)).padStart(2, '0');
            const text = mm + ':' + ss;
            el.textContent = useBangla ? toBangla(text) : text;
        }
    });

    function toBangla(s) {
        const map = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
        return s.replace(/\d/g, (d) => map[+d]);
    }
})();
