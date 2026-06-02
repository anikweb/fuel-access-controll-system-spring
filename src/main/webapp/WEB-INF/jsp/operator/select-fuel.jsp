<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="জ্বালানি প্রদান | FACS">

    <jsp:attribute name="sidebar">
        <article class="bg-white border border-gray-200 rounded-2xl p-6 flex flex-col items-center text-center shadow-sm">
            <div class="w-24 h-24 rounded-full overflow-hidden bg-gray-100 ring-2 ring-brand ring-offset-2 ring-offset-white">
                <c:choose>
                    <c:when test="${not empty operator.photoUrl}">
                        <img src="<c:out value='${operator.photoUrl}'/>" alt="" class="w-full h-full object-cover"/>
                    </c:when>
                    <c:otherwise>
                        <img src="<c:url value='/img/avatar-placeholder.svg'/>" alt="" class="w-full h-full object-cover"/>
                    </c:otherwise>
                </c:choose>
            </div>
            <h2 class="mt-4 text-[18px] font-bold text-gray-900 leading-tight"><c:out value="${operator.name}"/></h2>
            <p class="mt-1.5 text-sm text-gray-500">অপারেটর আইডি: ${operator.displayId}</p>
        </article>

        <c:if test="${not empty station}">
            <article class="bg-white border border-gray-200 rounded-2xl p-6 shadow-sm">
                <p class="text-[13px] font-semibold text-gray-500">স্টেশন</p>
                <p class="mt-3 text-[15px] font-semibold text-gray-900 leading-snug"><c:out value="${station.name}"/></p>
                <p class="mt-1 text-sm text-gray-500 leading-snug"><c:out value="${station.location}"/></p>
            </article>
        </c:if>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <form action="<c:url value='/operator/transactions/dispense'/>" method="post"
              class="w-full flex flex-col gap-6" id="dispenseForm">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>
            <input type="hidden" name="vehicleId" value="${ctx.vehicleId}"/>

            <header class="flex items-start justify-between gap-4 flex-wrap">
                <div>
                    <h1 class="text-[26px] sm:text-[28px] font-bold text-brand tracking-tight leading-snug">জ্বালানি প্রদান</h1>
                    <p class="mt-2 text-sm text-gray-500">যানবাহনের জন্য জ্বালানির ধরন এবং পরিমাণ নির্বাচন করুন।</p>
                </div>
                <span class="inline-flex items-center gap-2 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-700 px-4 py-2.5 text-sm font-semibold shadow-sm">
                    <my:icon name="checkCircle"/>
                    <span>যাচাইকৃত</span>
                </span>
            </header>

            <article class="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">

                <div class="px-6 py-5 border-b border-gray-100 bg-gray-50 flex items-center gap-4 flex-wrap">
                    <div class="w-12 h-12 rounded-full overflow-hidden bg-white ring-2 ring-brand/30 ring-offset-2 ring-offset-gray-50 shrink-0">
                        <c:choose>
                            <c:when test="${not empty ctx.ownerPhotoUrl}">
                                <img src="<c:out value='${ctx.ownerPhotoUrl}'/>" alt="" class="w-full h-full object-cover"/>
                            </c:when>
                            <c:otherwise>
                                <img src="<c:url value='/img/avatar-placeholder.svg'/>" alt="" class="w-full h-full object-cover"/>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="min-w-0 flex-1">
                        <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">মালিক</p>
                        <p class="mt-0.5 text-[15px] font-semibold text-gray-900 leading-tight truncate"><c:out value="${ctx.ownerName}"/></p>
                    </div>
                    <div class="min-w-0">
                        <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">প্লেট নম্বর</p>
                        <p class="mt-0.5 text-[15px] font-bold text-brand tracking-wide"><c:out value="${ctx.plateDisplay}"/></p>
                    </div>
                </div>

                <header class="bg-brand text-white px-6 py-4 flex items-center gap-2">
                    <my:icon name="fuelPump"/>
                    <h2 class="text-[16px] font-bold">জ্বালানি বিতরণ</h2>
                </header>

                <div class="px-6 py-6 grid grid-cols-1 lg:grid-cols-2 gap-x-8 gap-y-8">

                    <section>
                        <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">জ্বালানির ধরন</p>

                        <div class="mt-3 flex flex-col gap-2.5" id="fuelTypeGroup">
                            <c:set var="fuelOptions" value="petrol,octane,diesel"/>
                            <c:forTokens items="${fuelOptions}" delims="," var="opt">
                                <c:set var="isSelected" value="${opt eq ctx.defaultFuelType}"/>
                                <c:set var="optLabel" value=""/>
                                <c:choose>
                                    <c:when test="${opt eq 'petrol'}"><c:set var="optLabel" value="পেট্রোল"/></c:when>
                                    <c:when test="${opt eq 'octane'}"><c:set var="optLabel" value="অকটেন"/></c:when>
                                    <c:when test="${opt eq 'diesel'}"><c:set var="optLabel" value="ডিজেল"/></c:when>
                                </c:choose>
                                <label data-fuel-card data-selected="${isSelected ? 'true' : 'false'}"
                                       class="group flex items-center gap-3 rounded-lg border px-4 py-3 cursor-pointer transition
                                              border-gray-200 bg-white text-gray-800 hover:border-brand/50 hover:bg-brand/5
                                              data-[selected=true]:border-brand data-[selected=true]:bg-brand data-[selected=true]:text-white data-[selected=true]:shadow-sm">
                                    <span class="inline-flex items-center justify-center w-9 h-9 rounded-md shrink-0 bg-gray-100 text-gray-500 group-data-[selected=true]:bg-white/15 group-data-[selected=true]:text-white">
                                        <my:icon name="fuelPump"/>
                                    </span>
                                    <span class="flex-1 text-[15px] font-semibold">${optLabel}</span>
                                    <span class="inline-flex items-center justify-center w-5 h-5 rounded-full border-2 border-gray-300 text-transparent group-data-[selected=true]:bg-white group-data-[selected=true]:border-white group-data-[selected=true]:text-brand">
                                        <my:icon name="check"/>
                                    </span>
                                    <input type="radio" name="fuelType" value="${opt}" class="sr-only" ${isSelected ? 'checked' : ''}/>
                                </label>
                            </c:forTokens>
                        </div>
                    </section>

                    <section>
                        <p class="text-[11px] font-semibold text-gray-500 uppercase tracking-wide">পরিমাণ (লিটার)</p>

                        <div class="mt-3 rounded-lg border border-gray-200 bg-gray-50 px-4 py-5 flex items-center justify-between gap-3">
                            <button type="button" id="litersMinus" aria-label="কমান"
                                    class="inline-flex items-center justify-center w-11 h-11 rounded-lg border border-gray-200 bg-white text-gray-700 hover:border-brand hover:text-brand transition text-2xl font-semibold shrink-0">
                                −
                            </button>
                            <div class="flex flex-col items-center flex-1">
                                <p id="litersDisplay" class="text-[40px] leading-none font-bold text-brand tabular-nums">২৫</p>
                                <p class="text-xs text-gray-500 mt-1">লিটার</p>
                            </div>
                            <button type="button" id="litersPlus" aria-label="বাড়ান"
                                    class="inline-flex items-center justify-center w-11 h-11 rounded-lg bg-brand text-white hover:bg-brand-700 transition text-2xl font-semibold shrink-0">
                                +
                            </button>
                        </div>

                        <p class="mt-5 text-[11px] font-semibold text-gray-500 uppercase tracking-wide">দ্রুত নির্বাচন</p>

                        <div class="mt-3 grid grid-cols-2 sm:grid-cols-4 gap-2" id="quickPicks">
                            <c:forTokens items="2,5,15,20" delims="," var="q">
                                <c:set var="qLabel" value=""/>
                                <c:choose>
                                    <c:when test="${q eq '2'}"><c:set var="qLabel" value="২"/></c:when>
                                    <c:when test="${q eq '5'}"><c:set var="qLabel" value="৫"/></c:when>
                                    <c:when test="${q eq '15'}"><c:set var="qLabel" value="১৫"/></c:when>
                                    <c:when test="${q eq '20'}"><c:set var="qLabel" value="২০"/></c:when>
                                </c:choose>
                                <button type="button" data-quick="${q}" data-selected="false"
                                        class="rounded-lg border px-3 py-2.5 text-sm font-semibold transition
                                               border-gray-200 bg-white text-gray-800 hover:border-brand hover:bg-brand/5
                                               data-[selected=true]:border-brand data-[selected=true]:bg-brand data-[selected=true]:text-white">
                                    ${qLabel} লিটার
                                </button>
                            </c:forTokens>
                        </div>

                        <input type="hidden" name="liters" id="litersInput" value="25"/>
                    </section>

                </div>

                <footer class="px-6 py-5 border-t border-gray-100 bg-gray-50 flex items-center justify-end gap-3 flex-wrap">
                    <a href="<c:url value='/operator/dashboard'/>"
                       class="inline-flex items-center gap-2 rounded-md border border-gray-200 bg-white text-gray-700 px-5 py-2.5 text-sm font-semibold hover:bg-gray-50 transition">
                        <my:icon name="x"/>
                        <span>বাতিল</span>
                    </a>
                    <button type="submit"
                            class="inline-flex items-center gap-2 rounded-md bg-brand text-white px-5 py-2.5 text-sm font-semibold hover:bg-brand-700 transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                        <my:icon name="fuelPump"/>
                        <span>জ্বালানি সরবরাহ করুন</span>
                    </button>
                </footer>
            </article>
        </form>

        <script>
            (function () {
                var BANGLA_DIGITS = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
                function toBangla(n) {
                    return String(n).replace(/\d/g, function (d) { return BANGLA_DIGITS[+d]; });
                }

                var display = document.getElementById('litersDisplay');
                var input = document.getElementById('litersInput');
                var minus = document.getElementById('litersMinus');
                var plus = document.getElementById('litersPlus');
                var quickButtons = document.querySelectorAll('#quickPicks [data-quick]');
                var current = parseFloat(input.value) || 25;

                function syncQuickPicks() {
                    quickButtons.forEach(function (b) {
                        b.dataset.selected = (parseInt(b.dataset.quick, 10) === current) ? 'true' : 'false';
                    });
                }
                function render() {
                    display.textContent = toBangla(current);
                    input.value = String(current);
                    syncQuickPicks();
                }
                function setValue(n) {
                    if (n < 1) n = 1;
                    if (n > 999) n = 999;
                    current = n;
                    render();
                }

                minus.addEventListener('click', function () { setValue(current - 1); });
                plus.addEventListener('click', function () { setValue(current + 1); });
                quickButtons.forEach(function (b) {
                    b.addEventListener('click', function () { setValue(parseInt(b.dataset.quick, 10)); });
                });
                syncQuickPicks();

                var cards = document.querySelectorAll('[data-fuel-card]');
                cards.forEach(function (card) {
                    card.addEventListener('click', function () {
                        cards.forEach(function (c) {
                            c.dataset.selected = 'false';
                            var radio = c.querySelector('input[type="radio"]');
                            if (radio) radio.checked = false;
                        });
                        card.dataset.selected = 'true';
                        var radio = card.querySelector('input[type="radio"]');
                        if (radio) radio.checked = true;
                    });
                });
            })();
        </script>
    </jsp:body>

</my:panelLayout>
