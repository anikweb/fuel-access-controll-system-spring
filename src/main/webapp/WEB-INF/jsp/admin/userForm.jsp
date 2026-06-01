<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>

<c:set var="isEdit" value="${formMode eq 'edit'}"/>
<c:set var="pageTitle" value="${isEdit ? 'ব্যবহারকারী সম্পাদনা | FACS অ্যাডমিন' : 'নতুন ব্যবহারকারী | FACS অ্যাডমিন'}"/>
<c:set var="cardTitle" value="${isEdit ? 'ব্যবহারকারী সম্পাদনা' : 'নতুন ব্যবহারকারী তৈরি করুন'}"/>
<c:set var="cardSubtitle" value="${isEdit ? 'প্রয়োজনীয় পরিবর্তন করে সংরক্ষণ করুন।' : 'সিস্টেমে অ্যাক্সেস প্রদানের জন্য প্রয়োজনীয় তথ্য পূরণ করুন।'}"/>
<c:set var="submitLabel" value="${isEdit ? 'আপডেট করুন' : 'সংরক্ষণ করুন'}"/>

<c:choose>
    <c:when test="${isEdit}">
        <c:set var="formAction" value="/admin/users/${panelUserId}/update"/>
    </c:when>
    <c:otherwise>
        <c:set var="formAction" value="/admin/users"/>
    </c:otherwise>
</c:choose>

<my:panelLayout title="${pageTitle}">

    <jsp:attribute name="sidebar">
        <my:sidebarNavItem href="/admin/dashboard"    icon="dashboard" label="ড্যাশবোর্ড"/>
        <my:sidebarNavItem href="/admin/users"        icon="users"     label="ব্যবহারকারী" active="true"/>
        <my:sidebarNavItem href="/admin/transactions" icon="receipt"   label="লেনদেন"/>
        <my:sidebarNavItem href="/admin/vehicles"     icon="truck"     label="যানবাহন"/>
        <my:sidebarNavItem href="/admin/stations"     icon="terminal"  label="স্টেশন"/>
    </jsp:attribute>

    <jsp:attribute name="sidebarFooter">
        <my:sidebarNavItem href="/change-password" icon="gear" label="পাসওয়ার্ড পরিবর্তন"/>
    </jsp:attribute>

    <jsp:body>
        <section class="flex flex-col gap-6 w-full">

            <header>
                <h1 class="text-[34px] sm:text-[38px] font-bold text-brand tracking-tight leading-snug">${cardTitle}</h1>
                <p class="mt-2 text-sm text-gray-500">${cardSubtitle}</p>
            </header>

            <form action="<c:url value='${formAction}'/>" method="post" enctype="multipart/form-data" novalidate
                  class="bg-white border border-gray-200 rounded-xl overflow-hidden">
                <c:if test="${not empty _csrf}">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                </c:if>

                <div class="p-6 sm:p-8 flex flex-col gap-6">

                    <div class="flex flex-col items-center" data-avatar-root>
                        <span class="relative block w-32 h-32 rounded-2xl overflow-hidden bg-gray-100 border-2 border-dashed border-gray-300">
                            <img src="${existingPhotoUrl}"
                                 alt=""
                                 class="w-full h-full object-cover ${empty existingPhotoUrl ? 'hidden' : ''}"
                                 data-avatar-img/>
                            <span class="absolute inset-0 flex items-center justify-center text-gray-400 [&>svg]:w-10 [&>svg]:h-10 ${not empty existingPhotoUrl ? 'hidden' : ''}"
                                  data-avatar-fallback>
                                <my:icon name="camera"/>
                            </span>
                            <label for="photo"
                                   class="absolute bottom-2 right-2 inline-flex items-center justify-center w-8 h-8 rounded-full bg-brand text-white cursor-pointer ring-2 ring-white transition hover:bg-brand-700 [&>svg]:w-4 [&>svg]:h-4">
                                <span><my:icon name="camera"/></span>
                            </label>
                        </span>
                        <input id="photo" name="photo" type="file" accept="image/*"
                               class="sr-only" data-avatar-input/>
                        <p class="mt-3 text-xs text-gray-500">ব্যবহারকারীর ছবি আপলোড করুন</p>
                        <c:if test="${not empty errors['photo']}">
                            <p class="mt-1 text-xs text-red-600">${errors['photo']}</p>
                        </c:if>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-5">
                        <my:input id="name" name="name" type="text"
                                  label="নাম" required="true"
                                  placeholder="পূর্ণ নাম লিখুন"
                                  autocomplete="off"
                                  value="${panelUser.name}"
                                  error="${errors['name']}"/>

                        <my:input id="mobile" name="mobile" type="tel"
                                  label="মোবাইল নম্বর" required="true"
                                  placeholder="০১৭XXXXXXXX"
                                  leadingIcon="phone"
                                  autocomplete="tel"
                                  value="${panelUser.mobile}"
                                  error="${errors['mobile']}"/>

                        <div class="flex flex-col" data-station-field>
                            <label for="stationId" class="mb-1.5 text-[13px] font-medium text-gray-700">
                                স্টেশন নির্বাচন করুন
                                <span class="text-red-600" data-station-required-mark>*</span>
                            </label>
                            <div class="relative flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15 ${not empty errors['stationId'] ? 'border-red-300 bg-red-50 focus-within:border-red-400 focus-within:ring-red-200' : ''}">
                                <select id="stationId" name="stationId"
                                        class="flex-1 w-full appearance-none bg-transparent border-0 px-3.5 pr-10 py-3 text-sm text-gray-900 focus:outline-none disabled:cursor-not-allowed disabled:text-gray-400">
                                    <option value="" ${empty panelUser.stationId ? 'selected' : ''}>স্টেশন বেছে নিন</option>
                                    <c:forEach items="${stations}" var="s">
                                        <option value="${s.id}" ${panelUser.stationId eq s.id ? 'selected' : ''}>
                                            <c:out value="${s.name}"/> (<c:out value="${s.code}"/>)
                                        </option>
                                    </c:forEach>
                                </select>
                                <span class="absolute right-3 pointer-events-none text-gray-400">
                                    <my:icon name="chevronDown"/>
                                </span>
                            </div>
                            <c:if test="${not empty errors['stationId']}">
                                <p class="mt-1 text-xs text-red-600">${errors['stationId']}</p>
                            </c:if>
                        </div>

                        <div class="flex flex-col">
                            <label for="role" class="mb-1.5 text-[13px] font-medium text-gray-700">
                                ভূমিকা <span class="text-red-600">*</span>
                            </label>
                            <div class="relative flex items-center rounded-lg border border-gray-200 bg-gray-50 transition focus-within:border-brand focus-within:bg-white focus-within:ring-2 focus-within:ring-brand/15 ${not empty errors['role'] ? 'border-red-300 bg-red-50 focus-within:border-red-400 focus-within:ring-red-200' : ''}">
                                <select id="role" name="role" required data-role-select
                                        class="flex-1 w-full appearance-none bg-transparent border-0 px-3.5 pr-10 py-3 text-sm text-gray-900 focus:outline-none">
                                    <option value="OPERATOR" ${panelUser.role eq 'OPERATOR' ? 'selected' : ''}>অপারেটর</option>
                                    <option value="ADMIN" ${panelUser.role eq 'ADMIN' ? 'selected' : ''}>সিস্টেম অ্যাডমিন</option>
                                </select>
                                <span class="absolute right-3 pointer-events-none text-gray-400">
                                    <my:icon name="chevronDown"/>
                                </span>
                            </div>
                            <c:if test="${not empty errors['role']}">
                                <p class="mt-1 text-xs text-red-600">${errors['role']}</p>
                            </c:if>
                        </div>

                        <my:input id="password" name="password" type="password"
                                  label="${isEdit ? 'নতুন পাসওয়ার্ড (ঐচ্ছিক)' : 'পাসওয়ার্ড'}"
                                  required="${!isEdit}"
                                  placeholder="••••••••"
                                  leadingIcon="lock"
                                  passwordToggle="true"
                                  autocomplete="new-password"
                                  error="${errors['password']}"/>

                        <my:input id="passwordConfirm" name="passwordConfirm" type="password"
                                  label="পাসওয়ার্ড নিশ্চিত করুন"
                                  required="${!isEdit}"
                                  placeholder="••••••••"
                                  leadingIcon="lockReset"
                                  passwordToggle="true"
                                  autocomplete="new-password"
                                  error="${errors['passwordConfirm']}"/>
                    </div>

                </div>

                <footer class="flex justify-end gap-3 px-6 py-4 border-t border-gray-100 bg-white">
                    <div class="w-40">
                        <my:button label="বাতিল করুন" href="/admin/users" variant="secondary"/>
                    </div>
                    <div class="w-44">
                        <my:button label="${submitLabel}" type="submit"/>
                    </div>
                </footer>
            </form>

        </section>

        <script src="<c:url value='/js/auth.js'/>" defer></script>
        <script src="<c:url value='/js/uploads.js'/>" defer></script>
        <script>
            (function () {
                var roleSel = document.querySelector('[data-role-select]');
                var stationSel = document.getElementById('stationId');
                var requiredMark = document.querySelector('[data-station-required-mark]');
                if (!roleSel || !stationSel) return;

                function sync() {
                    var isOperator = roleSel.value === 'OPERATOR';
                    stationSel.disabled = !isOperator;
                    if (requiredMark) requiredMark.style.display = isOperator ? '' : 'none';
                    if (!isOperator) stationSel.value = '';
                }

                roleSel.addEventListener('change', sync);
                sync();
            })();
        </script>
    </jsp:body>

</my:panelLayout>
