<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="placeholder" required="false" %>
<%@ attribute name="value" required="false" %>
<%@ attribute name="rows" required="false" %>
<%@ attribute name="required" required="false" %>

<div class="flex flex-col">
    <label for="${id}" class="mb-1.5 text-[13px] font-medium text-gray-700">${label}</label>
    <textarea id="${id}" name="${name}"
              placeholder="${placeholder}"
              rows="${empty rows ? 3 : rows}"
              <c:if test="${required eq 'true' or required eq true}">required</c:if>
              class="rounded-lg border border-gray-200 bg-gray-50 px-3.5 py-3 text-sm text-gray-900 placeholder-gray-400 focus:outline-none focus:border-brand focus:bg-white focus:ring-2 focus:ring-brand/15 resize-y">${value}</textarea>
</div>
