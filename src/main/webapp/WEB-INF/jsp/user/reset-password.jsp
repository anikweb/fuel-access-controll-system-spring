<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="নতুন পাসওয়ার্ড | FACS">
<section id="reset" class="w-full max-w-md mx-auto">
    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-8 sm:px-9 sm:py-10"
             aria-labelledby="reset-title">

        <header class="text-center mb-7">
            <h1 id="reset-title" class="text-[22px] font-bold text-gray-900 tracking-tight mb-1.5">নতুন পাসওয়ার্ড সেট করুন</h1>
            <p class="text-sm text-gray-500">আপনার নতুন পাসওয়ার্ডটি কমপক্ষে ৮ অক্ষরের হতে হবে</p>
        </header>

        <c:if test="${param.error eq 'mismatch'}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">পাসওয়ার্ড মিলছে না।</div>
        </c:if>
        <c:if test="${param.error eq 'weak'}">
            <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">পাসওয়ার্ড কমপক্ষে ৮ অক্ষর হতে হবে।</div>
        </c:if>

        <form class="flex flex-col gap-4" action="<c:url value='/reset-password'/>" method="post" novalidate>
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <my:input id="password" name="password" type="password" label="নতুন পাসওয়ার্ড"
                      placeholder="পাসওয়ার্ড দিন" leadingIcon="lock"
                      passwordToggle="true" autocomplete="new-password" required="true"/>

            <my:passwordStrength targetId="password"/>

            <my:input id="passwordConfirm" name="passwordConfirm" type="password" label="পাসওয়ার্ড নিশ্চিত করুন"
                      placeholder="আবার পাসওয়ার্ড দিন" leadingIcon="lock"
                      passwordToggle="true" autocomplete="new-password" required="true"/>

            <my:button label="পাসওয়ার্ড আপডেট করুন" type="submit" variant="primary" trailingIcon="arrow"/>
        </form>
    </article>

    <script src="<c:url value='/js/auth.js'/>" defer></script>
    <script src="<c:url value='/js/password-strength.js'/>" defer></script>
</section>
</my:layout>
