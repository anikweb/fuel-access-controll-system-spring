<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="href" required="true" %>
<%@ attribute name="icon" required="true" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="active" required="false" %>

<c:set var="isActive" value="${active eq 'true' or active eq true}"/>
<c:choose>
    <c:when test="${isActive}">
        <c:set var="klass" value="bg-brand text-white shadow-[0_2px_8px_rgba(13,58,46,0.18)]"/>
    </c:when>
    <c:otherwise>
        <c:set var="klass" value="text-gray-700 hover:bg-gray-100"/>
    </c:otherwise>
</c:choose>

<a href="<c:url value='${href}'/>"
   class="inline-flex items-center gap-3 rounded-lg px-3.5 py-2.5 text-sm font-semibold transition ${klass}">
    <span class="inline-flex items-center justify-center"><my:icon name="${icon}"/></span>
    <span>${label}</span>
</a>
