<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="সকল লেনদেন | FACS">

    <jsp:attribute name="sidebar">
        <article class="bg-white border border-gray-200 rounded-2xl p-6 flex flex-col items-center text-center shadow-sm">
            <div class="w-24 h-24 rounded-full overflow-hidden bg-gray-100 ring-2 ring-brand ring-offset-2 ring-offset-white">
                <c:choose>
                    <c:when test="${not empty userSidebar.photoUrl}">
                        <img src="<c:out value='${userSidebar.photoUrl}'/>" alt="" class="w-full h-full object-cover"/>
                    </c:when>
                    <c:otherwise>
                        <img src="<c:url value='/img/avatar-placeholder.svg'/>" alt="" class="w-full h-full object-cover"/>
                    </c:otherwise>
                </c:choose>
            </div>
            <h2 class="mt-4 text-[18px] font-bold text-gray-900 leading-tight"><c:out value="${userSidebar.name}"/></h2>
            <p class="mt-1.5 text-sm text-gray-500"><c:out value="${userSidebar.roleLabel}"/></p>
        </article>

        <my:sidebarNavItem href="/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/transactions" icon="receipt"   label="সকল লেনদেন" active="true"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header>
                <h1 class="text-[26px] sm:text-[28px] font-bold text-brand tracking-tight leading-snug">সকল লেনদেন</h1>
                <p class="mt-2 text-sm text-gray-500">আপনার যানবাহনের জন্য সম্পন্ন সকল রিফুয়েলিং লেনদেন।</p>
            </header>

            <form action="<c:url value='/transactions'/>" method="get"
                  class="bg-white border border-gray-200 rounded-xl p-5 sm:p-6 flex flex-col gap-4">

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">

                    <div class="flex flex-col">
                        <label for="q" class="mb-1.5 text-[13px] font-medium text-gray-700">সার্চ (কোড বা প্লেট)</label>
                        <div class="flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15">
                            <input id="q" name="q" type="text"
                                   placeholder="উদা: FACS-001234"
                                   value="<c:out value='${filterQ}'/>"
                                   class="flex-1 w-full bg-transparent border-0 px-3.5 py-3 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"/>
                        </div>
                    </div>

                    <div class="flex flex-col">
                        <label for="date" class="mb-1.5 text-[13px] font-medium text-gray-700">তারিখ</label>
                        <div class="flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15">
                            <input id="date" name="date" type="date"
                                   value="${filterDate}"
                                   class="flex-1 w-full bg-transparent border-0 px-3.5 py-3 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"/>
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

                <div class="flex items-center gap-3">
                    <button type="submit"
                            class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-5 py-2.5 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                        ফিল্টার করুন
                    </button>
                    <c:if test="${not empty filterQ or not empty filterDate or not empty filterStatus}">
                        <a href="<c:url value='/transactions'/>"
                           class="inline-flex items-center gap-2 rounded-md border border-gray-200 bg-white text-gray-700 px-5 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                            রিসেট
                        </a>
                    </c:if>
                </div>
            </form>

            <my:dataTable
                isEmpty="${empty transactions}"
                emptyMessage="কোনো লেনদেন পাওয়া যায়নি।"
                colspan="5"
                itemLabel="লেনদেন"
                fromIdx="${transactionsFromIdx}"
                toIdx="${transactionsToIdx}"
                total="${transactionsTotal}"
                currentPage="${transactionsPage}"
                hasPrev="${transactionsHasPrev}"
                hasNext="${transactionsHasNext}"
                pageUrl="${transactionsPageUrl}">

                <jsp:attribute name="header">
                    <my:dataTableHeadCell label="লেনদেন আইডি" width="w-40"/>
                    <my:dataTableHeadCell label="তারিখ ও সময়" width="w-56"/>
                    <my:dataTableHeadCell label="যানবাহন"/>
                    <my:dataTableHeadCell label="স্টেশন"/>
                    <my:dataTableHeadCell label="পরিমাণ" align="right" width="w-32"/>
                </jsp:attribute>

                <jsp:body>
                    <c:forEach items="${transactions}" var="t">
                        <my:dataTableRow>
                            <my:dataTableBodyCell tone="brand" bold="true" mono="true" nowrap="true">${t.displayCode}</my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="muted" nowrap="true">${t.createdAtDisplay}</my:dataTableBodyCell>
                            <my:dataTableBodyCell>
                                <span class="inline-flex items-center gap-2">
                                    <span class="inline-flex items-center justify-center w-8 h-8 rounded-md bg-brand/5 text-brand shrink-0 [&>svg]:w-4 [&>svg]:h-4">
                                        <my:icon name="truck"/>
                                    </span>
                                    <span class="text-sm font-medium text-gray-900"><c:out value="${t.vehiclePlate}"/></span>
                                </span>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell tone="muted"><c:out value="${t.stationName}"/></my:dataTableBodyCell>
                            <my:dataTableBodyCell align="right" bold="true" mono="true" nowrap="true">${t.amountDisplay}</my:dataTableBodyCell>
                        </my:dataTableRow>
                    </c:forEach>
                </jsp:body>
            </my:dataTable>

        </section>
    </jsp:body>

</my:panelLayout>
