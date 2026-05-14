<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="রিভিউ | FACS">
<section id="signup" class="w-full max-w-3xl mx-auto">

    <my:stepper items="${stepLabels}" currentIndex="${currentIndex}"/>

    <header class="text-center mb-6">
        <h1 class="text-[20px] sm:text-[22px] font-bold text-gray-900 tracking-tight">আবেদন রিভিউ এবং নিশ্চিতকরণ</h1>
        <p class="mt-1 text-sm text-gray-500">
            অনুগ্রহ করে আপনার তথ্যগুলো যাচাই করুন। একবার সাবমিট করলে তা পরিবর্তন করা যাবে না।
        </p>
    </header>

    <c:if test="${param.error eq 'declaration'}">
        <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
            অনুগ্রহ করে ঘোষণাটি নিশ্চিত করুন।
        </div>
    </c:if>
    <c:if test="${not empty param.smsError}">
        <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
            এসএমএস পাঠাতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।
        </div>
    </c:if>

    <form action="<c:url value='/signup/review'/>" method="post" novalidate class="flex flex-col gap-5">
        <c:if test="${not empty _csrf}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </c:if>

        <article class="bg-white border border-gray-200 rounded-xl p-5 sm:p-6">
            <my:reviewCardHeader icon="user" title="ব্যক্তিগত তথ্য" editHref="/signup/personal"/>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-y-4 gap-x-6">
                <my:fieldDisplay label="পূর্ণ নাম" value="${draft.personal.name}"/>
                <my:fieldDisplay label="জাতীয় পরিচয়পত্র (NID)" value="${draft.personal.nidNumber}"/>
                <my:fieldDisplay label="ড্রাইভিং লাইসেন্স নম্বর" value="${draft.personal.licenseNumber}"/>
                <my:fieldDisplay label="মোবাইল নম্বর" value="${displayMobile}"/>
            </div>
        </article>

        <article class="bg-white border border-gray-200 rounded-xl p-5 sm:p-6">
            <my:reviewCardHeader icon="truck" title="যানবাহনের বিবরণ" editHref="/signup/vehicle"/>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-y-4 gap-x-6">
                <my:fieldDisplay label="রেজিস্ট্রেশন নম্বর" value="${draft.vehicle.plateNumber}"/>
                <my:fieldDisplay label="ব্র্যান্ড" value="${displayBrand}"/>
                <my:fieldDisplay label="মডেল ও বছর" value="${displayModelYear}"/>
                <my:fieldDisplay label="যানবাহনের ধরন" value="${displayVehicleType}"/>
            </div>
        </article>

        <article class="bg-white border border-gray-200 rounded-xl p-5 sm:p-6">
            <my:reviewCardHeader icon="lock" title="অ্যাকাউন্ট নিরাপত্তা" editHref="/signup/security"/>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-y-4 gap-x-6">
                <my:fieldDisplay label="পাসওয়ার্ড" value="••••••••"/>
                <my:fieldDisplay label="OTP যাচাইকরণ" value="মোবাইলে কোড পাঠানো হবে"/>
            </div>
        </article>

        <my:checkbox id="confirmDeclaration" name="confirmDeclaration"
                     label="আমি ঘোষণা করছি যে উপরে প্রদত্ত সকল তথ্য সত্য এবং নির্ভুল। কোনো ভুল তথ্যের জন্য আমার আবেদন বাতিল হতে পারে।"
                     required="true"/>

        <my:stepNav prevHref="/signup/security" primaryLabel="নিবন্ধন সম্পন্ন করুন"/>
    </form>
</section>
</my:layout>
