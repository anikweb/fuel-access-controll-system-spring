<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
            <my:panelLayout title="নতুন বিতরণ | FACS">

                <jsp:attribute name="sidebar">
                    <article
                        class="bg-white border border-gray-200 rounded-2xl p-6 flex flex-col items-center text-center shadow-sm">
                        <div
                            class="w-24 h-24 rounded-full overflow-hidden bg-gray-100 ring-2 ring-brand ring-offset-2 ring-offset-white">
                            <c:choose>
                                <c:when test="${not empty operator.photoUrl}">
                                    <img src="<c:out value='${operator.photoUrl}'/>" alt=""
                                        class="w-full h-full object-cover" />
                                </c:when>
                                <c:otherwise>
                                    <img src="<c:url value='/img/avatar-placeholder.svg'/>" alt=""
                                        class="w-full h-full object-cover" />
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <h2 class="mt-4 text-[18px] font-bold text-gray-900 leading-tight">
                            <c:out value="${operator.name}" />
                        </h2>
                        <p class="mt-1.5 text-sm text-gray-500">অপারেটর আইডি: ${operator.displayId}</p>
                        <a href="<c:url value='/operator/transactions/new'/>"
                            class="mt-5 w-full inline-flex items-center justify-center gap-2 rounded-lg bg-brand text-white px-4 py-3 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                            <my:icon name="plus" />
                            <span>নতুন বিতরণ</span>
                        </a>
                    </article>

                    <c:if test="${not empty station}">
                        <article class="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm">
                            <p class="text-[13px] font-semibold text-gray-500">স্টেশন</p>
                            <p class="mt-3 text-[15px] font-semibold text-gray-900 leading-snug">
                                <c:out value="${station.name}" />
                            </p>
                            <p class="mt-1 text-sm text-gray-500 leading-snug">
                                <c:out value="${station.location}" />
                            </p>
                        </article>
                    </c:if>
                </jsp:attribute>

                <jsp:attribute name="sidebarFooter">
                    <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন" />
                </jsp:attribute>

                <jsp:body>
                    <section class="w-full max-w-3xl mx-auto flex flex-col gap-6">

                        <header>
                            <h1 class="text-[28px] sm:text-[32px] font-bold text-brand tracking-tight leading-snug">নতুন
                                বিতরণ</h1>
                            <p class="mt-2 text-sm text-gray-500">লাইসেন্স প্লেটের ছবি আপলোড করুন। সিস্টেম যানবাহনের
                                তথ্য যাচাই করবে।</p>
                        </header>

                        <c:if test="${not empty error}">
                            <div
                                class="rounded-lg border border-red-200 bg-red-50 text-brand-red px-4 py-3 text-sm font-medium">
                                <c:out value="${error}" />
                            </div>
                        </c:if>

                        <form action="<c:url value='/operator/transactions/verify'/>" method="post"
                            enctype="multipart/form-data"
                            class="bg-white border border-gray-200 rounded-2xl p-6 sm:p-8 shadow-sm flex flex-col gap-6">
                            <c:if test="${not empty _csrf}">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            </c:if>

                            <div class="flex flex-col gap-3">
                                <label class="text-[13px] font-semibold text-gray-700">প্লেটের ছবি</label>
                                <label for="photo"
                                    class="relative group flex flex-col items-center justify-center gap-3 rounded-2xl border-2 border-dashed border-gray-300 bg-gray-50 px-6 py-12 min-h-[260px] cursor-pointer transition hover:border-brand hover:bg-brand/5 overflow-hidden"
                                    data-upload-zone>

                                    <div class="flex flex-col items-center gap-3" data-upload-placeholder>
                                        <span
                                            class="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand/10 text-brand [&>svg]:w-7 [&>svg]:h-7">
                                            <my:icon name="camera" />
                                        </span>
                                        <p class="text-base font-semibold text-gray-700" data-upload-label>ছবি আপলোড
                                            করতে ক্লিক করুন বা টেনে আনুন</p>
                                        <p class="text-xs text-gray-500">JPG, PNG বা WebP — সর্বোচ্চ ৫ MB</p>
                                    </div>

                                    <img class="hidden absolute inset-0 w-full h-full object-contain p-3 bg-white"
                                        alt="Preview" data-upload-preview />

                                    <span
                                        class="hidden absolute inset-0 items-center justify-center bg-black/45 text-white text-sm font-medium opacity-0 group-hover:opacity-100 transition"
                                        data-upload-overlay>ছবি পরিবর্তন করুন</span>

                                    <button type="button"
                                        class="hidden absolute top-3 right-3 items-center gap-1.5 rounded-md bg-white/95 text-gray-800 px-3 py-1.5 text-xs font-semibold shadow-sm ring-1 ring-gray-200 hover:bg-white transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40"
                                        data-upload-retake>
                                        <my:icon name="refresh" />
                                        <span>পুনরায় ছবি তুলুন</span>
                                    </button>

                                    <input id="photo" name="photo" type="file" accept="image/jpeg,image/png,image/webp"
                                        class="sr-only" data-upload-input required />
                                </label>
                            </div>

                            <div class="flex flex-col">
                                <label for="plate" class="mb-1.5 text-[13px] font-semibold text-gray-700">শনাক্তকৃত
                                    প্লেট নম্বর</label>
                                <div class="relative">
                                    <input id="plate" name="plate" type="text" required
                                        value="<c:out value='${formPlate}'/>" placeholder="উদা: Dhaka metro ga 31-9957"
                                        class="w-full rounded-lg border border-gray-200 bg-gray-50 px-3.5 py-3 text-base text-gray-900 placeholder-gray-400 focus:outline-none focus:border-brand focus:bg-white focus:ring-2 focus:ring-brand/15"
                                        data-plate-input />
                                    <span id="plateOcrSpinner"
                                        class="hidden absolute right-3 top-1/2 -translate-y-1/2 text-brand">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18"
                                            viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"
                                            stroke-linecap="round" class="animate-spin">
                                            <path d="M21 12a9 9 0 1 1-6.219-8.56" />
                                        </svg>
                                    </span>
                                </div>
                                <p id="plateOcrStatus" class="mt-1.5 text-xs text-gray-500">ছবি আপলোড করলে সিস্টেম
                                    স্বয়ংক্রিয়ভাবে প্লেট নম্বর পূরণ করার চেষ্টা করবে।</p>
                            </div>

                            <div class="flex items-center justify-end gap-3 pt-2">
                                <a href="<c:url value='/operator/dashboard'/>"
                                    class="inline-flex items-center gap-2 rounded-md border border-gray-200 bg-white text-gray-700 px-5 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                                    বাতিল
                                </a>
                                <button type="submit"
                                    class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-5 py-2.5 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                                    <span>যাচাই করুন</span>
                                    <my:icon name="arrow" />
                                </button>
                            </div>
                        </form>

                    </section>

                    <script src="<c:url value='/js/uploads.js'/>" defer></script>
                    <script>
                        (function () {
                            var photoInput = document.getElementById('photo');
                            var plateInput = document.getElementById('plate');
                            var spinner = document.getElementById('plateOcrSpinner');
                            var status = document.getElementById('plateOcrStatus');
                            var form = plateInput ? plateInput.closest('form') : null;
                            if (!photoInput || !plateInput || !form) return;

                            var ocrUrl = '<c:url value="/operator/transactions/ocr-plate"/>';
                            var csrfInput = form.querySelector('input[name="${not empty _csrf ? _csrf.parameterName : "_csrf"}"]');
                            var defaultStatus = status ? status.textContent : '';

                            function setStatus(text, cls) {
                                if (!status) return;
                                status.textContent = text;
                                status.className = 'mt-1.5 text-xs ' + (cls || 'text-gray-500');
                            }
                            function setBusy(busy) {
                                if (!spinner) return;
                                spinner.classList.toggle('hidden', !busy);
                            }

                            photoInput.addEventListener('change', function () {
                                var file = photoInput.files && photoInput.files[0];
                                if (!file || !file.type || !file.type.startsWith('image/')) return;
                                var data = new FormData();
                                data.append('photo', file);
                                if (csrfInput) data.append(csrfInput.name, csrfInput.value);

                                setBusy(true);
                                setStatus('প্লেট নম্বর পড়া হচ্ছে…', 'text-gray-500');
                                fetch(ocrUrl, { method: 'POST', body: data, credentials: 'same-origin' })
                                    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
                                    .then(function (json) {
                                        setBusy(false);
                                        if (!json.enabled) {
                                            setStatus(defaultStatus, 'text-gray-500');
                                            return;
                                        }
                                        if (json.plate) {
                                            plateInput.value = json.plate;
                                            setStatus('OCR ফলাফল: ' + json.plate + '। প্রয়োজনে সম্পাদনা করুন।', 'text-emerald-600');
                                        } else {
                                            setStatus('স্বয়ংক্রিয়ভাবে প্লেট পড়া যায়নি, হাতে লিখুন।', 'text-amber-600');
                                        }
                                    })
                                    .catch(function () {
                                        setBusy(false);
                                        setStatus('OCR সেবায় সংযোগ করা যায়নি, হাতে প্লেট নম্বর লিখুন।', 'text-amber-600');
                                    });
                            });
                        })();
                    </script>
                </jsp:body>

            </my:panelLayout>