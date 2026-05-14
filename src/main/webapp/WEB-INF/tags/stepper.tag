<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="items" required="true" type="java.util.List" %>
<%@ attribute name="currentIndex" required="true" type="java.lang.Integer" %>

<nav aria-label="Progress" class="mb-8">
    <ol class="flex items-start">
        <c:forEach items="${items}" var="label" varStatus="status">
            <c:set var="isDone" value="${status.index < currentIndex}"/>
            <c:set var="isCurrent" value="${status.index == currentIndex}"/>
            <li class="flex flex-col items-center min-w-0">
                <span class="flex items-center justify-center w-10 h-10 rounded-lg text-sm font-semibold transition [&>svg]:w-4 [&>svg]:h-4 ${isDone or isCurrent ? 'bg-brand text-white' : 'bg-gray-200 text-gray-500'}">
                    <c:choose>
                        <c:when test="${isDone}"><my:icon name="check"/></c:when>
                        <c:otherwise><span>${status.count}</span></c:otherwise>
                    </c:choose>
                </span>
                <span class="mt-2 text-xs text-center max-w-[96px] ${isCurrent ? 'text-gray-900 font-medium' : 'text-gray-500'}">${label}</span>
            </li>
            <c:if test="${not status.last}">
                <li class="flex-1 h-px mt-5 mx-2 sm:mx-3 ${status.index < currentIndex ? 'bg-brand' : 'bg-gray-300'}" aria-hidden="true"></li>
            </c:if>
        </c:forEach>
    </ol>
</nav>
