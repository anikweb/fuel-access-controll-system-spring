<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="পাসওয়ার্ড পুনরুদ্ধার | FACS">
<section id="forgot" class="w-full max-w-md mx-auto">
    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-8 sm:px-9 sm:py-10"
             aria-labelledby="forgot-title">

        <header class="text-center mb-7">
            <h1 id="forgot-title" class="text-[22px] font-bold text-gray-900 tracking-tight mb-1.5">পাসওয়ার্ড পুনরুদ্ধার</h1>
            <p class="text-sm text-gray-500">আপনার মোবাইল নম্বর দিন এবং আমরা একটি ওটিপি (OTP) পাঠাব</p>
        </header>

        <c:if test="${param.error eq 'notFound'}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
                এই মোবাইল নম্বর দিয়ে কোনো অ্যাকাউন্ট পাওয়া যায়নি।
            </div>
        </c:if>
        <c:if test="${not empty param.smsError}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
                এসএমএস পাঠাতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।
            </div>
        </c:if>

        <form class="flex flex-col gap-4" action="<c:url value='/forgot-password'/>" method="post" novalidate>
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <my:input id="mobile" name="mobile" type="tel" label="মোবাইল নম্বর"
                      placeholder="০১৮XXXXXXXX" leadingIcon="phone"
                      autocomplete="tel" required="true"/>

            <my:button label="ওটিপি পাঠান" type="submit" variant="primary" trailingIcon="arrow"/>

            <my:button label="লগইন-এ ফিরে যান" variant="secondary" href="/"/>
        </form>
    </article>
</section>
</my:layout>
