<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="ওটিপি যাচাইকরণ | FACS">
<section id="verify-otp" class="w-full max-w-md mx-auto">
    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-8 sm:px-9 sm:py-10"
             aria-labelledby="verify-title">

        <header class="text-center mb-7">
            <span class="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-indigo-100 text-gray-700 mb-4" aria-hidden="true">
                <my:icon name="shield"/>
            </span>
            <h1 id="verify-title" class="text-[22px] font-bold text-gray-900 tracking-tight mb-1.5">ওটিপি যাচাইকরণ</h1>
            <p class="text-sm text-gray-500">
                আমরা <span class="font-medium text-gray-700">${maskedMobile}</span> নম্বরে একটি ৬-সংখ্যার কোড পাঠিয়েছি।<br/>
                অনুগ্রহ করে কোডটি এখানে লিখুন।
            </p>
        </header>

        <c:if test="${not empty param.error}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
                কোডটি সঠিক নয়। অনুগ্রহ করে আবার চেষ্টা করুন।
            </div>
        </c:if>
        <c:if test="${not empty param.resent}">
            <div class="mb-4 rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700" role="status">
                একটি নতুন কোড পাঠানো হয়েছে।
            </div>
        </c:if>
        <c:if test="${not empty param.smsError}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
                এসএমএস পাঠাতে সমস্যা হয়েছে।
            </div>
        </c:if>

        <form class="flex flex-col gap-5" action="${verifyUrl}" method="post" novalidate>
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <my:otpBoxes name="code" length="6"/>

            <my:button label="যাচাই করুন" type="submit" variant="primary" leadingIcon="target"/>
        </form>

        <div class="mt-4 flex items-center justify-between text-sm">
            <span class="inline-flex items-center gap-1.5 text-gray-500">
                <span><my:icon name="clock"/></span>
                <span data-otp-timer="120" data-digits="bangla">০২:০০</span>
            </span>
            <form action="${resendUrl}" method="post" class="m-0">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <button type="submit" class="text-brand font-medium hover:underline focus-visible:outline-none focus-visible:underline">
                    কোড পুনরায় পাঠান
                </button>
            </form>
        </div>
    </article>

    <script src="<c:url value='/js/otp.js'/>" defer></script>
</section>
</my:layout>
