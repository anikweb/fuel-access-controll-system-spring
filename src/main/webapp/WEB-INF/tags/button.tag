<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="type" required="false" %>
<%@ attribute name="variant" required="false" %>
<%@ attribute name="href" required="false" %>
<%@ attribute name="leadingIcon" required="false" %>
<%@ attribute name="trailingIcon" required="false" %>

<c:set var="base" value="inline-flex w-full items-center justify-center gap-2 rounded-lg px-4 py-3 text-sm font-semibold transition active:translate-y-px focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 focus-visible:ring-brand/40"/>
<c:choose>
    <c:when test="${variant eq 'secondary'}">
        <c:set var="variantClass" value="bg-white text-gray-900 border border-gray-300 hover:bg-gray-50 hover:border-gray-400"/>
    </c:when>
    <c:when test="${variant eq 'ghost'}">
        <c:set var="variantClass" value="bg-transparent text-brand border border-transparent hover:bg-brand/5"/>
    </c:when>
    <c:otherwise>
        <c:set var="variantClass" value="bg-brand text-white border border-brand hover:bg-brand-700 hover:border-brand-700"/>
    </c:otherwise>
</c:choose>
<c:set var="klass" value="${base} ${variantClass}"/>

<c:choose>
    <c:when test="${not empty href}">
        <a href="${href}" class="${klass}">
            <c:if test="${not empty leadingIcon}">
                <span class="inline-flex items-center"><my:icon name="${leadingIcon}"/></span>
            </c:if>
            <span>${label}</span>
            <c:if test="${not empty trailingIcon}">
                <span class="inline-flex items-center"><my:icon name="${trailingIcon}"/></span>
            </c:if>
        </a>
    </c:when>
    <c:otherwise>
        <button type="${empty type ? 'button' : type}" class="${klass}">
            <c:if test="${not empty leadingIcon}">
                <span class="inline-flex items-center"><my:icon name="${leadingIcon}"/></span>
            </c:if>
            <span>${label}</span>
            <c:if test="${not empty trailingIcon}">
                <span class="inline-flex items-center"><my:icon name="${trailingIcon}"/></span>
            </c:if>
        </button>
    </c:otherwise>
</c:choose>
