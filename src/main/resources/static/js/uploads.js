(function () {
    'use strict';

    // ----- Image picker modal: choose camera vs gallery before opening any file input. -----
    const pickerModal = document.getElementById('imagePickerModal');
    if (pickerModal) {
        const pickerView = pickerModal.querySelector('[data-image-picker-view="picker"]');
        const captureView = pickerModal.querySelector('[data-image-picker-view="capture"]');
        const video = pickerModal.querySelector('[data-image-picker-video]');
        const canvas = pickerModal.querySelector('[data-image-picker-canvas]');
        const snapBtn = pickerModal.querySelector('[data-image-picker-snap]');
        const status = pickerModal.querySelector('[data-image-picker-status]');
        const statusText = pickerModal.querySelector('[data-image-picker-status-text]');
        const isTouchPrimary = window.matchMedia && window.matchMedia('(pointer: coarse)').matches;
        const canUseWebcam = !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia);
        let currentStream = null;

        function showPickerView() {
            pickerView.classList.remove('hidden');
            captureView.classList.add('hidden');
        }
        function showCaptureView() {
            pickerView.classList.add('hidden');
            captureView.classList.remove('hidden');
        }
        function setStatus(text) {
            if (!status || !statusText) return;
            if (text) { statusText.textContent = text; status.classList.remove('hidden'); }
            else { status.classList.add('hidden'); }
        }
        function stopStream() {
            if (currentStream) {
                currentStream.getTracks().forEach((t) => t.stop());
                currentStream = null;
            }
            if (video) video.srcObject = null;
            if (snapBtn) snapBtn.disabled = true;
        }
        async function startStream() {
            setStatus('ক্যামেরা চালু করা হচ্ছে…');
            if (snapBtn) snapBtn.disabled = true;
            try {
                currentStream = await navigator.mediaDevices.getUserMedia({
                    video: { facingMode: 'environment' },
                    audio: false
                });
                video.srcObject = currentStream;
                await video.play();
                setStatus(null);
                if (snapBtn) snapBtn.disabled = false;
            } catch (err) {
                let msg = 'ক্যামেরা চালু করা যায়নি।';
                if (err && err.name === 'NotAllowedError') msg = 'ক্যামেরা ব্যবহারের অনুমতি দেওয়া হয়নি।';
                else if (err && err.name === 'NotFoundError') msg = 'কোনো ক্যামেরা খুঁজে পাওয়া যায়নি।';
                setStatus(msg);
            }
        }
        function snapAndDeliver() {
            const target = currentTarget();
            if (!target || !video || !canvas || !video.videoWidth) return;
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            canvas.getContext('2d').drawImage(video, 0, 0, canvas.width, canvas.height);
            canvas.toBlob((blob) => {
                if (!blob) return;
                const file = new File([blob], 'camera-' + Date.now() + '.jpg', { type: 'image/jpeg' });
                try {
                    const dt = new DataTransfer();
                    dt.items.add(file);
                    target.files = dt.files;
                } catch (e) {
                    // DataTransfer write may be blocked in some browsers — bail.
                    setStatus('এই ব্রাউজারে ছবি স্থানান্তর করা যায়নি।');
                    return;
                }
                target.dispatchEvent(new Event('change', { bubbles: true }));
                stopStream();
                closePicker();
            }, 'image/jpeg', 0.9);
        }
        function currentTarget() {
            const id = pickerModal.dataset.targetId;
            return id ? document.getElementById(id) : null;
        }

        function openPicker(targetInput) {
            if (!targetInput) return;
            if (!targetInput.id) {
                targetInput.id = 'imgPicker_' + Math.random().toString(36).slice(2);
            }
            pickerModal.dataset.targetId = targetInput.id;
            showPickerView();
            pickerModal.classList.remove('hidden');
            pickerModal.classList.add('flex');
            pickerModal.setAttribute('aria-hidden', 'false');
        }
        function closePicker() {
            stopStream();
            showPickerView();
            pickerModal.classList.add('hidden');
            pickerModal.classList.remove('flex');
            pickerModal.setAttribute('aria-hidden', 'true');
            pickerModal.dataset.targetId = '';
        }
        window.openImagePicker = openPicker;

        pickerModal.addEventListener('click', (e) => {
            const inDialog = e.target.closest('[data-image-picker-stop]');
            const actionBtn = e.target.closest('[data-image-picker-action]');
            if (!inDialog) { closePicker(); return; }
            if (!actionBtn) return;
            const action = actionBtn.dataset.imagePickerAction;
            const target = currentTarget();

            if (action === 'cancel') { closePicker(); return; }
            if (action === 'back') { stopStream(); showPickerView(); return; }
            if (action === 'snap') { snapAndDeliver(); return; }

            if (!target) { closePicker(); return; }

            if (action === 'file') {
                target.removeAttribute('capture');
                closePicker();
                target.click();
                return;
            }
            if (action === 'camera') {
                // Touch devices: hand off to the OS camera app via native capture.
                // Desktop: stream the webcam inline.
                if (isTouchPrimary || !canUseWebcam) {
                    target.setAttribute('capture', 'environment');
                    closePicker();
                    target.click();
                } else {
                    showCaptureView();
                    startStream();
                }
            }
        });
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && !pickerModal.classList.contains('hidden')) closePicker();
        });

        // Intercept clicks on labels that point at image file inputs.
        // In upload-zone markup the input lives INSIDE the label, so when we later call
        // input.click() the resulting click bubbles up here — skip those bubbled events.
        document.querySelectorAll('input[type="file"]').forEach((input) => {
            const accept = (input.getAttribute('accept') || '').toLowerCase();
            if (!accept.includes('image')) return;
            if (!input.id) return;
            document.querySelectorAll('label[for="' + input.id + '"]').forEach((label) => {
                label.addEventListener('click', (e) => {
                    if (e.target === input) return;
                    e.preventDefault();
                    openPicker(input);
                });
            });
        });
    }

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
