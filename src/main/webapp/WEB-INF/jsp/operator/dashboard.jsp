<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="অপারেটর ড্যাশবোর্ড | FACS">

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
        <section class="flex flex-col gap-6 w-full">

            <c:if test="${not empty flash}">
                <div class="rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 px-4 py-3 text-sm font-medium flex items-center gap-2">
                    <my:icon name="checkCircle"/>
                    <span><c:out value="${flash}"/></span>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="rounded-lg border border-red-200 bg-red-50 text-brand-red px-4 py-3 text-sm font-medium flex items-center gap-2">
                    <my:icon name="shieldAlert"/>
                    <span><c:out value="${error}"/></span>
                </div>
            </c:if>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">

                <article class="bg-white border border-gray-200 rounded-xl px-6 py-5 flex flex-col gap-3">
                    <span class="inline-flex items-center justify-center w-9 h-9 rounded-full bg-emerald-50 text-emerald-600">
                        <my:icon name="checkCircle"/>
                    </span>
                    <p class="text-sm text-gray-500">সফল ফুয়েল প্রদান</p>
                    <p class="text-[34px] leading-none font-semibold text-brand">${successCount}</p>
                </article>

                <article class="bg-white border border-gray-200 rounded-xl px-6 py-5 flex flex-col gap-3">
                    <span class="inline-flex items-center justify-center w-9 h-9 rounded-full bg-red-50 text-brand-red">
                        <my:icon name="shieldAlert"/>
                    </span>
                    <p class="text-sm text-gray-500">প্রত্যাখ্যাত অনুরোধ</p>
                    <p class="text-[34px] leading-none font-semibold text-brand">${rejectedCount}</p>
                </article>

                <article class="bg-white border border-gray-200 rounded-xl px-6 py-5 flex flex-col gap-3">
                    <span class="inline-flex items-center justify-center w-9 h-9 rounded-full bg-brand/5 text-brand">
                        <my:icon name="fuelPump"/>
                    </span>
                    <p class="text-sm text-gray-500">মোট জ্বালানি বিতরণ</p>
                    <p class="text-[34px] leading-none font-semibold text-brand">${totalLitersDisplay}</p>
                </article>

            </div>

            <section class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                <header class="flex items-center justify-between gap-4 px-6 py-4 border-b border-gray-100">
                    <h2 class="text-[18px] font-bold text-brand tracking-tight">সাম্প্রতিক লেনদেন</h2>
                    <a href="<c:url value='/operator/transactions'/>"
                       class="inline-flex items-center gap-1 text-sm font-semibold text-brand hover:underline">
                        <span>সব দেখুন</span>
                        <my:icon name="arrow"/>
                    </a>
                </header>

                <div class="overflow-x-auto">
                    <table class="w-full text-sm">
                        <thead class="bg-gray-100 text-gray-700">
                            <tr class="text-left text-[13px] font-medium">
                                <th class="px-6 py-3 font-semibold">সময় ও তারিখ</th>
                                <th class="px-6 py-3 font-semibold">যানবাহন প্লেট নম্বর</th>
                                <th class="px-6 py-3 font-semibold">পরিমাণ</th>
                                <th class="px-6 py-3 font-semibold">ধরণ</th>
                                <th class="px-6 py-3 font-semibold">অবস্থা</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <c:choose>
                                <c:when test="${empty recentTransactions}">
                                    <tr>
                                        <td colspan="5" class="px-6 py-12 text-center text-sm text-gray-500">
                                            এখনো কোনো লেনদেন নেই।
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${recentTransactions}" var="t">
                                        <tr>
                                            <td class="px-6 py-4 align-top whitespace-nowrap">
                                                <p class="text-sm font-medium text-gray-900">${t.timeOfDay}</p>
                                                <p class="text-xs text-gray-500 mt-0.5">${t.dateLine}</p>
                                            </td>
                                            <td class="px-6 py-4 align-middle whitespace-nowrap text-sm font-mono text-gray-800">
                                                <c:out value="${t.vehiclePlate}"/>
                                            </td>
                                            <td class="px-6 py-4 align-middle whitespace-nowrap text-sm text-gray-800">
                                                ${t.amountDisplay}
                                            </td>
                                            <td class="px-6 py-4 align-middle whitespace-nowrap">
                                                <span class="inline-flex items-center px-3 py-1 rounded-md text-xs font-semibold ${t.fuelTypeBadgeClass}">
                                                    <c:out value="${t.fuelTypeLabel}"/>
                                                </span>
                                            </td>
                                            <td class="px-6 py-4 align-middle whitespace-nowrap">
                                                <span class="inline-flex items-center gap-1.5 text-sm font-medium ${t.statusTone}">
                                                    <my:icon name="${t.statusIcon}"/>
                                                    <c:out value="${t.statusLabel}"/>
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>

        </section>
    </jsp:body>

</my:panelLayout>
