<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ attribute name="align" required="false" %>
<%@ attribute name="width" required="false" %>
<%@ attribute name="tone" required="false" %>
<%@ attribute name="bold" required="false" type="java.lang.Boolean" %>
<%@ attribute name="mono" required="false" type="java.lang.Boolean" %>
<%@ attribute name="nowrap" required="false" type="java.lang.Boolean" %>

<c:set var="alignClass" value="${align eq 'center' ? 'text-center' : (align eq 'right' ? 'text-right' : 'text-left')}"/>
<c:set var="toneClass" value="${tone eq 'brand' ? 'text-brand' : (tone eq 'muted' ? 'text-gray-700' : 'text-gray-800')}"/>
<c:set var="weightClass" value="${bold ? 'font-medium' : ''}"/>
<c:set var="monoClass" value="${mono ? 'tabular-nums' : ''}"/>
<c:set var="wrapClass" value="${nowrap ? 'whitespace-nowrap' : ''}"/>

<td class="px-6 py-6 ${alignClass} ${toneClass} ${weightClass} ${monoClass} ${wrapClass} ${empty width ? '' : width}">
    <jsp:doBody/>
</td>
