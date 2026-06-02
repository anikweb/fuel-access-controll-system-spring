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
<body class="h-screen flex flex-col overflow-hidden bg-[#f6f6ef] text-gray-700 antialiased">

<header class="h-16 bg-white border-b border-gray-200 flex items-center px-4 sm:px-6 lg:px-8 shrink-0 z-50">
    <button type="button" id="sidebarToggle"
            class="md:hidden inline-flex items-center justify-center w-10 h-10 -ml-2 mr-1 rounded-md text-gray-600 hover:bg-gray-100 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30"
            aria-label="মেনু খুলুন" aria-controls="sidebarPanel" aria-expanded="false">
        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none"
             stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <line x1="4" y1="6" x2="20" y2="6"/>
            <line x1="4" y1="12" x2="20" y2="12"/>
            <line x1="4" y1="18" x2="20" y2="18"/>
        </svg>
    </button>
    <a href="<c:url value='/'/>" class="inline-flex items-center" aria-label="FACS">
        <img src="<c:url value='/img/facs.png'/>" alt="FACS System" class="h-8 sm:h-9">
    </a>
    <div class="ml-auto">
        <form action="<c:url value='/logout'/>" method="post" class="inline-block">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>
            <button type="submit"
                    class="inline-flex items-center gap-2 rounded-md bg-brand-red text-white px-3 sm:px-4 py-2 text-sm font-semibold hover:bg-brand-red-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-red/40">
                <my:icon name="logout"/>
                <span class="hidden sm:inline">লগআউট</span>
            </button>
        </form>
    </div>
</header>

<div class="flex flex-1 min-h-0 relative">

    <div id="sidebarBackdrop"
         class="hidden md:hidden fixed inset-x-0 bottom-0 top-16 bg-black/40 z-30"
         aria-hidden="true"></div>

    <aside id="sidebarPanel"
           class="fixed top-16 bottom-0 left-0 w-72 z-40 bg-white border-r border-gray-200 flex flex-col shrink-0 overflow-hidden
                  transform -translate-x-full transition-transform duration-200 ease-out
                  md:static md:top-auto md:bottom-auto md:translate-x-0 md:transition-none md:w-64 lg:w-72">
        <nav class="flex-1 min-h-0 overflow-y-auto px-4 py-5 flex flex-col gap-3">
            <jsp:invoke fragment="sidebar"/>
        </nav>
        <c:if test="${not empty sidebarFooter}">
            <div class="shrink-0 px-4 py-4 border-t border-gray-100 flex flex-col gap-1">
                <jsp:invoke fragment="sidebarFooter"/>
            </div>
        </c:if>
    </aside>

    <div class="flex-1 flex flex-col min-w-0 min-h-0">
        <main class="flex-1 min-h-0 overflow-y-auto px-4 sm:px-6 lg:px-8 py-5 sm:py-6 lg:py-8">
            <jsp:doBody/>
        </main>
        <footer class="shrink-0 px-4 sm:px-6 lg:px-8 py-4 text-center text-xs text-gray-500 border-t border-gray-200/70 bg-white">
            © ২০২৬ ফুয়েল এক্সেস কন্ট্রোল সিস্টেম - সর্বস্বত্ব সংরক্ষিত।
        </footer>
    </div>
</div>

<script>
    (function () {
        var btn = document.getElementById('sidebarToggle');
        var panel = document.getElementById('sidebarPanel');
        var backdrop = document.getElementById('sidebarBackdrop');
        if (!btn || !panel || !backdrop) return;

        function open() {
            panel.classList.remove('-translate-x-full');
            backdrop.classList.remove('hidden');
            btn.setAttribute('aria-expanded', 'true');
        }
        function close() {
            panel.classList.add('-translate-x-full');
            backdrop.classList.add('hidden');
            btn.setAttribute('aria-expanded', 'false');
        }
        btn.addEventListener('click', function () {
            if (panel.classList.contains('-translate-x-full')) open(); else close();
        });
        backdrop.addEventListener('click', close);
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') close();
        });
        // Close drawer if user navigates inside it on mobile.
        panel.addEventListener('click', function (e) {
            if (window.innerWidth >= 768) return;
            var link = e.target.closest('a');
            if (link) close();
        });
    })();
</script>

</body>
</html>
