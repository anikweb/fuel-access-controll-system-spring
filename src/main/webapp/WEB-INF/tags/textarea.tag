<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="placeholder" required="false" %>
<%@ attribute name="value" required="false" %>
<%@ attribute name="rows" required="false" %>
<%@ attribute name="required" required="false" %>
<%@ attribute name="leadingIcon" required="false" %>
<%@ attribute name="error" required="false" %>

<c:set var="isRequired" value="${required eq 'true' or required eq true}"/>
<c:set var="hasIcon" value="${not empty leadingIcon}"/>

<div class="flex flex-col">
    <label for="${id}" class="mb-1.5 text-[13px] font-medium text-gray-700">
        ${label}<c:if test="${isRequired}"> <span class="text-red-600">*</span></c:if>
    </label>

    <div class="relative rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15 ${not empty error ? 'border-red-300 bg-red-50 focus-within:border-red-400 focus-within:ring-red-200' : ''}">
        <c:if test="${hasIcon}">
            <span class="absolute text-gray-400 pointer-events-none" style="top: 14px; left: 14px;"><my:icon name="${leadingIcon}"/></span>
        </c:if>
        <textarea id="${id}" name="${name}"
                  placeholder="${placeholder}"
                  rows="${empty rows ? 3 : rows}"
                  <c:if test="${isRequired}">required </c:if><c:if test="${hasIcon}">style="padding-left: 42px;" </c:if>class="block w-full bg-transparent border-0 px-3.5 py-3 text-sm text-gray-900 placeholder-gray-400 focus:outline-none resize-y">${value}</textarea>
    </div>

    <c:if test="${not empty error}">
        <p class="mt-1 text-xs text-red-600">${error}</p>
    </c:if>
</div>
