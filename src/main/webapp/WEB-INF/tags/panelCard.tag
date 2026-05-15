<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="title" required="false" %>
<%@ attribute name="actionLabel" required="false" %>
<%@ attribute name="actionHref" required="false" %>

<section class="bg-white border border-gray-200 rounded-xl overflow-hidden">
    <c:if test="${not empty title}">
        <header class="flex items-center justify-between gap-4 px-6 py-4 border-b border-gray-100">
            <h2 class="text-[18px] font-bold text-brand tracking-tight">${title}</h2>
            <c:if test="${not empty actionHref}">
                <a href="<c:url value='${actionHref}'/>"
                   class="inline-flex items-center gap-1.5 text-sm font-semibold text-brand hover:underline">
                    <span>${empty actionLabel ? 'সবগুলো দেখুন' : actionLabel}</span>
                    <my:icon name="chevronRight"/>
                </a>
            </c:if>
        </header>
    </c:if>
    <div>
        <jsp:doBody/>
    </div>
</section>
