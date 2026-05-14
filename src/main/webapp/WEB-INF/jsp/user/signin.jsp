<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="সাইন ইন | FACS">
<section id="signin" class="w-full max-w-md mx-auto">
    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-8 sm:px-9 sm:py-10"
             aria-labelledby="signin-title">

        <header class="text-center mb-7">
            <h1 id="signin-title" class="text-[22px] font-bold text-gray-900 tracking-tight mb-1.5">সাইন ইন</h1>
            <p class="text-sm text-gray-500">আপনার অ্যাকাউন্টে নিরাপদে প্রবেশ করুন</p>
        </header>

        <c:if test="${not empty loginError}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">${loginError}</div>
        </c:if>
        <c:if test="${not empty loginNotice}">
            <div class="mb-4 rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700" role="status">${loginNotice}</div>
        </c:if>

        <form class="flex flex-col gap-4" action="<c:url value='/signin'/>" method="post" novalidate>
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <my:input id="mobile" name="mobile" type="tel" label="মোবাইল নম্বর"
                      placeholder="০১৮XXXXXXXX" leadingIcon="phone"
                      autocomplete="tel" required="true"/>

            <my:input id="password" name="password" type="password" label="পাসওয়ার্ড"
                      placeholder="পাসওয়ার্ড দিন" leadingIcon="lock"
                      passwordToggle="true"
                      actionLabel="পাসওয়ার্ড ভুলে গেছেন?" actionHref="/forgot-password"
                      autocomplete="current-password" required="true"/>

            <my:button label="সাইন ইন করুন" type="submit" variant="primary" trailingIcon="arrow"/>
        </form>

        <hr class="border-0 border-t border-gray-200 my-6"/>
        <p class="text-center text-sm text-gray-500 mb-3">অ্যাকাউন্ট নেই?</p>

        <my:button label="অ্যাকাউন্ট তৈরি করুন" variant="secondary" href="/signup"/>

    </article>

    <script src="<c:url value='/js/auth.js'/>" defer></script>
</section>
</my:layout>
