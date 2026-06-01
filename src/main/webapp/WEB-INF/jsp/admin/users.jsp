<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="ব্যবহারকারী | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"        icon="users"     label="ব্যবহারকারী" active="true"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt"   label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles"     icon="truck"     label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/stations"     icon="terminal"  label="স্টেশন"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header class="flex items-center justify-between gap-4">
                <div>
                    <h1 class="text-[34px] sm:text-[38px] font-bold text-brand tracking-tight leading-snug">ব্যবহারকারী ব্যবস্থাপনা</h1>
                    <p class="mt-2 text-sm text-gray-500">সিস্টেমের সকল ব্যবহারকারীর তালিকা এবং অ্যাক্সেস কন্ট্রোল</p>
                </div>
                <a href="<c:url value='/admin/users/new'/>"
                   class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-6 py-3 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40 shadow-[0_2px_8px_rgba(13,58,46,0.18)]">
                    <my:icon name="users"/>
                    <span>+ নতুন ব্যবহারকারী</span>
                </a>
            </header>

            <c:if test="${not empty panelUserFlash}">
                <div role="status"
                     class="rounded-md px-4 py-3 text-sm font-medium
                            ${panelUserFlashVariant == 'error'
                              ? 'bg-red-50 text-red-700 border border-red-200'
                              : 'bg-emerald-50 text-emerald-700 border border-emerald-200'}">
                    <c:out value="${panelUserFlash}"/>
                </div>
            </c:if>

            <my:dataTable
                isEmpty="${empty panelUsers}"
                emptyMessage="এখনো কোনো ব্যবহারকারী যুক্ত করা হয়নি।"
                colspan="5"
                itemLabel="রেকর্ড"
                fromIdx="${panelUsersFromIdx}"
                toIdx="${panelUsersToIdx}"
                total="${panelUsersTotal}"
                currentPage="${panelUsersPage}"
                hasPrev="${panelUsersHasPrev}"
                hasNext="${panelUsersHasNext}"
                pageUrl="/admin/users">

                <jsp:attribute name="header">
                    <my:dataTableHeadCell label="নাম ও আইডি"/>
                    <my:dataTableHeadCell label="মোবাইল"/>
                    <my:dataTableHeadCell label="ভূমিকা" width="w-44"/>
                    <my:dataTableHeadCell label="নিবন্ধনের তারিখ" width="w-44"/>
                    <my:dataTableHeadCell label="অ্যাকশন" align="right" width="w-32"/>
                </jsp:attribute>

                <jsp:body>
                    <c:forEach items="${panelUsers}" var="u">
                        <my:dataTableRow>
                            <my:dataTableBodyCell>
                                <div class="flex items-center gap-4 -my-1">
                                    <c:choose>
                                        <c:when test="${not empty u.photoUrl}">
                                            <span class="inline-flex items-center justify-center w-12 h-12 rounded-md overflow-hidden bg-gray-100 shrink-0">
                                                <img src="${u.photoUrl}" alt="" class="w-full h-full object-cover"/>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="inline-flex items-center justify-center w-12 h-12 rounded-md text-base font-semibold shrink-0 ${u.avatarClass}">
                                                <c:out value="${u.initial}"/>
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="flex flex-col min-w-0">
                                        <span class="text-sm font-semibold text-gray-900"><c:out value="${u.name}"/></span>
                                        <span class="text-xs text-gray-500 mt-0.5"><c:out value="${u.displayId}"/></span>
                                    </span>
                                </div>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="muted">${u.mobile}</my:dataTableBodyCell>
                            <my:dataTableBodyCell>
                                <span class="inline-flex items-center px-3 py-1 rounded-md text-xs font-medium ${u.roleBadgeClass}">
                                    <c:out value="${u.roleLabel}"/>
                                </span>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="muted">${u.registeredOn}</my:dataTableBodyCell>
                            <my:dataTableBodyCell>
                                <div class="flex items-center justify-end gap-3">
                                    <a href="<c:url value='/admin/users/${u.id}/edit'/>"
                                       class="inline-flex items-center justify-center w-10 h-10 rounded-md text-gray-500 hover:bg-gray-100 hover:text-brand transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30 [&>svg]:h-5 [&>svg]:w-5"
                                       aria-label="সম্পাদনা">
                                        <my:icon name="pencil"/>
                                    </a>
                                    <button type="button"
                                            class="inline-flex items-center justify-center w-10 h-10 rounded-md text-gray-500 hover:bg-gray-100 hover:text-brand-red transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-red/40 [&>svg]:h-5 [&>svg]:w-5"
                                            aria-label="মুছুন"
                                            data-delete-user
                                            data-action="<c:url value='/admin/users/${u.id}/delete'/>"
                                            data-name="<c:out value='${u.name}'/>"
                                            data-id="<c:out value='${u.displayId}'/>">
                                        <my:icon name="trash"/>
                                    </button>
                                </div>
                            </my:dataTableBodyCell>
                        </my:dataTableRow>
                    </c:forEach>
                </jsp:body>
            </my:dataTable>

        </section>

        <div id="userDeleteModal"
             class="hidden fixed inset-0 z-50 items-center justify-center px-4"
             role="dialog"
             aria-modal="true"
             aria-labelledby="userDeleteTitle"
             aria-describedby="userDeleteDesc">
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
                        <h2 id="userDeleteTitle" class="text-lg font-semibold text-brand">
                            ব্যবহারকারী মুছে ফেলবেন?
                        </h2>
                        <p id="userDeleteDesc" class="mt-2 text-sm text-gray-600 leading-relaxed">
                            <span class="block">
                                <span class="font-medium text-gray-800" id="userDeleteName"></span>
                                <span class="text-gray-400">·</span>
                                <span class="font-mono text-xs text-gray-500" id="userDeleteId"></span>
                            </span>
                            <span class="mt-2 block">এই কাজটি ফেরানো যাবে না।</span>
                        </p>
                    </div>
                </div>
                <form id="userDeleteForm" method="post" action=""
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
                var modal = document.getElementById('userDeleteModal');
                if (!modal) return;
                var form = document.getElementById('userDeleteForm');
                var nameEl = document.getElementById('userDeleteName');
                var idEl = document.getElementById('userDeleteId');
                var lastTrigger = null;

                function openModal(trigger) {
                    form.action = trigger.getAttribute('data-action') || '';
                    nameEl.textContent = trigger.getAttribute('data-name') || '';
                    idEl.textContent = trigger.getAttribute('data-id') || '';
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

                document.querySelectorAll('[data-delete-user]').forEach(function (btn) {
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
