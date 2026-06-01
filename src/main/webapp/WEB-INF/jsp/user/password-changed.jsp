<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="পাসওয়ার্ড পরিবর্তিত হয়েছে | FACS">
<section id="password-changed" class="w-full max-w-md mx-auto">
    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-8 sm:px-10 sm:py-11 text-center"
             aria-labelledby="password-changed-title">

        <div class="flex justify-center mb-6">
            <span class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-brand/10 text-brand shadow-[0_4px_12px_rgba(13,58,46,0.12)]" aria-hidden="true">
                <span class="inline-flex items-center justify-center w-11 h-11 rounded-full bg-brand text-white">
                    <my:icon name="check"/>
                </span>
            </span>
        </div>

        <h1 id="password-changed-title" class="text-[22px] font-bold text-gray-900 tracking-tight mb-3">
            পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে
        </h1>
        <p class="text-sm text-gray-500 leading-6 mb-7">
            আপনার অ্যাকাউন্টের নিরাপত্তা আপডেট করা হয়েছে। আপনার পরবর্তী লগইনের জন্য নতুন পাসওয়ার্ডটি ব্যবহার করুন। আপনার বর্তমান সেশনটি সুরক্ষিত রাখা হয়েছে।
        </p>

        <div class="flex flex-col sm:flex-row gap-3 justify-center">
            <div class="sm:w-44">
                <my:button label="ড্যাশবোর্ড-এ ফিরে যান" href="${dashboardUrl}" variant="primary"/>
            </div>
            <div class="sm:w-40">
                <button type="button"
                        onclick="document.getElementById('logout-confirm').showModal();"
                        class="inline-flex w-full items-center justify-center gap-2 rounded-lg px-4 py-3 text-sm font-semibold transition active:translate-y-px focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-1 focus-visible:ring-brand/40 bg-white text-gray-900 border border-gray-300 hover:bg-gray-50 hover:border-gray-400">
                    <span>লগ আউট করুন</span>
                </button>
            </div>
        </div>

        <div class="mt-8 pt-5 border-t border-gray-200 flex flex-col sm:flex-row items-center justify-center gap-x-6 gap-y-1.5 text-xs text-gray-500 font-mono">
            <span class="inline-flex items-center gap-1.5">
                <span class="text-gray-400"><my:icon name="clock"/></span>
                <span>TIME: ${changedAt}</span>
            </span>
            <span class="inline-flex items-center gap-1.5">
                <span class="text-gray-400"><my:icon name="target"/></span>
                <span>IP: ${changedIp}</span>
            </span>
        </div>
    </article>

    <dialog id="logout-confirm"
            class="w-full max-w-sm rounded-xl border border-gray-200 bg-white p-0 shadow-[0_10px_40px_rgba(16,24,40,0.18)] backdrop:bg-gray-900/50 open:animate-[fadeIn_120ms_ease-out]"
            aria-labelledby="logout-confirm-title">
        <div class="p-6 sm:p-7">
            <div class="flex items-start gap-4">
                <span class="inline-flex items-center justify-center w-11 h-11 rounded-full bg-amber-50 text-amber-600 shrink-0" aria-hidden="true">
                    <my:icon name="logout"/>
                </span>
                <div class="flex-1 min-w-0 text-left">
                    <h2 id="logout-confirm-title" class="text-base font-bold text-gray-900 mb-1">লগ আউট নিশ্চিত করুন</h2>
                    <p class="text-sm text-gray-500 leading-6">আপনি কি সত্যিই লগ আউট করতে চান? পরের বার ব্যবহার করতে আবার সাইন ইন করতে হবে।</p>
                </div>
            </div>

            <form action="<c:url value='/logout'/>" method="post"
                  class="mt-6 flex flex-col-reverse sm:flex-row sm:justify-end gap-2.5">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>
                <button type="button"
                        onclick="document.getElementById('logout-confirm').close();"
                        class="inline-flex w-full sm:w-auto items-center justify-center rounded-lg px-4 py-2.5 text-sm font-semibold bg-white text-gray-900 border border-gray-300 hover:bg-gray-50 hover:border-gray-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/40">
                    বাতিল করুন
                </button>
                <button type="submit"
                        class="inline-flex w-full sm:w-auto items-center justify-center gap-2 rounded-lg px-4 py-2.5 text-sm font-semibold bg-red-600 text-white border border-red-600 hover:bg-red-700 hover:border-red-700 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-red-500/40">
                    <my:icon name="logout"/>
                    <span>হ্যাঁ, লগ আউট করুন</span>
                </button>
            </form>
        </div>
    </dialog>
</section>

<script>
    (function () {
        'use strict';
        var dlg = document.getElementById('logout-confirm');
        if (!dlg) return;
        dlg.addEventListener('click', function (e) {
            var r = dlg.getBoundingClientRect();
            var inside = e.clientX >= r.left && e.clientX <= r.right &&
                         e.clientY >= r.top  && e.clientY <= r.bottom;
            if (!inside) dlg.close();
        });
    })();
</script>
</my:layout>
