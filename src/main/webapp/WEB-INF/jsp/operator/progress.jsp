<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<!DOCTYPE html>
<html lang="bn">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>জ্বালানি প্রদান চলছে | FACS</title>
    <link rel="stylesheet" href="<c:url value='/css/app.css'/>">
</head>
<body class="min-h-screen flex flex-col bg-[#f6f6ef] text-gray-700 antialiased">

<main class="flex-1 flex items-center justify-center px-6 py-12">
    <section class="w-full max-w-2xl flex flex-col items-center gap-8">

        <div class="relative">
            <div class="w-64 h-64 sm:w-72 sm:h-72 rounded-full border-[10px] border-brand flex items-center justify-center bg-white shadow-[0_8px_30px_rgba(13,58,46,0.18)]">
                <div class="flex flex-col items-center">
                    <p id="counter" class="text-[56px] sm:text-[64px] leading-none font-bold text-brand tabular-nums">০.০</p>
                    <p class="mt-2 text-sm font-semibold text-gray-600">লিটার</p>
                    <p class="mt-2 text-[11px] font-bold text-gray-500 tracking-[0.18em]">প্রদানকৃত</p>
                </div>
            </div>
            <span class="absolute -inset-2 rounded-full border-[10px] border-brand/15 animate-ping" aria-hidden="true"></span>
        </div>

        <p class="text-[15px] font-semibold text-gray-700 flex items-center gap-2">
            <span class="inline-block w-2 h-2 rounded-full bg-brand animate-pulse"></span>
            <span>জ্বালানি সরবরাহ চলছে…</span>
        </p>

        <div class="w-full grid grid-cols-1 sm:grid-cols-2 gap-4">
            <article class="bg-white border border-gray-200 rounded-xl px-5 py-4 shadow-sm flex items-center gap-3">
                <span class="inline-flex items-center justify-center w-11 h-11 rounded-md bg-gray-100 text-gray-500 shrink-0">
                    <my:icon name="truck"/>
                </span>
                <div>
                    <p class="text-[11px] font-semibold text-gray-500 tracking-wide">প্লেট নম্বর</p>
                    <p class="mt-0.5 text-[15px] font-semibold text-gray-900"><c:out value="${view.plateDisplay}"/></p>
                </div>
            </article>

            <article class="bg-white border border-gray-200 rounded-xl px-5 py-4 shadow-sm flex items-center gap-3">
                <span class="inline-flex items-center justify-center w-11 h-11 rounded-md bg-brand/5 text-brand shrink-0">
                    <my:icon name="fuelPump"/>
                </span>
                <div>
                    <p class="text-[11px] font-semibold text-gray-500 tracking-wide">জ্বালানির ধরন</p>
                    <p class="mt-0.5 text-[15px] font-semibold text-gray-900"><c:out value="${view.fuelTypeLabel}"/></p>
                </div>
            </article>
        </div>

        <div class="w-full rounded-lg bg-brand-red/90 border-l-4 border-brand-red text-white px-5 py-3.5 text-sm font-semibold text-center">
            নিরাপদ দূরত্ব বজায় রাখুন এবং ইঞ্জিন বন্ধ রাখুন।
        </div>

    </section>
</main>

<footer class="px-6 sm:px-8 py-4 text-center text-xs text-gray-500 border-t border-gray-200/70 bg-white">
    © ২০২৬ ফুয়েল এক্সেস কন্ট্রোল সিস্টেম - সর্বস্বত্ব সংরক্ষিত
</footer>

<script>
    (function () {
        var BANGLA = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
        function toBangla(s) {
            return String(s).replace(/\d/g, function (d) { return BANGLA[+d]; });
        }
        var target = parseFloat('${view.litersRaw}') || 0;
        var duration = 2800;
        var startTime = performance.now();
        var counter = document.getElementById('counter');

        function frame(now) {
            var p = Math.min(1, (now - startTime) / duration);
            var eased = 1 - Math.pow(1 - p, 3); // ease-out cubic
            var current = (target * eased).toFixed(1);
            counter.textContent = toBangla(current);
            if (p < 1) {
                requestAnimationFrame(frame);
            } else {
                counter.textContent = toBangla(target.toFixed(1));
            }
        }
        requestAnimationFrame(frame);

        setTimeout(function () {
            window.location.href = '<c:url value="/operator/transactions/success"/>?id=${view.id}';
        }, duration + 600);
    })();
</script>

</body>
</html>
