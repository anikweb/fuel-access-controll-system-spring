<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="যানবাহনের বিস্তারিত | FACS অ্যাডমিন">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"        icon="users"     label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt"   label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles"     icon="truck"     label="যানবাহন" active="true"/>
        <my:sidebarNavItem href="/admin/stations"     icon="terminal"  label="স্টেশন"/>
        <my:sidebarNavItem href="/admin/settings"     icon="settings"  label="সেটিংস"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header class="flex items-center gap-3">
                <a href="<c:url value='/admin/vehicles'/>"
                   class="inline-flex items-center justify-center w-10 h-10 rounded-md bg-white border border-gray-200 text-gray-500 hover:bg-gray-50 hover:text-brand transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30"
                   aria-label="পিছনে">
                    <my:icon name="arrowLeft"/>
                </a>
                <h1 class="text-[26px] sm:text-[30px] font-bold text-brand tracking-tight leading-snug">যানবাহনের বিস্তারিত তথ্য</h1>
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

            <article class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                <div class="grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-6 p-5 sm:p-6 items-center">
                    <div class="w-full h-44 sm:h-48 rounded-lg bg-gray-100 flex items-center justify-center text-gray-400 overflow-hidden">
                        <c:choose>
                            <c:when test="${not empty vehicle.plateImageUrl}">
                                <img src="${vehicle.plateImageUrl}" alt="" class="w-full h-full object-cover"/>
                            </c:when>
                            <c:otherwise>
                                <span class="[&>svg]:w-20 [&>svg]:h-20"><my:icon name="${vehicle.typeIcon}"/></span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="flex flex-col gap-5">
                        <h2 class="text-[22px] sm:text-[26px] font-bold text-brand tracking-tight text-right"><c:out value="${vehicle.plateNumber}"/></h2>
                        <div class="grid grid-cols-1 sm:grid-cols-3 gap-5 sm:text-right">
                            <div>
                                <p class="text-xs text-gray-500 mb-1">সর্বশেষ ফুয়েলিং</p>
                                <p class="text-base font-semibold text-gray-900"><c:out value="${vehicle.lastRefueledDisplay}"/></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500 mb-1">মোট ফুয়েল</p>
                                <p class="text-base font-semibold text-gray-900 tabular-nums"><c:out value="${vehicle.totalLitersDisplay}"/></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500 mb-1">পরবর্তী ফুয়েল নিতে পারবে</p>
                                <p class="text-base font-semibold ${vehicle.eligibleNow ? 'text-emerald-600' : 'text-brand-red'}"><c:out value="${vehicle.nextEligibleDisplay}"/></p>
                            </div>
                        </div>
                        <div class="grid grid-cols-1 sm:grid-cols-3 gap-5 sm:text-right border-t border-gray-100 pt-4">
                            <div>
                                <p class="text-xs text-gray-500 mb-1 flex items-center gap-1.5 sm:justify-end">
                                    <span>মাসিক কোটা</span>
                                    <c:choose>
                                        <c:when test="${vehicle.quotaOverridden}">
                                            <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold bg-indigo-50 text-indigo-700">যানবাহন-স্পেসিফিক</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold bg-gray-100 text-gray-600">গ্লোবাল ডিফল্ট</span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <p class="text-base font-semibold text-gray-900 tabular-nums"><c:out value="${vehicle.monthlyQuotaDisplay}"/></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500 mb-1">এই মাসে ব্যবহৃত</p>
                                <p class="text-base font-semibold text-gray-900 tabular-nums"><c:out value="${vehicle.monthlyUsedDisplay}"/></p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500 mb-1">এই মাসে অবশিষ্ট</p>
                                <p class="text-base font-semibold tabular-nums ${vehicle.eligibleNow ? 'text-emerald-600' : 'text-brand-red'}"><c:out value="${vehicle.monthlyRemainingDisplay}"/></p>
                            </div>
                        </div>
                        <c:if test="${not empty vehicle.eligibilityReason}">
                            <div class="rounded-md bg-amber-50 border border-amber-200 px-4 py-3 text-sm text-amber-800 text-right">
                                <c:out value="${vehicle.eligibilityReason}"/>
                            </div>
                        </c:if>
                    </div>
                </div>
            </article>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

                <article class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                    <header class="flex items-center gap-2 px-6 py-4 bg-gray-100 border-b border-gray-200">
                        <span class="text-gray-700 [&>svg]:w-5 [&>svg]:h-5"><my:icon name="${vehicle.typeIcon}"/></span>
                        <h3 class="text-base font-semibold text-brand">যানবাহনের তথ্য</h3>
                    </header>
                    <div class="p-6 grid grid-cols-1 sm:grid-cols-2 gap-y-5 gap-x-6">
                        <my:fieldDisplay label="প্লেট নম্বর" value="${vehicle.plateNumber}"/>
                        <my:fieldDisplay label="মডেল" value="${vehicle.modelWithYear}"/>
                        <my:fieldDisplay label="রং" value="${vehicle.color}"/>
                        <my:fieldDisplay label="চ্যাসিস নম্বর" value="${vehicle.chassisNumber}"/>
                        <my:fieldDisplay label="নিবন্ধন তারিখ" value="${vehicle.registeredOn}"/>
                        <my:fieldDisplay label="ইঞ্জিন নম্বর" value="${vehicle.engineNumber}"/>
                    </div>
                </article>

                <article class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                    <header class="flex items-center gap-2 px-6 py-4 bg-gray-100 border-b border-gray-200">
                        <span class="text-gray-700 [&>svg]:w-5 [&>svg]:h-5"><my:icon name="user"/></span>
                        <h3 class="text-base font-semibold text-brand">মালিকের তথ্য</h3>
                    </header>
                    <div class="p-6 grid grid-cols-1 sm:grid-cols-2 gap-y-5 gap-x-6">
                        <my:fieldDisplay label="মালিকের নাম" value="${vehicle.owner.name}"/>
                        <my:fieldDisplay label="যোগাযোগের নম্বর" value="${vehicle.owner.mobile}"/>
                        <div class="sm:col-span-2">
                            <my:fieldDisplay label="ঠিকানা" value="${vehicle.owner.address}"/>
                        </div>
                        <my:fieldDisplay label="এনআইডি নম্বর" value="${vehicle.owner.nidNumber}"/>
                        <my:fieldDisplay label="ড্রাইভিং লাইসেন্স" value="${vehicle.owner.licenseNumber}"/>
                    </div>
                </article>

            </div>

            <article class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                <header class="flex items-center justify-between gap-3 px-6 py-4 bg-gray-100 border-b border-gray-200">
                    <div class="flex items-center gap-2">
                        <span class="text-gray-700 [&>svg]:w-5 [&>svg]:h-5"><my:icon name="receipt"/></span>
                        <h3 class="text-base font-semibold text-brand">সাম্প্রতিক লেনদেন</h3>
                    </div>
                    <a href="<c:url value='/admin/transactions?q=${vehicle.plateNumber}'/>"
                       class="inline-flex items-center gap-1 text-sm font-semibold text-brand hover:underline">
                        <span>সবগুলো দেখুন</span>
                        <my:icon name="chevronRight"/>
                    </a>
                </header>

                <my:dataTable
                    isEmpty="${empty vehicle.recentTransactions}"
                    emptyMessage="এই যানবাহনের জন্য এখনো কোনো লেনদেন নেই।"
                    colspan="6"
                    paginated="false">

                    <jsp:attribute name="header">
                        <my:dataTableHeadCell label="লেনদেন আইডি" width="w-40"/>
                        <my:dataTableHeadCell label="তারিখ ও সময়" width="w-56"/>
                        <my:dataTableHeadCell label="স্টেশন"/>
                        <my:dataTableHeadCell label="অপারেটর"/>
                        <my:dataTableHeadCell label="পরিমাণ" width="w-32"/>
                        <my:dataTableHeadCell label="অবস্থা" align="right" width="w-32"/>
                    </jsp:attribute>

                    <jsp:body>
                        <c:forEach items="${vehicle.recentTransactions}" var="t">
                            <my:dataTableRow>
                                <my:dataTableBodyCell label="লেনদেন আইডি" tone="brand" bold="true" mono="true" nowrap="true">${t.displayCode}</my:dataTableBodyCell>
                                <my:dataTableBodyCell label="তারিখ ও সময়" tone="muted" nowrap="true">${t.createdAtDisplay}</my:dataTableBodyCell>
                                <my:dataTableBodyCell label="স্টেশন"><c:out value="${t.stationName}"/></my:dataTableBodyCell>
                                <my:dataTableBodyCell label="অপারেটর" tone="muted"><c:out value="${t.operatorName}"/></my:dataTableBodyCell>
                                <my:dataTableBodyCell label="পরিমাণ" bold="true" mono="true" nowrap="true">${t.amountDisplay}</my:dataTableBodyCell>
                                <my:dataTableBodyCell label="অবস্থা" align="right" nowrap="true">
                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold ${t.statusBadgeClass}">
                                        <c:out value="${t.statusLabel}"/>
                                    </span>
                                </my:dataTableBodyCell>
                            </my:dataTableRow>
                        </c:forEach>
                    </jsp:body>
                </my:dataTable>
            </article>

            <article class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                <header class="flex items-center gap-2 px-6 py-4 bg-gray-100 border-b border-gray-200">
                    <span class="text-gray-700 [&>svg]:w-5 [&>svg]:h-5"><my:icon name="settings"/></span>
                    <h3 class="text-base font-semibold text-brand">যোগ্যতার সেটিংস (এই যানবাহনের জন্য)</h3>
                </header>

                <form action="<c:url value='/admin/vehicles/${vehicle.id}/eligibility'/>" method="post" novalidate
                      class="p-6 flex flex-col gap-6">
                    <c:if test="${not empty _csrf}">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    </c:if>

                    <p class="text-sm text-gray-500">
                        ব্লাঙ্ক রাখলে গ্লোবাল ডিফল্ট প্রযোজ্য হবে।
                        গ্লোবাল ডিফল্ট পরিবর্তনের জন্য <a class="text-brand hover:underline font-semibold" href="<c:url value='/admin/settings'/>">সেটিংস পেজ</a> দেখুন।
                    </p>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
                        <div class="flex flex-col">
                            <my:input id="monthlyQuotaLiters" name="monthlyQuotaLiters" type="number"
                                      label="মাসিক কোটা (লিটার)"
                                      leadingIcon="fuelPump"
                                      placeholder="গ্লোবাল ডিফল্ট ব্যবহার করুন"
                                      autocomplete="off"
                                      value="${vehicleEligibility.monthlyQuotaLiters}"
                                      error="${errors['monthlyQuotaLiters']}"/>
                            <p class="mt-1.5 text-xs text-gray-500">
                                গ্লোবাল ডিফল্ট: <span class="font-semibold text-gray-700"><c:out value="${vehicle.globalMonthlyQuotaDisplay}"/></span>
                            </p>
                        </div>

                        <div class="flex flex-col">
                            <my:input id="cooldownHours" name="cooldownHours" type="number"
                                      label="অপেক্ষমান সময় (ঘণ্টা)"
                                      leadingIcon="clock"
                                      placeholder="গ্লোবাল ডিফল্ট ব্যবহার করুন"
                                      autocomplete="off"
                                      value="${vehicleEligibility.cooldownHours}"
                                      error="${errors['cooldownHours']}"/>
                            <p class="mt-1.5 text-xs text-gray-500">
                                গ্লোবাল ডিফল্ট: <span class="font-semibold text-gray-700"><c:out value="${vehicle.globalCooldownDisplay}"/></span>
                            </p>
                        </div>
                    </div>

                    <div class="flex justify-end gap-3 border-t border-gray-100 pt-5">
                        <div class="w-44">
                            <my:button label="সেটিংস সংরক্ষণ করুন" type="submit"/>
                        </div>
                    </div>
                </form>
            </article>

        </section>
    </jsp:body>

</my:panelLayout>
