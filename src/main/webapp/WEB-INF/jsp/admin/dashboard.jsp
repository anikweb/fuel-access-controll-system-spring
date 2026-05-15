<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="অ্যাডমিন ড্যাশবোর্ড | FACS">
<section id="admin-dashboard" class="w-full max-w-5xl mx-auto flex flex-col gap-6">

    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-6 sm:p-7 flex items-center gap-5">
        <span class="inline-flex items-center justify-center w-12 h-12 rounded-2xl bg-gradient-to-br from-brand-500 to-brand text-white shadow-[0_4px_12px_rgba(13,58,46,0.18)]" aria-hidden="true">
            <my:icon name="user"/>
        </span>
        <div class="flex-1 min-w-0">
            <h1 class="text-[20px] font-bold text-gray-900 tracking-tight">অ্যাডমিন প্যানেল</h1>
            <p class="text-sm text-gray-500">${displayName}</p>
        </div>
        <form action="<c:url value='/logout'/>" method="post" class="shrink-0">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>
            <my:button label="সাইন আউট" type="submit" variant="secondary"/>
        </form>
    </article>

    <article class="bg-white border border-gray-200 rounded-xl p-6 sm:p-7">
        <p class="text-sm text-gray-600">এখানে অ্যাডমিন ফিচারগুলো শীঘ্রই যুক্ত হবে।</p>
    </article>

</section>
</my:layout>
