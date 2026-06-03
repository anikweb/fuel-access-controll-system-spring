<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="লেনদেন | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"        icon="users"     label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt"   label="লেনদেন" active="true"/>
        <my:sidebarNavItem href="/admin/vehicles"     icon="truck"     label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/stations"     icon="terminal"  label="স্টেশন"/>
        <my:sidebarNavItem href="/admin/settings"     icon="settings"  label="সেটিংস"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header>
                <h1 class="text-[34px] sm:text-[38px] font-bold text-brand tracking-tight leading-snug">লেনদেন ব্যবস্থাপনা</h1>
                <p class="mt-2 text-sm text-gray-500">সিস্টেমের সকল জ্বালানি লেনদেনের তালিকা এবং অডিট ট্রেইল</p>
            </header>

            <form action="<c:url value='/admin/transactions'/>" method="get"
                  class="bg-white border border-gray-200 rounded-xl p-5 sm:p-6 flex flex-col gap-4">

                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                    <div class="flex flex-col">
                        <label for="q" class="mb-1.5 text-[13px] font-medium text-gray-700">সার্চ (আইডি বা যানবাহন)</label>
                        <div class="flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15">
                            <input id="q" name="q" type="text"
                                   placeholder="উদা: TXN-5042"
                                   value="${filterQ}"
                                   class="flex-1 w-full bg-transparent border-0 px-3.5 py-3 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"/>
                        </div>
                    </div>

                    <div class="flex flex-col">
                        <label for="date" class="mb-1.5 text-[13px] font-medium text-gray-700">তারিখের সীমা</label>
                        <div class="flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15">
                            <input id="date" name="date" type="date"
                                   value="${filterDate}"
                                   class="flex-1 w-full bg-transparent border-0 px-3.5 py-3 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"/>
                        </div>
                    </div>

                    <div class="flex flex-col">
                        <label for="stationId" class="mb-1.5 text-[13px] font-medium text-gray-700">স্টেশন</label>
                        <div class="relative flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15">
                            <select id="stationId" name="stationId"
                                    class="flex-1 w-full appearance-none bg-transparent border-0 px-3.5 pr-10 py-3 text-sm text-gray-900 focus:outline-none">
                                <option value="" ${empty filterStationId ? 'selected' : ''}>সব স্টেশন</option>
                                <c:forEach items="${stations}" var="s">
                                    <option value="${s.id}" ${filterStationId eq s.id ? 'selected' : ''}><c:out value="${s.name}"/></option>
                                </c:forEach>
                            </select>
                            <span class="absolute right-3 pointer-events-none text-gray-400">
                                <my:icon name="chevronDown"/>
                            </span>
                        </div>
                    </div>

                    <div class="flex flex-col">
                        <label for="status" class="mb-1.5 text-[13px] font-medium text-gray-700">অবস্থা</label>
                        <div class="relative flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15">
                            <select id="status" name="status"
                                    class="flex-1 w-full appearance-none bg-transparent border-0 px-3.5 pr-10 py-3 text-sm text-gray-900 focus:outline-none">
                                <option value="" ${empty filterStatus ? 'selected' : ''}>সব অবস্থা</option>
                                <option value="SUCCESS"   ${filterStatus eq 'SUCCESS'   ? 'selected' : ''}>সফল</option>
                                <option value="PENDING"   ${filterStatus eq 'PENDING'   ? 'selected' : ''}>অপেক্ষমান</option>
                                <option value="CANCELLED" ${filterStatus eq 'CANCELLED' ? 'selected' : ''}>বাতিল</option>
                            </select>
                            <span class="absolute right-3 pointer-events-none text-gray-400">
                                <my:icon name="chevronDown"/>
                            </span>
                        </div>
                    </div>
                </div>

                <div>
                    <button type="submit"
                            class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-5 py-2.5 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                        ফিল্টার করুন
                    </button>
                </div>
            </form>

            <my:dataTable
                isEmpty="${empty transactions}"
                emptyMessage="কোনো লেনদেন পাওয়া যায়নি।"
                colspan="6"
                itemLabel="লেনদেন"
                fromIdx="${transactionsFromIdx}"
                toIdx="${transactionsToIdx}"
                total="${transactionsTotal}"
                currentPage="${transactionsPage}"
                hasPrev="${transactionsHasPrev}"
                hasNext="${transactionsHasNext}"
                pageUrl="${transactionsPageUrl}">

                <jsp:attribute name="header">
                    <my:dataTableHeadCell label="লেনদেন আইডি" width="w-32"/>
                    <my:dataTableHeadCell label="তারিখ ও সময়" width="w-44"/>
                    <my:dataTableHeadCell label="যানবাহন"/>
                    <my:dataTableHeadCell label="স্টেশন"/>
                    <my:dataTableHeadCell label="পরিমাণ" width="w-32"/>
                    <my:dataTableHeadCell label="অবস্থা" align="right" width="w-32"/>
                </jsp:attribute>

                <jsp:body>
                    <c:forEach items="${transactions}" var="t">
                        <my:dataTableRow>
                            <my:dataTableBodyCell label="লেনদেন আইডি" tone="brand" bold="true" mono="true" nowrap="true">${t.displayCode}</my:dataTableBodyCell>
                            <my:dataTableBodyCell label="তারিখ ও সময়" tone="muted">${t.createdAtDisplay}</my:dataTableBodyCell>
                            <my:dataTableBodyCell label="যানবাহন">
                                <span class="inline-flex items-center gap-2">
                                    <span class="inline-flex items-center justify-center w-8 h-8 rounded-md bg-brand/5 text-brand shrink-0 [&>svg]:w-4 [&>svg]:h-4">
                                        <my:icon name="truck"/>
                                    </span>
                                    <span class="text-sm font-medium text-gray-900"><c:out value="${t.vehiclePlate}"/></span>
                                </span>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell label="স্টেশন" tone="muted">${empty t.stationName ? '—' : t.stationName}</my:dataTableBodyCell>
                            <my:dataTableBodyCell label="পরিমাণ" bold="true" mono="true">${t.amountDisplay}</my:dataTableBodyCell>
                            <my:dataTableBodyCell label="অবস্থা" align="right">
                                <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold ${t.statusBadgeClass}">
                                    <c:out value="${t.statusLabel}"/>
                                </span>
                            </my:dataTableBodyCell>
                        </my:dataTableRow>
                    </c:forEach>
                </jsp:body>
            </my:dataTable>

        </section>
    </jsp:body>

</my:panelLayout>
