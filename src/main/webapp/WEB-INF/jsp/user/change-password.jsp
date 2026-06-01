<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="পাসওয়ার্ড পরিবর্তন | FACS">
<section id="change-password" class="w-full max-w-md mx-auto">
    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-8 sm:px-9 sm:py-10"
             aria-labelledby="change-password-title">

        <header class="mb-7">
            <h1 id="change-password-title" class="text-[22px] font-bold text-gray-900 tracking-tight mb-1.5">পাসওয়ার্ড পরিবর্তন</h1>
            <p class="text-sm text-gray-500">আপনার অ্যাকাউন্ট নিরাপদ রাখতে একটি শক্তিশালী পাসওয়ার্ড ব্যবহার করুন।</p>
        </header>

        <c:if test="${param.error eq 'current'}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">বর্তমান পাসওয়ার্ড সঠিক নয়।</div>
        </c:if>
        <c:if test="${param.error eq 'mismatch'}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">নতুন পাসওয়ার্ড দুটি মিলছে না।</div>
        </c:if>
        <c:if test="${param.error eq 'weak'}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">পাসওয়ার্ড কমপক্ষে ৮ অক্ষর, একটি বড় হাতের, একটি ছোট হাতের অক্ষর ও একটি সংখ্যা থাকতে হবে।</div>
        </c:if>
        <c:if test="${param.error eq 'same'}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">নতুন পাসওয়ার্ড আগের পাসওয়ার্ড থেকে আলাদা হতে হবে।</div>
        </c:if>

        <form class="flex flex-col gap-5" action="<c:url value='/change-password'/>" method="post" novalidate>
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <my:input id="currentPassword" name="currentPassword" type="password"
                      label="বর্তমান পাসওয়ার্ড" placeholder="বর্তমান পাসওয়ার্ড দিন"
                      passwordToggle="true" autocomplete="current-password" required="true"/>

            <div class="flex flex-col gap-2">
                <my:input id="newPassword" name="newPassword" type="password"
                          label="নতুন পাসওয়ার্ড" placeholder="কমপক্ষে ৮টি অক্ষর"
                          passwordToggle="true" autocomplete="new-password" required="true"/>
                <my:passwordStrength targetId="newPassword"/>
            </div>

            <my:input id="confirmPassword" name="confirmPassword" type="password"
                      label="পাসওয়ার্ড নিশ্চিত করুন" placeholder="নতুন পাসওয়ার্ডটি আবার লিখুন"
                      passwordToggle="true" autocomplete="new-password" required="true"/>

            <div class="mt-2 flex items-center justify-between gap-4">
                <div class="w-full sm:w-auto sm:min-w-[220px]">
                    <my:button label="পাসওয়ার্ড আপডেট করুন" type="submit" variant="primary" leadingIcon="lockReset"/>
                </div>
                <a href="<c:url value='/forgot-password'/>"
                   class="text-sm font-medium text-gray-600 hover:text-brand inline-flex items-center gap-1">
                    <span>পাসওয়ার্ড ভুলে গেছেন?</span>
                    <span class="text-gray-400"><my:icon name="arrow"/></span>
                </a>
            </div>
        </form>
    </article>

    <script src="<c:url value='/js/auth.js'/>" defer></script>
    <script src="<c:url value='/js/password-strength.js'/>" defer></script>
</section>
</my:layout>
