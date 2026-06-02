<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="title" required="false" %>
<!DOCTYPE html>
<html lang="bn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${empty title ? 'FACS System' : title}</title>
    <link rel="stylesheet" href="<c:url value='/css/app.css'/>">
</head>
<body class="min-h-screen flex flex-col bg-gray-100 text-gray-700 antialiased">

<header class="sticky top-0 z-20 h-16 bg-white border-b border-gray-200 flex items-center px-8">
    <div class="w-full max-w-7xl mx-auto flex items-center justify-between">
        <a href="<c:url value='/'/>" class="inline-flex items-center" aria-label="FACS">
            <img src="<c:url value='/img/facs.png'/>" alt="FACS System" class="h-10">
        </a>
    </div>
</header>

<main class="flex-1 flex items-start sm:items-center justify-center px-6 py-12">
    <div class="w-full">
        <jsp:doBody/>
    </div>
</main>

<footer class="border-t border-gray-200 bg-white text-gray-500 text-sm flex items-center justify-center px-6 py-4 text-center">
    <small>© ২০২৬ ফুয়েল এক্সেস কন্ট্রোল সিস্টেম - সর্বস্বত্ব সংরক্ষিত</small>
</footer>

<my:imagePickerModal/>

</body>
</html>
