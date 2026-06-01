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
                                <p class="text-base font-semibold text-gray-900">—</p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500 mb-1">মোট ফুয়েল</p>
                                <p class="text-base font-semibold text-gray-900">—</p>
                            </div>
                            <div>
                                <p class="text-xs text-gray-500 mb-1">পরবর্তী ফুয়েল নিতে পারবে</p>
                                <p class="text-base font-semibold text-brand-red">—</p>
                            </div>
                        </div>
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

        </section>
    </jsp:body>

</my:panelLayout>
