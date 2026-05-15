<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="title" required="true" %>
<%@ attribute name="subtitle" required="false" %>
<%@ attribute name="sectionTitle" required="false" %>
<%@ attribute name="action" required="true" %>
<%@ attribute name="method" required="false" %>
<%@ attribute name="cancelHref" required="true" %>
<%@ attribute name="cancelLabel" required="false" %>
<%@ attribute name="submitLabel" required="false" %>
<%@ attribute name="multipart" required="false" type="java.lang.Boolean" %>

<section class="flex flex-col gap-6">

    <header>
        <h1 class="text-[34px] sm:text-[38px] font-bold text-brand tracking-tight leading-snug">${title}</h1>
        <c:if test="${not empty subtitle}">
            <p class="mt-2 text-sm text-gray-500">${subtitle}</p>
        </c:if>
    </header>

    <form action="<c:url value='${action}'/>" method="${empty method ? 'post' : method}" novalidate
          <c:if test="${multipart}">enctype="multipart/form-data" </c:if>class="bg-white border border-gray-200 rounded-xl overflow-hidden">
        <c:if test="${not empty _csrf}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
        </c:if>

        <div class="p-6 sm:p-8 flex flex-col gap-6">
            <c:if test="${not empty sectionTitle}">
                <h2 class="text-base font-semibold text-brand pt-2 pb-6 border-b border-gray-200">${sectionTitle}</h2>
            </c:if>

            <jsp:doBody/>
        </div>

        <footer class="flex justify-end gap-3 px-6 py-4 border-t border-gray-100 bg-white">
            <div class="w-40">
                <my:button label="${empty cancelLabel ? 'বাতিল করুন' : cancelLabel}" href="${cancelHref}" variant="secondary"/>
            </div>
            <div class="w-44">
                <my:button label="${empty submitLabel ? 'সংরক্ষণ করুন' : submitLabel}" type="submit"/>
            </div>
        </footer>
    </form>

</section>
