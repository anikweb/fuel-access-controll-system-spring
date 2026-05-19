<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="ড্যাশবোর্ড | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard" icon="dashboard" label="ড্যাশবোর্ড" active="true"/>
        <my:sidebarNavItem href="/admin/users" icon="users" label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt" label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles" icon="truck" label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/stations" icon="terminal" label="স্টেশন"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/admin/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                <my:statCard label="মোট সক্রিয় ব্যবহারকারী" value="${activeUsers}" icon="users"/>
                <my:statCard label="আজকের লেনদেন"          value="${todayTransactions}" icon="cash"/>
                <my:statCard label="নিবন্ধিত যানবাহন"        value="${registeredVehicles}" icon="truck"/>
            </div>

            <my:dataTable
                title="সাম্প্রতিক লেনদেন"
                actionHref="/admin/transactions"
                actionLabel="সবগুলো দেখুন"
                isEmpty="${empty recentTransactions}"
                emptyMessage="এখনো কোনো লেনদেন নেই।"
                colspan="6"
                paginated="false">

                <jsp:attribute name="header">
                    <my:dataTableHeadCell label="লেনদেন আইডি"/>
                    <my:dataTableHeadCell label="তারিখ ও সময়"/>
                    <my:dataTableHeadCell label="যানবাহন"/>
                    <my:dataTableHeadCell label="স্টেশন"/>
                    <my:dataTableHeadCell label="পরিমাণ" align="right"/>
                    <my:dataTableHeadCell label="অবস্থা" align="center"/>
                </jsp:attribute>

                <jsp:body>
                    <c:forEach items="${recentTransactions}" var="t">
                        <my:dataTableRow>
                            <my:dataTableBodyCell tone="brand" bold="true" nowrap="true">#${t.id}</my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="muted">${t.when}</my:dataTableBodyCell>
                            <my:dataTableBodyCell>
                                <span class="inline-flex items-center gap-2 text-gray-800">
                                    <span class="text-gray-400"><my:icon name="truck"/></span>
                                    <span>${t.vehicle}</span>
                                </span>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="muted">${t.station}</my:dataTableBodyCell>
                            <my:dataTableBodyCell align="right" bold="true" mono="true" nowrap="true">${t.qty}</my:dataTableBodyCell>
                            <my:dataTableBodyCell align="center">
                                <my:statusBadge label="${t.statusLabel}" variant="${t.statusVariant}"/>
                            </my:dataTableBodyCell>
                        </my:dataTableRow>
                    </c:forEach>
                </jsp:body>
            </my:dataTable>

        </section>
    </jsp:body>

</my:panelLayout>
