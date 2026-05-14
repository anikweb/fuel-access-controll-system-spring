<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="placeholder" required="false" %>
<%@ attribute name="required" required="false" %>
<%@ attribute name="value" required="false" %>
<%@ attribute name="error" required="false" %>
<%@ attribute name="options" type="java.util.List" required="true" %>

<div class="flex flex-col">
    <label for="${id}" class="mb-1.5 text-[13px] font-medium text-gray-700">${label}</label>

    <div class="relative flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15 ${not empty error ? 'border-red-300 bg-red-50 focus-within:border-red-400 focus-within:ring-red-200' : ''}">
        <select class="flex-1 w-full appearance-none bg-transparent border-0 px-3.5 pr-10 py-3 text-sm text-gray-900 focus:outline-none"
                id="${id}"
                name="${name}"
                <c:if test="${required eq 'true' or required eq true}">required</c:if>>
            <c:if test="${not empty placeholder}">
                <option value="" disabled ${empty value ? 'selected' : ''}>${placeholder}</option>
            </c:if>
            <c:forEach items="${options}" var="opt">
                <option value="${opt}" ${opt eq value ? 'selected' : ''}>${opt}</option>
            </c:forEach>
        </select>
        <span class="absolute right-3 pointer-events-none text-gray-400">
            <my:icon name="chevronDown"/>
        </span>
    </div>

    <c:if test="${not empty error}">
        <p class="mt-1 text-xs text-red-600">${error}</p>
    </c:if>
</div>
