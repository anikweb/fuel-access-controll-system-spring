<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="value" required="true" %>
<%@ attribute name="icon" required="false" %>

<article class="bg-white border border-gray-200 rounded-xl px-6 py-5 sm:py-6 flex flex-col gap-4">
    <header class="flex items-start justify-between gap-3">
        <p class="text-sm text-gray-500">${label}</p>
        <c:if test="${not empty icon}">
            <span class="text-gray-400 shrink-0"><my:icon name="${icon}"/></span>
        </c:if>
    </header>
    <p class="text-[34px] sm:text-[38px] leading-none font-semibold text-brand">${value}</p>
</article>
