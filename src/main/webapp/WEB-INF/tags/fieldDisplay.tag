<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="value" required="false" %>

<div>
    <p class="text-xs text-gray-500 mb-1">${label}</p>
    <p class="text-sm font-semibold text-gray-900">${empty value ? '—' : value}</p>
</div>
