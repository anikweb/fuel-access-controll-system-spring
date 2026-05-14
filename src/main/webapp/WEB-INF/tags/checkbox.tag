<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="required" required="false" %>

<label class="flex items-start gap-2.5 cursor-pointer rounded-lg border border-gray-200 bg-gray-50 px-4 py-3 hover:border-gray-300 transition">
    <input type="checkbox"
           id="${id}"
           name="${name}"
           <c:if test="${required eq 'true' or required eq true}">required</c:if>
           class="mt-0.5 w-4 h-4 rounded border-gray-300 text-brand focus:ring-2 focus:ring-brand/30 cursor-pointer"/>
    <span class="text-sm text-gray-700 leading-snug">${label}</span>
</label>
