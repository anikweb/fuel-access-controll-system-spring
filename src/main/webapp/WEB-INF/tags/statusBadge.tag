<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="variant" required="false" %>

<c:choose>
    <c:when test="${variant eq 'pending'}">
        <c:set var="klass" value="bg-amber-400 text-amber-950"/>
    </c:when>
    <c:when test="${variant eq 'cancelled' or variant eq 'danger'}">
        <c:set var="klass" value="bg-brand-red text-white"/>
    </c:when>
    <c:when test="${variant eq 'neutral'}">
        <c:set var="klass" value="bg-gray-200 text-gray-800"/>
    </c:when>
    <c:otherwise>
        <c:set var="klass" value="bg-brand text-white"/>
    </c:otherwise>
</c:choose>

<span class="inline-flex items-center justify-center rounded-full px-3.5 py-1 text-xs font-semibold ${klass}">${label}</span>
