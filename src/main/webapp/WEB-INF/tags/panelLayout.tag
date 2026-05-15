<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="title" required="false" %>
<%@ attribute name="sidebar" required="true" fragment="true" %>
<%@ attribute name="sidebarFooter" required="false" fragment="true" %>
<!DOCTYPE html>
<html lang="bn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty title ? 'FACS' : title}</title>
    <link rel="stylesheet" href="<c:url value='/css/app.css'/>">
</head>
<body class="min-h-screen flex flex-col bg-[#f6f6ef] text-gray-700 antialiased">

<header class="h-16 bg-white border-b border-gray-200 flex items-center px-6 sm:px-8 shrink-0">
    <a href="<c:url value='/'/>" class="inline-flex items-center" aria-label="FACS">
        <img src="<c:url value='/img/facs.png'/>" alt="FACS System" class="h-9">
    </a>
    <div class="ml-auto">
        <form action="<c:url value='/logout'/>" method="post" class="inline-block">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>
            <button type="submit"
                    class="inline-flex items-center gap-2 rounded-md bg-brand-red text-white px-4 py-2 text-sm font-semibold hover:bg-brand-red-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-red/40">
                <my:icon name="logout"/>
                <span>লগআউট</span>
            </button>
        </form>
    </div>
</header>

<div class="flex flex-1 min-h-0">
    <aside class="w-60 sm:w-64 bg-white border-r border-gray-200 flex flex-col shrink-0">
        <nav class="flex-1 px-3 py-4 flex flex-col gap-1">
            <jsp:invoke fragment="sidebar"/>
        </nav>
        <c:if test="${not empty sidebarFooter}">
            <div class="px-3 py-4 border-t border-gray-100 flex flex-col gap-1">
                <jsp:invoke fragment="sidebarFooter"/>
            </div>
        </c:if>
    </aside>

    <div class="flex-1 flex flex-col min-w-0">
        <main class="flex-1 px-6 sm:px-8 py-6 sm:py-8">
            <jsp:doBody/>
        </main>
        <footer class="px-6 sm:px-8 py-4 text-center text-xs text-gray-500 border-t border-gray-200/70">
            © ২০২৬ ফুয়েল এক্সেস কন্ট্রোল সিস্টেম - সর্বস্বত্ব সংরক্ষিত।
        </footer>
    </div>
</div>

</body>
</html>
