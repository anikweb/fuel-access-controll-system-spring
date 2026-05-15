<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="ড্যাশবোর্ড | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard" icon="dashboard" label="ড্যাশবোর্ড" active="true"/>
        <my:sidebarNavItem href="/admin/users" icon="users" label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt" label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles" icon="truck" label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/terminals" icon="terminal" label="টার্মিনাল"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/admin/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 max-w-7xl">

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                <my:statCard label="মোট সক্রিয় ব্যবহারকারী" value="${activeUsers}" icon="users"/>
                <my:statCard label="আজকের লেনদেন"          value="${todayTransactions}" icon="cash"/>
                <my:statCard label="নিবন্ধিত যানবাহন"        value="${registeredVehicles}" icon="truck"/>
            </div>

            <my:panelCard title="সাম্প্রতিক লেনদেন" actionHref="/admin/transactions" actionLabel="সবগুলো দেখুন">
                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead class="bg-gray-50 text-gray-500">
                        <tr class="text-left text-[12px] font-semibold tracking-wide">
                            <th class="px-6 py-3 font-semibold">লেনদেন আইডি</th>
                            <th class="px-6 py-3 font-semibold">তারিখ ও সময়</th>
                            <th class="px-6 py-3 font-semibold">যানবাহন</th>
                            <th class="px-6 py-3 font-semibold">স্টেশন</th>
                            <th class="px-6 py-3 font-semibold text-right">পরিমাণ</th>
                            <th class="px-6 py-3 font-semibold text-center">অবস্থা</th>
                        </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                        <c:choose>
                            <c:when test="${empty recentTransactions}">
                                <tr>
                                    <td colspan="6" class="px-6 py-10 text-center text-sm text-gray-500">
                                        এখনো কোনো লেনদেন নেই।
                                    </td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${recentTransactions}" var="t">
                                    <tr class="hover:bg-gray-50/60 transition">
                                        <td class="px-6 py-4 text-brand font-semibold whitespace-nowrap">#${t.id}</td>
                                        <td class="px-6 py-4 text-gray-700">${t.when}</td>
                                        <td class="px-6 py-4">
                                            <span class="inline-flex items-center gap-2 text-gray-800">
                                                <span class="text-gray-400"><my:icon name="truck"/></span>
                                                <span>${t.vehicle}</span>
                                            </span>
                                        </td>
                                        <td class="px-6 py-4 text-gray-700">${t.station}</td>
                                        <td class="px-6 py-4 text-right text-gray-900 font-medium tabular-nums whitespace-nowrap">${t.qty}</td>
                                        <td class="px-6 py-4 text-center">
                                            <my:statusBadge label="${t.statusLabel}" variant="${t.statusVariant}"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </my:panelCard>

        </section>
    </jsp:body>

</my:panelLayout>
