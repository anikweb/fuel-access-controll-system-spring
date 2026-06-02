<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="ড্যাশবোর্ড | FACS">

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

        <article class="bg-white border border-gray-200 rounded-2xl p-5 shadow-sm">
            <p class="text-[13px] font-semibold text-gray-500 flex items-center gap-2">
                <my:icon name="truck"/>
                <span>যানবাহন</span>
            </p>

            <c:choose>
                <c:when test="${empty view.vehicles}">
                    <p class="mt-4 text-sm text-gray-500">কোনো যানবাহন নিবন্ধিত নেই।</p>
                </c:when>
                <c:otherwise>
                    <div class="mt-4 flex flex-col gap-4">
                        <c:forEach items="${view.vehicles}" var="v">
                            <div class="rounded-xl border border-gray-200 px-4 py-3.5 bg-white">
                                <p class="text-[15px] font-bold text-gray-900 leading-tight"><c:out value="${v.plateDisplay}"/></p>
                                <p class="mt-2 text-xs text-gray-500">
                                    <span class="font-semibold text-gray-600">ব্র্যান্ড:</span>
                                    <c:out value="${empty v.brand ? '—' : v.brand}"/>
                                    <span class="mx-1.5 text-gray-300">•</span>
                                    <span class="font-semibold text-gray-600">মডেল:</span>
                                    <c:out value="${empty v.model ? '—' : v.model}"/>
                                </p>
                                <div class="mt-3 flex items-center justify-between text-[11px] font-semibold text-gray-500">
                                    <span>মাসিক কোটা ব্যবহৃত</span>
                                    <span class="text-brand">${v.percentUsedDisplay}</span>
                                </div>
                                <div class="mt-1.5 h-1.5 rounded-full bg-gray-100 overflow-hidden">
                                    <div class="h-full bg-brand rounded-full transition-all" style="width: ${v.percentUsed}%"></div>
                                </div>
                                <p class="mt-1.5 text-[11px] text-gray-500"><c:out value="${v.usedDisplay}"/> / <c:out value="${v.quotaDisplay}"/></p>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </article>

        <c:if test="${view.eligibility.hasVehicles}">
            <article class="bg-white border border-gray-200 rounded-2xl p-5 shadow-sm">
                <div class="flex items-center justify-between gap-3">
                    <p class="text-[13px] font-semibold text-gray-500 flex items-center gap-2">
                        <my:icon name="checkCircle"/>
                        <span>রিফুয়েলিং যোগ্যতা</span>
                    </p>
                    <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full border text-[11px] font-semibold ${view.eligibility.badgeClass}">
                        <my:icon name="check"/>
                        <span><c:out value="${view.eligibility.badgeLabel}"/></span>
                    </span>
                </div>

                <div class="mt-4 flex items-start gap-2.5">
                    <span class="inline-flex items-center justify-center w-7 h-7 rounded-md bg-gray-100 text-gray-500 shrink-0 [&>svg]:w-4 [&>svg]:h-4">
                        <my:icon name="clock"/>
                    </span>
                    <div class="min-w-0">
                        <p class="text-[11px] font-semibold text-gray-500">সর্বশেষ রিফুয়েলিং</p>
                        <p class="text-[13px] font-semibold text-gray-900 mt-0.5"><c:out value="${view.eligibility.lastRefueledDisplay}"/></p>
                    </div>
                </div>

                <div class="mt-3 flex items-start gap-2.5">
                    <span class="inline-flex items-center justify-center w-7 h-7 rounded-md bg-gray-100 text-gray-500 shrink-0 [&>svg]:w-4 [&>svg]:h-4">
                        <my:icon name="calendar"/>
                    </span>
                    <div class="min-w-0">
                        <p class="text-[11px] font-semibold text-gray-500">পরবর্তী রিফুয়েলিং</p>
                        <p class="text-[13px] font-semibold text-gray-900 mt-0.5"><c:out value="${view.eligibility.nextEligibleDisplay}"/></p>
                    </div>
                </div>
            </article>
        </c:if>

    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <article class="bg-white border border-gray-200 rounded-xl shadow-sm px-6 py-5 flex items-center gap-4">
                <span class="inline-flex items-center justify-center w-12 h-12 rounded-xl bg-brand/5 text-brand shadow-sm">
                    <my:icon name="shield"/>
                </span>
                <div class="min-w-0">
                    <h1 class="text-[22px] sm:text-[24px] font-bold text-gray-900 tracking-tight leading-snug">
                        স্বাগতম, <c:out value="${view.displayName}"/>
                    </h1>
                    <p class="mt-0.5 text-sm text-gray-500"><c:out value="${view.mobile}"/></p>
                </div>
            </article>

            <c:if test="${empty view.profile}">
                <div class="rounded-lg border border-amber-200 bg-amber-50 text-amber-800 px-4 py-3 text-sm font-medium flex items-center justify-between gap-4">
                    <span>আপনার প্রোফাইল এখনো সম্পূর্ণ নয়।</span>
                    <a href="<c:url value='/signup'/>" class="font-semibold text-brand hover:underline">প্রোফাইল সম্পন্ন করুন</a>
                </div>
            </c:if>

            <section class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                <header class="flex items-center justify-between gap-4 px-6 py-4 border-b border-gray-100">
                    <h2 class="text-[18px] font-bold text-brand tracking-tight">সাম্প্রতিক লেনদেন</h2>
                    <a href="<c:url value='/transactions'/>"
                       class="inline-flex items-center gap-1 text-sm font-semibold text-brand hover:underline">
                        <span>সবগুলো দেখুন</span>
                        <my:icon name="chevronRight"/>
                    </a>
                </header>

                <div class="md:overflow-x-auto">
                    <table class="responsive-table w-full text-sm">
                        <thead class="bg-gray-100 text-gray-700">
                            <tr class="text-left text-[13px] font-medium">
                                <th class="px-6 py-3 font-semibold">লেনদেন আইডি</th>
                                <th class="px-6 py-3 font-semibold">তারিখ ও সময়</th>
                                <th class="px-6 py-3 font-semibold">স্টেশন</th>
                                <th class="px-6 py-3 font-semibold">পরিমাণ</th>
                                <th class="px-6 py-3 font-semibold text-right">অবস্থা</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <c:choose>
                                <c:when test="${empty view.recentTransactions}">
                                    <tr class="responsive-table-empty">
                                        <td colspan="5" class="px-6 py-12 text-center text-sm text-gray-500">
                                            এখনো কোনো লেনদেন নেই।
                                        </td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${view.recentTransactions}" var="t">
                                        <tr>
                                            <td data-label="লেনদেন আইডি" class="px-6 py-4 align-middle whitespace-nowrap text-sm font-semibold text-brand tabular-nums">${t.displayCode}</td>
                                            <td data-label="তারিখ ও সময়" class="px-6 py-4 align-middle whitespace-nowrap text-sm text-gray-700">${t.createdAtDisplay}</td>
                                            <td data-label="স্টেশন" class="px-6 py-4 align-middle text-sm text-gray-700"><c:out value="${t.stationName}"/></td>
                                            <td data-label="পরিমাণ" class="px-6 py-4 align-middle whitespace-nowrap text-sm font-semibold text-gray-900 tabular-nums">${t.amountDisplay}</td>
                                            <td data-label="অবস্থা" class="px-6 py-4 align-middle whitespace-nowrap text-right">
                                                <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold ${t.statusBadgeClass}">
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
