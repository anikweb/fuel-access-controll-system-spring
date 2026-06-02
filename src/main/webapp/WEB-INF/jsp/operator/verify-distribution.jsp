<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="যানবাহন যাচাইকরণ | FACS">

    <jsp:attribute name="sidebar">
        <article class="bg-white border border-gray-200 rounded-2xl p-6 flex flex-col items-center text-center shadow-sm">
            <div class="w-24 h-24 rounded-full overflow-hidden bg-gray-100 ring-2 ring-brand ring-offset-2 ring-offset-white">
                <c:choose>
                    <c:when test="${not empty operator.photoUrl}">
                        <img src="<c:out value='${operator.photoUrl}'/>" alt="" class="w-full h-full object-cover"/>
                    </c:when>
                    <c:otherwise>
                        <img src="<c:url value='/img/avatar-placeholder.svg'/>" alt="" class="w-full h-full object-cover"/>
                    </c:otherwise>
                </c:choose>
            </div>
            <h2 class="mt-4 text-[18px] font-bold text-gray-900 leading-tight"><c:out value="${operator.name}"/></h2>
            <p class="mt-1.5 text-sm text-gray-500">অপারেটর আইডি: ${operator.displayId}</p>
            <a href="<c:url value='/operator/transactions/new'/>"
               class="mt-5 w-full inline-flex items-center justify-center gap-2 rounded-lg bg-brand text-white px-4 py-3 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                <my:icon name="plus"/>
                <span>নতুন বিতরণ</span>
            </a>
        </article>

        <c:if test="${not empty station}">
            <article class="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm">
                <p class="text-[13px] font-semibold text-gray-500">স্টেশন</p>
                <p class="mt-3 text-[15px] font-semibold text-gray-900 leading-snug"><c:out value="${station.name}"/></p>
                <p class="mt-1 text-sm text-gray-500 leading-snug"><c:out value="${station.location}"/></p>
            </article>
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <form action="<c:url value='/operator/transactions/select-fuel'/>" method="post" enctype="multipart/form-data"
              class="w-full flex flex-col gap-6">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>
            <input type="hidden" name="vehicleId" value="${view.vehicleId}"/>
            <input id="retake-photo" name="photo" type="file" accept="image/jpeg,image/png,image/webp" class="sr-only"/>

            <header class="flex items-start justify-between gap-4 flex-wrap">
                <div>
                    <h1 class="text-[26px] sm:text-[28px] font-bold text-brand tracking-tight leading-snug">যানবাহন যাচাইকরণ</h1>
                    <p class="mt-2 text-sm text-gray-500">সিস্টেম স্বয়ংক্রিয়ভাবে লাইসেন্স প্লেট এবং নিবন্ধনের ডেটা নিশ্চিত করেছে।</p>
                </div>
                <span class="inline-flex items-center gap-2 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 px-4 py-2.5 text-sm font-semibold shadow-sm">
                    <my:icon name="checkCircle"/>
                    <span>অনুমোদিত</span>
                </span>
            </header>

            <div class="grid grid-cols-1 lg:grid-cols-[minmax(260px,360px)_minmax(0,1fr)] gap-6 items-start">

                <article class="bg-white border border-gray-200 rounded-xl p-5 shadow-sm">
                    <p class="text-[13px] font-semibold text-gray-500">ক্যাপচার করা ছবি</p>

                    <div class="mt-4 rounded-lg overflow-hidden bg-gray-100 aspect-[3/1] flex items-center justify-center">
                        <c:choose>
                            <c:when test="${not empty view.capturedPhotoUrl}">
                                <img id="capturedPhotoImg" src="<c:out value='${view.capturedPhotoUrl}'/>" alt="" class="w-full h-full object-contain"/>
                            </c:when>
                            <c:otherwise>
                                <img id="capturedPhotoImg" alt="" class="w-full h-full object-contain hidden"/>
                                <span id="capturedPhotoPlaceholder" class="text-gray-400 text-xs">কোনো ছবি আপলোড করা হয়নি</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="mt-4 rounded-lg border-2 border-dashed border-brand/30 bg-brand/5 px-4 py-4 text-center">
                        <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">শনাক্তকৃত নম্বর</p>
                        <p class="mt-1.5 text-[20px] font-bold text-brand tracking-wide"><c:out value="${view.detectedPlate}"/></p>
                    </div>

                    <button type="button" id="retake-trigger"
                            class="mt-3 w-full inline-flex items-center justify-center gap-2 rounded-lg border border-gray-200 bg-white text-gray-700 px-4 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                        <my:icon name="refresh"/>
                        <span>পুনরায় ছবি তুলুন</span>
                    </button>
                </article>

                <article class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
                    <header class="bg-brand text-white px-6 py-4 flex items-center gap-2">
                        <my:icon name="shield"/>
                        <h2 class="text-[16px] font-bold">মালিক এবং যানবাহনের বিবরণ</h2>
                    </header>

                    <div class="px-6 py-5 grid grid-cols-1 sm:grid-cols-2 gap-x-8 gap-y-5">

                        <div>
                            <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">মালিকের তথ্য</p>

                            <div class="mt-4 flex items-start gap-3">
                                <span class="inline-flex items-center justify-center w-9 h-9 rounded-full bg-gray-100 text-gray-500 shrink-0">
                                    <my:icon name="user"/>
                                </span>
                                <div class="min-w-0">
                                    <p class="text-[15px] font-semibold text-gray-900 leading-tight"><c:out value="${view.owner.name}"/></p>
                                    <p class="mt-0.5 text-xs text-gray-500">ড্রাইভিং লাইসেন্স: <c:out value="${view.owner.licenseMasked}"/></p>
                                </div>
                            </div>

                            <div class="mt-5 flex items-baseline justify-between gap-3">
                                <p class="text-sm text-gray-500">মোবাইল:</p>
                                <p class="text-sm font-semibold text-gray-900 text-right"><c:out value="${view.owner.mobileMasked}"/></p>
                            </div>
                        </div>

                        <div>
                            <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">যানবাহনের বিবরণ</p>

                            <div class="mt-4 flex items-start gap-3">
                                <span class="inline-flex items-center justify-center w-9 h-9 rounded-md bg-gray-100 text-gray-500 shrink-0">
                                    <my:icon name="truck"/>
                                </span>
                                <div class="min-w-0">
                                    <p class="text-xs text-gray-500">প্লেট নম্বর</p>
                                    <p class="text-[15px] font-semibold text-gray-900 leading-tight mt-0.5"><c:out value="${view.detectedPlate}"/></p>
                                </div>
                            </div>

                            <div class="mt-4 flex items-start gap-3">
                                <span class="inline-flex items-center justify-center w-9 h-9 rounded-md bg-gray-100 text-gray-500 shrink-0">
                                    <my:icon name="fuelPump"/>
                                </span>
                                <div class="min-w-0">
                                    <p class="text-xs text-gray-500">জ্বালানির ধরন</p>
                                    <p class="text-[15px] font-semibold text-gray-900 leading-tight mt-0.5"><c:out value="${view.fuelTypeLabel}"/></p>
                                </div>
                            </div>

                            <div class="mt-4 flex items-start gap-3">
                                <span class="inline-flex items-center justify-center w-9 h-9 rounded-md bg-gray-100 text-gray-500 shrink-0">
                                    <my:icon name="calendar"/>
                                </span>
                                <div class="min-w-0">
                                    <p class="text-xs text-gray-500">সর্বশেষ ফুয়েল নিয়েছেন</p>
                                    <p class="text-[15px] font-semibold text-gray-900 leading-tight mt-0.5"><c:out value="${view.lastFueledDisplay}"/></p>
                                </div>
                            </div>
                        </div>

                    </div>

                    <footer class="px-6 py-5 border-t border-gray-100 bg-gray-50 flex items-center justify-end gap-3 flex-wrap">
                        <a href="<c:url value='/operator/dashboard'/>"
                           class="inline-flex items-center gap-2 rounded-md border border-gray-200 bg-white text-gray-700 px-5 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                            <my:icon name="x"/>
                            <span>বাতিল</span>
                        </a>
                        <button type="submit"
                                class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-5 py-2.5 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                            <my:icon name="fuelPump"/>
                            <span>জ্বালানি প্রদান করুন</span>
                        </button>
                    </footer>
                </article>

            </div>
        </form>

        <script src="<c:url value='/js/uploads.js'/>" defer></script>
        <script>
            (function () {
                var trigger = document.getElementById('retake-trigger');
                var input = document.getElementById('retake-photo');
                var img = document.getElementById('capturedPhotoImg');
                var placeholder = document.getElementById('capturedPhotoPlaceholder');
                if (!trigger || !input || !img) return;
                trigger.addEventListener('click', function () {
                    if (window.openImagePicker) window.openImagePicker(input);
                    else input.click();
                });
                input.addEventListener('change', function () {
                    var file = input.files && input.files[0];
                    if (!file) return;
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        img.src = e.target.result;
                        img.classList.remove('hidden');
                        if (placeholder) placeholder.classList.add('hidden');
                    };
                    reader.readAsDataURL(file);
                });
            })();
        </script>
    </jsp:body>

</my:panelLayout>
