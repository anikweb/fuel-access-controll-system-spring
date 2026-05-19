<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="যানবাহন | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"        icon="users"     label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt"   label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles"     icon="truck"     label="যানবাহন" active="true"/>
        <my:sidebarNavItem href="/admin/stations"     icon="terminal"  label="স্টেশন"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/admin/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header class="flex items-center justify-between gap-4">
                <div>
                    <h1 class="text-[34px] sm:text-[38px] font-bold text-brand tracking-tight leading-snug">যানবাহন ব্যবস্থাপনা</h1>
                    <p class="mt-2 text-sm text-gray-500">নিরাপদ যানবাহন ডাটাবেস এবং অ্যাক্সেস কন্ট্রোল</p>
                </div>
                <a href="<c:url value='/admin/vehicles/new'/>"
                   class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-6 py-3 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40 shadow-[0_2px_8px_rgba(13,58,46,0.18)]">
                    <my:icon name="plus"/>
                    <span>নতুন যানবাহন</span>
                </a>
            </header>

            <c:if test="${not empty vehicleFlash}">
                <div role="status"
                     class="rounded-md px-4 py-3 text-sm font-medium
                            ${vehicleFlashVariant == 'error'
                              ? 'bg-red-50 text-red-700 border border-red-200'
                              : 'bg-emerald-50 text-emerald-700 border border-emerald-200'}">
                    <c:out value="${vehicleFlash}"/>
                </div>
            </c:if>

            <my:dataTable
                isEmpty="${empty vehicles}"
                emptyMessage="এখনো কোনো যানবাহন নিবন্ধিত নেই।"
                colspan="4"
                itemLabel="যানবাহন"
                fromIdx="${vehiclesFromIdx}"
                toIdx="${vehiclesToIdx}"
                total="${vehiclesTotal}"
                currentPage="${vehiclesPage}"
                hasPrev="${vehiclesHasPrev}"
                hasNext="${vehiclesHasNext}"
                pageUrl="/admin/vehicles">

                <jsp:attribute name="header">
                    <my:dataTableHeadCell label="যানবাহনের তথ্য"/>
                    <my:dataTableHeadCell label="মালিকের নাম"/>
                    <my:dataTableHeadCell label="ধরন" width="w-32"/>
                    <my:dataTableHeadCell label="অ্যাকশন" align="right" width="w-32"/>
                </jsp:attribute>

                <jsp:body>
                    <c:forEach items="${vehicles}" var="v">
                        <my:dataTableRow>
                            <my:dataTableBodyCell>
                                <a href="<c:url value='/admin/vehicles/${v.id}'/>"
                                   class="group flex items-center gap-4 -my-1">
                                    <span class="inline-flex items-center justify-center w-12 h-12 rounded-lg bg-brand/5 text-brand shrink-0 [&>svg]:w-6 [&>svg]:h-6">
                                        <my:icon name="${v.typeIcon}"/>
                                    </span>
                                    <span class="flex flex-col min-w-0">
                                        <span class="text-sm font-semibold text-gray-900 group-hover:text-brand transition"><c:out value="${v.plateNumber}"/></span>
                                        <span class="text-xs text-gray-500 mt-0.5">
                                            <c:out value="${v.typeLabel}"/><c:if test="${not empty v.brand}"> • <c:out value="${v.brand}"/></c:if><c:if test="${not empty v.model}"> <c:out value="${v.model}"/></c:if>
                                        </span>
                                    </span>
                                </a>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell>${empty v.ownerName ? '—' : v.ownerName}</my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="brand" bold="true">${v.typeLabel}</my:dataTableBodyCell>
                            <my:dataTableBodyCell>
                                <div class="flex items-center justify-end gap-3">
                                    <button type="button"
                                            class="inline-flex items-center justify-center w-10 h-10 rounded-md text-gray-500 hover:bg-gray-100 hover:text-brand-red transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-red/40 [&>svg]:h-5 [&>svg]:w-5"
                                            aria-label="মুছুন"
                                            data-delete-vehicle
                                            data-action="<c:url value='/admin/vehicles/${v.id}/delete'/>"
                                            data-name="<c:out value='${v.plateNumber}'/>">
                                        <my:icon name="trash"/>
                                    </button>
                                </div>
                            </my:dataTableBodyCell>
                        </my:dataTableRow>
                    </c:forEach>
                </jsp:body>
            </my:dataTable>

        </section>

        <div id="vehicleDeleteModal"
             class="hidden fixed inset-0 z-50 items-center justify-center px-4"
             role="dialog"
             aria-modal="true"
             aria-labelledby="vehicleDeleteTitle"
             aria-describedby="vehicleDeleteDesc">
            <div class="absolute inset-0 bg-gray-900/50 backdrop-blur-sm" data-modal-dismiss></div>
            <div class="relative w-full max-w-md rounded-xl bg-white shadow-2xl ring-1 ring-black/5 overflow-hidden">
                <div class="px-6 pt-6 pb-5 flex gap-4">
                    <span class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-red-50 text-brand-red"
                          aria-hidden="true">
                        <svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 24 24"
                             fill="none" stroke="currentColor" stroke-width="2"
                             stroke-linecap="round" stroke-linejoin="round">
                            <path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                            <line x1="12" y1="9" x2="12" y2="13"/>
                            <line x1="12" y1="17" x2="12.01" y2="17"/>
                        </svg>
                    </span>
                    <div class="flex-1">
                        <h2 id="vehicleDeleteTitle" class="text-lg font-semibold text-brand">
                            যানবাহন মুছে ফেলবেন?
                        </h2>
                        <p id="vehicleDeleteDesc" class="mt-2 text-sm text-gray-600 leading-relaxed">
                            <span class="font-medium text-gray-800" id="vehicleDeleteName"></span>
                            <span class="mt-2 block">এই কাজটি ফেরানো যাবে না।</span>
                        </p>
                    </div>
                </div>
                <form id="vehicleDeleteForm" method="post" action=""
                      class="bg-gray-50 px-6 py-4 flex items-center justify-end gap-3 border-t border-gray-100">
                    <c:if test="${not empty _csrf}">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    </c:if>
                    <button type="button" data-modal-dismiss
                            class="inline-flex items-center justify-center rounded-md bg-white px-4 py-2 text-sm font-semibold text-gray-700 ring-1 ring-gray-200 hover:bg-gray-50 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30">
                        বাতিল
                    </button>
                    <button type="submit"
                            class="inline-flex items-center justify-center rounded-md bg-brand-red px-4 py-2 text-sm font-semibold text-white shadow-[0_2px_8px_rgba(170,40,40,0.25)] hover:bg-brand-red-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-red/40">
                        মুছে ফেলুন
                    </button>
                </form>
            </div>
        </div>

        <script>
            (function () {
                var modal = document.getElementById('vehicleDeleteModal');
                if (!modal) return;
                var form = document.getElementById('vehicleDeleteForm');
                var nameEl = document.getElementById('vehicleDeleteName');
                var lastTrigger = null;

                function openModal(trigger) {
                    form.action = trigger.getAttribute('data-action') || '';
                    nameEl.textContent = trigger.getAttribute('data-name') || '';
                    lastTrigger = trigger;
                    modal.classList.remove('hidden');
                    modal.classList.add('flex');
                    document.body.style.overflow = 'hidden';
                    var cancelBtn = modal.querySelector('[data-modal-dismiss]:not(.absolute)');
                    if (cancelBtn) cancelBtn.focus();
                }

                function closeModal() {
                    modal.classList.add('hidden');
                    modal.classList.remove('flex');
                    document.body.style.overflow = '';
                    if (lastTrigger) {
                        lastTrigger.focus();
                        lastTrigger = null;
                    }
                }

                document.querySelectorAll('[data-delete-vehicle]').forEach(function (btn) {
                    btn.addEventListener('click', function () { openModal(btn); });
                });

                modal.querySelectorAll('[data-modal-dismiss]').forEach(function (el) {
                    el.addEventListener('click', closeModal);
                });

                document.addEventListener('keydown', function (e) {
                    if (e.key === 'Escape' && !modal.classList.contains('hidden')) {
                        closeModal();
                    }
                });
            })();
        </script>
    </jsp:body>

</my:panelLayout>
