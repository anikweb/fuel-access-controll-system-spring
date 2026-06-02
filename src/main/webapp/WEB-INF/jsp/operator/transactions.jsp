<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="সকল লেনদেন | FACS">

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
        <my:sidebarNavItem href="/operator/dashboard" icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header>
                <h1 class="text-[26px] sm:text-[28px] font-bold text-brand tracking-tight leading-snug">সকল লেনদেন</h1>
                <p class="mt-2 text-sm text-gray-500">আপনার দ্বারা সম্পন্ন সকল জ্বালানি বিতরণের তালিকা।</p>
            </header>

            <form action="<c:url value='/operator/transactions'/>" method="get"
                  class="bg-white border border-gray-200 rounded-xl p-5 sm:p-6 flex flex-col gap-4">

                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">

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
                        <label for="fuelType" class="mb-1.5 text-[13px] font-medium text-gray-700">জ্বালানির ধরন</label>
                        <div class="relative flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15">
                            <select id="fuelType" name="fuelType"
                                    class="flex-1 w-full appearance-none bg-transparent border-0 px-3.5 pr-10 py-3 text-sm text-gray-900 focus:outline-none">
                                <option value="" ${empty filterFuelType ? 'selected' : ''}>সব ধরন</option>
                                <option value="petrol" ${filterFuelType eq 'petrol' ? 'selected' : ''}>পেট্রোল</option>
                                <option value="octane" ${filterFuelType eq 'octane' ? 'selected' : ''}>অকটেন</option>
                                <option value="diesel" ${filterFuelType eq 'diesel' ? 'selected' : ''}>ডিজেল</option>
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
                                <option value="CANCELLED" ${filterStatus eq 'CANCELLED' ? 'selected' : ''}>প্রত্যাখ্যাত</option>
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
                    <c:if test="${not empty filterQ or not empty filterDate or not empty filterStatus or not empty filterFuelType}">
                        <a href="<c:url value='/operator/transactions'/>"
                           class="inline-flex items-center gap-2 rounded-md border border-gray-200 bg-white text-gray-700 px-5 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                            রিসেট
                        </a>
                    </c:if>
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
                    <my:dataTableHeadCell label="লেনদেন আইডি" width="w-40"/>
                    <my:dataTableHeadCell label="তারিখ ও সময়" width="w-56"/>
                    <my:dataTableHeadCell label="যানবাহন প্লেট"/>
                    <my:dataTableHeadCell label="পরিমাণ" width="w-32"/>
                    <my:dataTableHeadCell label="ধরন" width="w-28"/>
                    <my:dataTableHeadCell label="অবস্থা" align="right" width="w-32"/>
                </jsp:attribute>

                <jsp:body>
                    <c:forEach items="${transactions}" var="t">
                        <my:dataTableRow>
                            <my:dataTableBodyCell label="লেনদেন আইডি" tone="brand" bold="true" mono="true" nowrap="true">${t.displayCode}</my:dataTableBodyCell>
                            <my:dataTableBodyCell label="তারিখ ও সময়" tone="muted" nowrap="true">${t.createdAtDisplay}</my:dataTableBodyCell>
                            <my:dataTableBodyCell label="যানবাহন প্লেট">
                                <span class="inline-flex items-center gap-2">
                                    <span class="inline-flex items-center justify-center w-8 h-8 rounded-md bg-brand/5 text-brand shrink-0 [&>svg]:w-4 [&>svg]:h-4">
                                        <my:icon name="truck"/>
                                    </span>
                                    <span class="text-sm font-medium text-gray-900"><c:out value="${t.vehiclePlate}"/></span>
                                </span>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell label="পরিমাণ" bold="true" mono="true" nowrap="true">${t.amountDisplay}</my:dataTableBodyCell>
                            <my:dataTableBodyCell label="ধরন">
                                <span class="inline-flex items-center px-3 py-1 rounded-md text-xs font-semibold ${t.fuelTypeBadgeClass}">
                                    <c:out value="${t.fuelTypeLabel}"/>
                                </span>
                            </my:dataTableBodyCell>
                            <my:dataTableBodyCell label="অবস্থা" align="right" nowrap="true">
                                <span class="inline-flex items-center gap-1.5 text-sm font-medium ${t.statusTone}">
                                    <my:icon name="${t.statusIcon}"/>
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
