<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="header" required="true" fragment="true" %>
<%@ attribute name="title" required="false" %>
<%@ attribute name="actionHref" required="false" %>
<%@ attribute name="actionLabel" required="false" %>
<%@ attribute name="isEmpty" required="false" type="java.lang.Boolean" %>
<%@ attribute name="emptyMessage" required="false" %>
<%@ attribute name="colspan" required="false" type="java.lang.Integer" %>
<%@ attribute name="itemLabel" required="false" %>
<%@ attribute name="fromIdx" required="false" %>
<%@ attribute name="toIdx" required="false" %>
<%@ attribute name="total" required="false" %>
<%@ attribute name="currentPage" required="false" type="java.lang.Integer" %>
<%@ attribute name="hasPrev" required="false" type="java.lang.Boolean" %>
<%@ attribute name="hasNext" required="false" type="java.lang.Boolean" %>
<%@ attribute name="pageUrl" required="false" %>
<%@ attribute name="paginated" required="false" type="java.lang.Boolean" %>

<c:set var="showPagination" value="${paginated == null ? true : paginated}"/>
<c:set var="emptyColspan" value="${colspan == null ? 1 : colspan}"/>

<section class="bg-white border border-gray-200 rounded-xl overflow-hidden">
    <c:if test="${not empty title}">
        <header class="flex items-center justify-between gap-4 px-6 py-4 border-b border-gray-100">
            <h2 class="text-[18px] font-bold text-brand tracking-tight">${title}</h2>
            <c:if test="${not empty actionHref}">
                <a href="<c:url value='${actionHref}'/>"
                   class="inline-flex items-center gap-1.5 text-sm font-semibold text-brand hover:underline">
                    <span>${empty actionLabel ? 'সবগুলো দেখুন' : actionLabel}</span>
                    <my:icon name="chevronRight"/>
                </a>
            </c:if>
        </header>
    </c:if>
    <div class="md:overflow-x-auto">
        <table class="responsive-table w-full text-sm">
            <thead class="bg-gray-200 text-gray-700">
                <tr class="text-left text-sm font-medium">
                    <jsp:invoke fragment="header"/>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-100">
                <c:choose>
                    <c:when test="${isEmpty}">
                        <tr class="responsive-table-empty">
                            <td colspan="${emptyColspan}" class="px-6 py-12 text-center text-sm text-gray-500">
                                ${empty emptyMessage ? 'কোনো তথ্য পাওয়া যায়নি।' : emptyMessage}
                            </td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <jsp:doBody/>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <c:if test="${showPagination}">
        <footer class="flex items-center justify-between gap-3 px-6 py-5 bg-gray-50 border-t border-gray-100 text-sm text-gray-600">
            <span>
                ${fromIdx} - ${toIdx} এর মধ্যে ${total}টি ${itemLabel} দেখাচ্ছে
            </span>
            <div class="flex items-center gap-2">
                <c:choose>
                    <c:when test="${hasPrev}">
                        <a href="<c:url value='${pageUrl}'><c:param name='page' value='${currentPage - 1}'/></c:url>"
                           class="inline-flex items-center justify-center w-10 h-10 rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30"
                           aria-label="পূর্ববর্তী">
                            <my:icon name="chevronLeft"/>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="inline-flex items-center justify-center w-10 h-10 rounded-md border border-gray-200 text-gray-300 cursor-not-allowed" aria-disabled="true">
                            <my:icon name="chevronLeft"/>
                        </span>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${hasNext}">
                        <a href="<c:url value='${pageUrl}'><c:param name='page' value='${currentPage + 1}'/></c:url>"
                           class="inline-flex items-center justify-center w-10 h-10 rounded-md border border-gray-200 text-gray-500 hover:bg-gray-50 hover:border-gray-300 hover:text-gray-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30"
                           aria-label="পরবর্তী">
                            <my:icon name="chevronRight"/>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="inline-flex items-center justify-center w-10 h-10 rounded-md border border-gray-200 text-gray-300 cursor-not-allowed" aria-disabled="true">
                            <my:icon name="chevronRight"/>
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>
        </footer>
    </c:if>
</section>
