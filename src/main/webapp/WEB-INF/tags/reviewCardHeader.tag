<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="icon" required="true" %>
<%@ attribute name="title" required="true" %>
<%@ attribute name="editHref" required="false" %>

<header class="flex items-center justify-between">
    <h2 class="flex items-center gap-2 text-base font-semibold text-gray-900">
        <span class="text-gray-700 [&>svg]:w-5 [&>svg]:h-5"><my:icon name="${icon}"/></span>
        <span>${title}</span>
    </h2>
    <c:if test="${not empty editHref}">
        <a href="${editHref}" class="inline-flex items-center gap-1 text-sm font-medium text-brand hover:underline">
            <span class="[&>svg]:w-4 [&>svg]:h-4"><my:icon name="pencil"/></span>
            এডিট করুন
        </a>
    </c:if>
</header>
<hr class="my-4 border-0 border-t border-gray-200"/>
