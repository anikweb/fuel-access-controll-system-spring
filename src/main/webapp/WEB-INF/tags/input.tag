<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="type" required="false" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="placeholder" required="false" %>
<%@ attribute name="leadingIcon" required="false" %>
<%@ attribute name="trailingIcon" required="false" %>
<%@ attribute name="passwordToggle" required="false" %>
<%@ attribute name="actionLabel" required="false" %>
<%@ attribute name="actionHref" required="false" %>
<%@ attribute name="autocomplete" required="false" %>
<%@ attribute name="required" required="false" %>
<%@ attribute name="value" required="false" %>
<%@ attribute name="error" required="false" %>

<c:set var="isRequired" value="${required eq 'true' or required eq true}"/>
<div class="flex flex-col">
    <div class="mb-1.5 flex items-baseline justify-between">
        <label for="${id}" class="text-[13px] font-medium text-gray-700">
            ${label}<c:if test="${isRequired}"> <span class="text-red-600">*</span></c:if>
        </label>
        <c:if test="${not empty actionHref}">
            <a href="${actionHref}" class="text-xs font-medium text-brand hover:underline">${actionLabel}</a>
        </c:if>
    </div>

    <div class="group flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15 ${not empty error ? 'border-red-300 bg-red-50 focus-within:border-red-400 focus-within:ring-red-200' : ''}">
        <c:if test="${not empty leadingIcon}">
            <span class="pl-3 flex items-center text-gray-400"><my:icon name="${leadingIcon}"/></span>
        </c:if>
        <input class="flex-1 w-full bg-transparent border-0 px-3.5 py-3 text-sm text-gray-900 placeholder-gray-400 focus:outline-none"
               id="${id}"
               name="${name}"
               type="${empty type ? 'text' : type}"
               placeholder="${placeholder}"
               autocomplete="${autocomplete}"
               value="${value}"
               <c:if test="${isRequired}">required</c:if>/>
        <c:if test="${not empty trailingIcon and not (passwordToggle eq 'true' or passwordToggle eq true)}">
            <span class="pr-3 flex items-center text-gray-400"><my:icon name="${trailingIcon}"/></span>
        </c:if>
        <c:if test="${passwordToggle eq 'true' or passwordToggle eq true}">
            <button type="button"
                    class="mr-1 p-1.5 rounded-md text-gray-400 hover:text-gray-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40"
                    data-target="${id}"
                    aria-label="Toggle password visibility">
                <span><my:icon name="eye"/></span>
            </button>
        </c:if>
    </div>

    <c:if test="${not empty error}">
        <p class="mt-1 text-xs text-red-600">${error}</p>
    </c:if>
</div>
