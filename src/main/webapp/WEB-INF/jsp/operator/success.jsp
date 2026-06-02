<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="bn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>সফল | FACS</title>
    <link rel="stylesheet" href="<c:url value='/css/app.css'/>">
</head>
<body class="min-h-screen flex flex-col bg-[#f6f6ef] text-gray-700 antialiased">

<main class="flex-1 flex items-center justify-center px-6 py-12">
    <section class="w-full max-w-xl flex flex-col items-center gap-6">

        <span class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-emerald-100 text-emerald-700 shadow-sm [&>svg]:w-9 [&>svg]:h-9">
            <my:icon name="check"/>
        </span>

        <header class="text-center">
            <h1 class="text-[22px] sm:text-[24px] font-bold text-brand tracking-tight">জ্বালানি সফলভাবে প্রদান করা হয়েছে</h1>
            <p class="mt-2 text-sm text-gray-500">সিস্টেম অডিট লগ সফলভাবে আপডেট করা হয়েছে এবং লেনদেনটি সুরক্ষিত।</p>
        </header>

        <article class="w-full bg-white border border-gray-200 rounded-xl shadow-sm">
            <div class="px-6 py-6 flex flex-col items-center text-center border-b border-gray-100">
                <span class="inline-flex items-center justify-center w-11 h-11 rounded-md bg-brand/5 text-brand">
                    <my:icon name="fuelPump"/>
                </span>
                <p class="mt-3 text-[11px] font-semibold text-gray-500 uppercase tracking-[0.18em]">প্রদানকৃত পরিমাণ</p>
                <p class="mt-1 text-[32px] sm:text-[36px] leading-none font-bold text-brand"><c:out value="${view.litersDisplay}"/></p>
            </div>

            <div class="px-6 py-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div class="rounded-lg bg-gray-50 px-4 py-3 flex items-center gap-3">
                    <span class="inline-flex items-center justify-center w-10 h-10 rounded-md bg-white border border-gray-200 text-brand">
                        <my:icon name="fuelPump"/>
                    </span>
                    <div>
                        <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">জ্বালানির গ্রেড</p>
                        <p class="mt-0.5 text-[14px] font-semibold text-gray-900"><c:out value="${view.fuelTypeLabel}"/></p>
                    </div>
                </div>
                <div class="rounded-lg bg-gray-50 px-4 py-3 flex items-center gap-3">
                    <span class="inline-flex items-center justify-center w-10 h-10 rounded-md bg-white border border-gray-200 text-brand">
                        <my:icon name="truck"/>
                    </span>
                    <div>
                        <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">যানবাহন আইডি</p>
                        <p class="mt-0.5 text-[14px] font-semibold text-gray-900"><c:out value="${view.plateDisplay}"/></p>
                    </div>
                </div>
            </div>
        </article>

        <div class="w-full pt-2">
            <a href="<c:url value='/operator/dashboard'/>"
               class="w-full inline-flex items-center justify-center gap-2 rounded-md bg-brand text-white px-5 py-3 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                <span>ড্যাশবোর্ডে ফিরে যান</span>
            </a>
        </div>

    </section>
</main>

<footer class="px-6 sm:px-8 py-4 text-center text-xs text-gray-500 border-t border-gray-200/70 bg-white">
    © ২০২৬ ফুয়েল এক্সেস কন্ট্রোল সিস্টেম - সর্বস্বত্ব সংরক্ষিত
</footer>

</body>
</html>
