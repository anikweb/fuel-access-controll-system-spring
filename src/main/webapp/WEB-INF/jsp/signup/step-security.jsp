<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="অ্যাকাউন্ট তথ্য | FACS">
<section id="signup" class="w-full max-w-3xl mx-auto">

    <my:stepper items="${stepLabels}" currentIndex="${currentIndex}"/>

    <c:if test="${param.error eq 'duplicate'}">
        <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
            এই মোবাইল নম্বর দিয়ে ইতিমধ্যে একটি অ্যাকাউন্ট রয়েছে। অনুগ্রহ করে সাইন ইন করুন।
        </div>
    </c:if>
    <c:if test="${param.error eq 'registrationFailed'}">
        <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">
            নিবন্ধন সম্পন্ন হয়নি। অনুগ্রহ করে তথ্য যাচাই করে আবার চেষ্টা করুন।
        </div>
    </c:if>

    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-6 sm:p-8">

        <form action="<c:url value='/signup/security'/>" method="post" novalidate class="flex flex-col gap-6">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <header class="text-center">
                <h1 class="text-[20px] sm:text-[22px] font-bold text-gray-900 tracking-tight">অ্যাকাউন্ট তথ্য</h1>
                <p class="mt-1 text-sm text-gray-500">আপনার নিরাপত্তা নিশ্চিত করতে শক্তিশালী পাসওয়ার্ড ব্যবহার করুন।</p>
            </header>

            <my:input id="mobile" name="mobile" type="tel" label="ফোন নম্বর *"
                      placeholder="+৮৮০ ১৭XXXXXXXX" leadingIcon="phone"
                      autocomplete="tel" required="true"
                      value="${draft.security.mobile}" error="${errors['mobile']}"/>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <my:input id="password" name="password" type="password" label="পাসওয়ার্ড *"
                          placeholder="••••••••" leadingIcon="lock"
                          passwordToggle="true" autocomplete="new-password" required="true"
                          error="${errors['password']}"/>
                <my:input id="passwordConfirm" name="passwordConfirm" type="password" label="পাসওয়ার্ড নিশ্চিত করুন *"
                          placeholder="••••••••" leadingIcon="lockReset"
                          passwordToggle="true" autocomplete="new-password" required="true"
                          error="${errors['passwordConfirm']}"/>
            </div>

            <my:passwordStrength targetId="password"/>

            <hr class="border-0 border-t border-gray-200"/>

            <my:stepNav prevHref="/signup/vehicle" primaryLabel="পরবর্তী ধাপ"/>
        </form>
    </article>

    <script src="<c:url value='/js/auth.js'/>" defer></script>
    <script src="<c:url value='/js/password-strength.js'/>" defer></script>
</section>
</my:layout>
