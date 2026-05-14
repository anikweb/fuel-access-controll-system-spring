(function () {
    'use strict';

    // ----- Avatar picker: live preview, hide icon fallback once picked -----
    document.querySelectorAll('[data-avatar-root]').forEach((root) => {
        const input = root.querySelector('[data-avatar-input]');
        const img = root.querySelector('[data-avatar-img]');
        const fallback = root.querySelector('[data-avatar-fallback]');
        if (!input || !img) return;

        input.addEventListener('change', () => {
            const file = input.files && input.files[0];
            if (!file) return;
            const reader = new FileReader();
            reader.onload = (e) => {
                img.src = e.target.result;
                img.classList.remove('hidden');
                if (fallback) fallback.classList.add('hidden');
            };
            reader.readAsDataURL(file);
        });
    });

    // ----- Upload zones: image preview, filename echo, drag/drop -----
    document.querySelectorAll('[data-upload-zone]').forEach((zone) => {
        const input = zone.querySelector('[data-upload-input]');
        const placeholder = zone.querySelector('[data-upload-placeholder]');
        const preview = zone.querySelector('[data-upload-preview]');
        const overlay = zone.querySelector('[data-upload-overlay]');
        const label = zone.querySelector('[data-upload-label]');
        if (!input) return;

        const originalLabelText = label ? label.textContent : '';

        input.addEventListener('change', () => {
            const file = input.files && input.files[0];
            if (!file) {
                resetPreview();
                return;
            }
            if (file.type.startsWith('image/')) {
                const reader = new FileReader();
                reader.onload = (e) => showImagePreview(e.target.result);
                reader.readAsDataURL(file);
            } else if (label) {
                label.textContent = file.name;
            }
        });

        function showImagePreview(dataUrl) {
            if (!preview) return;
            preview.src = dataUrl;
            preview.classList.remove('hidden');

            if (placeholder) placeholder.classList.add('hidden');

            if (overlay) {
                overlay.classList.remove('hidden');
                overlay.classList.add('flex');
            }

            zone.classList.remove('border-dashed', 'hover:bg-gray-100');
            zone.classList.add('border-solid', 'border-gray-200');
        }

        function resetPreview() {
            if (preview) {
                preview.src = '';
                preview.classList.add('hidden');
            }
            if (placeholder) placeholder.classList.remove('hidden');
            if (overlay) {
                overlay.classList.remove('flex');
                overlay.classList.add('hidden');
            }
            if (label) label.textContent = originalLabelText;
            zone.classList.add('border-dashed', 'hover:bg-gray-100');
            zone.classList.remove('border-solid', 'border-gray-200');
        }

        // Drag/drop highlight + file handoff
        ['dragenter', 'dragover'].forEach((ev) =>
            zone.addEventListener(ev, (e) => {
                e.preventDefault();
                zone.classList.add('border-brand', 'bg-brand/5');
            })
        );
        ['dragleave', 'drop'].forEach((ev) =>
            zone.addEventListener(ev, () => {
                zone.classList.remove('border-brand', 'bg-brand/5');
            })
        );
        zone.addEventListener('drop', (e) => {
            e.preventDefault();
            if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files.length) {
                input.files = e.dataTransfer.files;
                input.dispatchEvent(new Event('change'));
            }
        });
    });
})();
