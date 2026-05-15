<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="স্টেশন | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard" icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"     icon="users"     label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt" label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles"  icon="truck"     label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/stations"  icon="terminal"  label="স্টেশন" active="true"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/admin/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 max-w-7xl">

            <header class="flex items-center justify-between gap-4">
                <div>
                    <h1 class="text-[34px] sm:text-[38px] font-bold text-brand tracking-tight leading-snug">স্টেশন ব্যবস্থাপনা</h1>
                    <p class="mt-2 text-sm text-gray-500">সিস্টেমের সকল সক্রিয় ফুয়েল স্টেশন তালিকা</p>
                </div>
                <a href="<c:url value='/admin/stations/new'/>"
                   class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-6 py-3 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40 shadow-[0_2px_8px_rgba(13,58,46,0.18)]">
                    <my:icon name="plus"/>
                    <span>নতুন স্টেশন যোগ করুন</span>
                </a>
            </header>

            <my:dataTable
                isEmpty="${empty stations}"
                emptyMessage="এখনো কোনো স্টেশন যুক্ত করা হয়নি।"
                colspan="4"
                itemLabel="স্টেশন"
                fromIdx="${stationsFromIdx}"
                toIdx="${stationsToIdx}"
                total="${stationsTotal}"
                currentPage="${stationsPage}"
                hasPrev="${stationsHasPrev}"
                hasNext="${stationsHasNext}"
                pageUrl="/admin/stations">

                <jsp:attribute name="header">
                    <my:dataTableHeadCell label="আইডি" align="center" width="w-32"/>
                    <my:dataTableHeadCell label="স্টেশনের নাম"/>
                    <my:dataTableHeadCell label="অবস্থান"/>
                    <my:dataTableHeadCell label="অ্যাকশন" align="right" width="w-32"/>
                </jsp:attribute>

                <jsp:body>
                    <c:forEach items="${stations}" var="s">
                        <my:dataTableRow>
                            <my:dataTableBodyCell align="center" tone="brand" bold="true" mono="true" nowrap="true">${s.code}</my:dataTableBodyCell>
                            <my:dataTableBodyCell>${s.name}</my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="muted">${s.location}</my:dataTableBodyCell>
                            <my:dataTableBodyCell>
                                <div class="flex items-center justify-end gap-3">
                                    <a href="<c:url value='/admin/stations/${s.id}/edit'/>"
                                       class="inline-flex items-center justify-center w-10 h-10 rounded-md text-gray-500 hover:bg-gray-100 hover:text-brand transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30 [&>svg]:h-5 [&>svg]:w-5"
                                       aria-label="সম্পাদনা">
                                        <my:icon name="pencil"/>
                                    </a>
                                    <a href="<c:url value='/admin/stations/${s.id}/delete'/>"
                                       class="inline-flex items-center justify-center w-10 h-10 rounded-md text-gray-500 hover:bg-gray-100 hover:text-brand-red transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-red/40 [&>svg]:h-5 [&>svg]:w-5"
                                       aria-label="মুছুন">
                                        <my:icon name="trash"/>
                                    </a>
                                </div>
                            </my:dataTableBodyCell>
                        </my:dataTableRow>
                    </c:forEach>
                </jsp:body>
            </my:dataTable>

        </section>
    </jsp:body>

</my:panelLayout>
