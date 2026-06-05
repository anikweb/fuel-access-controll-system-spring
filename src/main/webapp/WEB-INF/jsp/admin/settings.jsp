<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:panelLayout title="যোগ্যতার সেটিংস | FACS অ্যাডমিন SEU">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"        icon="users"     label="ব্যবহারকারী"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt"   label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles"     icon="truck"     label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/stations"     icon="terminal"  label="স্টেশন"/>
        <my:sidebarNavItem href="/admin/settings"     icon="settings"  label="সেটিংস" active="true"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header>
                <h1 class="text-[34px] sm:text-[38px] font-bold text-brand tracking-tight leading-snug">
                    যোগ্যতার সেটিংস
                </h1>
                <p class="mt-2 text-sm text-gray-500">
                    মাসিক ফুয়েল কোটা ও পরবর্তী রিফুয়েলিং পর্যন্ত অপেক্ষমান সময় নির্ধারণ করুন।
                </p>
            </header>

            <c:if test="${not empty settingsFlash}">
                <div role="status"
                     class="rounded-md px-4 py-3 text-sm font-medium
                            ${settingsFlashVariant == 'error'
                              ? 'bg-red-50 text-red-700 border border-red-200'
                              : 'bg-emerald-50 text-emerald-700 border border-emerald-200'}">
                    <c:out value="${settingsFlash}"/>
                </div>
            </c:if>

            <my:formCard
                title="যোগ্যতার নিয়ম"
                subtitle="সর্বশেষ আপডেট: ${currentUpdatedAtDisplay}"
                sectionTitle="সিস্টেমব্যাপী নিয়ম"
                action="/admin/settings"
                cancelHref="/admin/dashboard"
                submitLabel="সেটিংস সংরক্ষণ করুন">

                <my:input id="monthlyQuotaLiters" name="monthlyQuotaLiters" type="number"
                          label="মাসিক কোটা (লিটার)" required="true"
                          leadingIcon="fuelPump"
                          placeholder="যেমন ৬০"
                          autocomplete="off"
                          value="${settings.monthlyQuotaLiters}"
                          error="${errors['monthlyQuotaLiters']}"/>

                <p class="-mt-3 text-xs text-gray-500">
                    প্রতিটি যানবাহন প্রতি ক্যালেন্ডার মাসে এই পরিমাণের বেশি ফুয়েল পাবে না।
                </p>

                <my:input id="cooldownHours" name="cooldownHours" type="number"
                          label="দুই রিফুয়েলিংয়ের মাঝে অপেক্ষমান সময় (ঘণ্টা)" required="true"
                          leadingIcon="clock"
                          placeholder="যেমন ২৪"
                          autocomplete="off"
                          value="${settings.cooldownHours}"
                          error="${errors['cooldownHours']}"/>

                <p class="-mt-3 text-xs text-gray-500">
                    একটি সফল রিফুয়েলিংয়ের পর কত ঘণ্টা পেরোলে যানবাহনটি আবার যোগ্য হবে। ০ মানে কোনো অপেক্ষা নেই।
                </p>

            </my:formCard>

        </section>
    </jsp:body>

</my:panelLayout>
