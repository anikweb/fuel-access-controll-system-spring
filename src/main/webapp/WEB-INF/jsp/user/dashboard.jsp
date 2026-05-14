<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="ড্যাশবোর্ড | FACS">
<section id="dashboard" class="w-full max-w-5xl mx-auto flex flex-col gap-6">

    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-6 sm:p-7 flex items-center gap-5">
        <span class="inline-flex items-center justify-center w-12 h-12 rounded-2xl bg-gradient-to-br from-brand-500 to-brand text-white shadow-[0_4px_12px_rgba(13,58,46,0.18)]" aria-hidden="true">
            <my:icon name="check"/>
        </span>
        <div class="flex-1 min-w-0">
            <h1 class="text-[20px] font-bold text-gray-900 tracking-tight">
                স্বাগতম, <span>${view.displayName}</span>
            </h1>
            <p class="text-sm text-gray-500">${view.mobile}</p>
        </div>
        <form action="<c:url value='/logout'/>" method="post" class="shrink-0">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>
            <my:button label="সাইন আউট" type="submit" variant="secondary"/>
        </form>
    </article>

    <c:if test="${empty view.profile}">
        <div class="bg-amber-50 border border-amber-200 rounded-xl px-5 py-4 text-sm text-amber-800 flex items-center justify-between gap-4">
            <span>আপনার প্রোফাইল এখনো সম্পূর্ণ নয়।</span>
            <a href="<c:url value='/signup'/>" class="font-semibold text-brand hover:underline">প্রোফাইল সম্পন্ন করুন</a>
        </div>
    </c:if>

    <c:if test="${not empty view.profile}">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

            <article class="bg-white border border-gray-200 rounded-xl p-6 sm:p-7">
                <my:reviewCardHeader icon="user" title="ব্যক্তিগত তথ্য"/>

                <div class="flex items-center gap-4 mb-5">
                    <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center text-gray-400 overflow-hidden shrink-0">
                        <c:choose>
                            <c:when test="${not empty view.profile.photoUrl}">
                                <img src="${view.profile.photoUrl}" alt="" class="w-full h-full object-cover"/>
                            </c:when>
                            <c:otherwise>
                                <span><my:icon name="user"/></span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="min-w-0">
                        <p class="text-sm font-semibold text-gray-900">${view.profile.name}</p>
                        <p class="text-xs text-gray-500">${view.mobile}</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-y-4 gap-x-6">
                    <my:fieldDisplay label="জাতীয় পরিচয়পত্র (NID)" value="${view.profile.nidNumber}"/>
                    <my:fieldDisplay label="ড্রাইভিং লাইসেন্স নম্বর" value="${view.profile.licenseNumber}"/>
                    <my:fieldDisplay label="জেলা" value="${view.profile.district}"/>
                    <my:fieldDisplay label="উপজেলা" value="${view.profile.subDistrict}"/>
                    <div class="sm:col-span-2">
                        <my:fieldDisplay label="ঠিকানা" value="${view.profile.address}"/>
                    </div>
                </div>
            </article>

            <article class="bg-white border border-gray-200 rounded-xl p-6 sm:p-7">
                <my:reviewCardHeader icon="truck" title="যানবাহন"/>

                <c:if test="${empty view.vehicles}">
                    <p class="text-sm text-gray-500">কোনো যানবাহন নিবন্ধিত নেই।</p>
                </c:if>

                <c:if test="${not empty view.vehicles}">
                    <div class="flex flex-col gap-5">
                        <c:forEach items="${view.vehicles}" var="v">
                            <div class="rounded-lg border border-gray-200 p-4">
                                <div class="flex items-start gap-4">
                                    <div class="w-16 h-16 rounded-md bg-gray-100 flex items-center justify-center text-gray-400 overflow-hidden shrink-0">
                                        <c:choose>
                                            <c:when test="${not empty v.plateImageUrl}">
                                                <img src="${v.plateImageUrl}" alt="" class="w-full h-full object-cover"/>
                                            </c:when>
                                            <c:otherwise>
                                                <span><my:icon name="car"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="flex-1 min-w-0">
                                        <p class="text-sm font-semibold text-gray-900">${v.plateNumber}</p>
                                        <p class="text-xs text-gray-500">
                                            <span>${v.brand}</span>
                                            <c:if test="${not empty v.model}"> • <span>${v.model}</span></c:if>
                                            <c:if test="${not empty v.year}"> • <span>${v.year}</span></c:if>
                                        </p>
                                    </div>
                                </div>
                                <div class="grid grid-cols-2 gap-y-3 gap-x-6 mt-4">
                                    <my:fieldDisplay label="ধরন" value="${v.type}"/>
                                    <my:fieldDisplay label="রং" value="${v.color}"/>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </article>
        </div>
    </c:if>

</section>
</my:layout>
