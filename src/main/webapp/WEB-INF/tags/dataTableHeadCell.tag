<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="align" required="false" %>
<%@ attribute name="width" required="false" %>

<c:set var="alignClass" value="${align eq 'center' ? 'text-center' : (align eq 'right' ? 'text-right' : 'text-left')}"/>
<c:set var="justifyClass" value="${align eq 'center' ? 'justify-center' : (align eq 'right' ? 'justify-end' : '')}"/>
<th class="px-6 py-5 font-medium ${alignClass} ${empty width ? '' : width}">
    <span class="flex items-center ${justifyClass}">${label}</span>
</th>
