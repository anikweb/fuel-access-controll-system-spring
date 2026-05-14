<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="যানবাহনের তথ্য | FACS">
<section id="signup" class="w-full max-w-3xl mx-auto">

    <my:stepper items="${stepLabels}" currentIndex="${currentIndex}"/>

    <c:if test="${not empty uploadError}">
        <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">${uploadError}</div>
    </c:if>

    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-6 sm:p-8">

        <form action="<c:url value='/signup/vehicle'/>" method="post" enctype="multipart/form-data" novalidate
              class="flex flex-col gap-6">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <header>
                <h1 class="text-[20px] sm:text-[22px] font-bold text-gray-900 tracking-tight">যানবাহনের তথ্য</h1>
                <p class="mt-1 text-sm text-gray-500">
                    সঠিক অডিট এবং অ্যাক্সেস কন্ট্রোলের জন্য আপনার যানবাহনের সঠিক বিবরণ প্রদান করুন।
                </p>
            </header>

            <hr class="border-0 border-t border-gray-200"/>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <my:input id="brand" name="brand" type="text" label="ব্র্যান্ড"
                          placeholder="যেমন: টয়োটা" autocomplete="off"
                          value="${draft.vehicle.brand}" error="${errors['brand']}"/>
                <my:input id="model" name="model" type="text" label="মডেল"
                          placeholder="মডেল নম্বর লিখুন" autocomplete="off"
                          value="${draft.vehicle.model}" error="${errors['model']}"/>
            </div>

            <my:input id="vehicleType" name="vehicleType" type="text" label="যানবাহনের ধরন"
                      placeholder="যেমন: কার, ট্রাক, বাইক" autocomplete="off"
                      value="${draft.vehicle.vehicleType}" error="${errors['vehicleType']}"/>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <my:input id="chassisNumber" name="chassisNumber" type="text" label="চ্যাসিস নম্বর"
                          placeholder="১৭ সংখ্যার কোড" autocomplete="off"
                          value="${draft.vehicle.chassisNumber}" error="${errors['chassisNumber']}"/>
                <my:input id="engineNumber" name="engineNumber" type="text" label="ইঞ্জিন নম্বর"
                          placeholder="ইঞ্জিন শনাক্তকরণ নম্বর" autocomplete="off"
                          value="${draft.vehicle.engineNumber}" error="${errors['engineNumber']}"/>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <my:input id="color" name="color" type="text" label="রং"
                          placeholder="যানবাহনের রং" autocomplete="off"
                          value="${draft.vehicle.color}" error="${errors['color']}"/>
                <my:input id="manufactureYear" name="manufactureYear" type="text" label="প্রস্তুতকাল"
                          placeholder="২০২৫" autocomplete="off"
                          value="${draft.vehicle.manufactureYear}" error="${errors['manufactureYear']}"/>
            </div>

            <div>
                <p class="mb-2 text-[13px] font-medium text-gray-700">রেজিস্ট্রেশন প্লেট এর ছবি আপলোড করুন</p>
                <my:uploadZone id="plateImage" name="plateImage" label="ফাইল নির্বাচন করুন"
                               helper="PDF, JPG (Max 5MB)" accept="image/*,application/pdf"/>
            </div>

            <my:input id="plateNumber" name="plateNumber" type="text" label="প্লেট নম্বর"
                      placeholder="স্বয়ংক্রিয় ভাবে শনাক্ত হবে" trailingIcon="car"
                      autocomplete="off"
                      value="${draft.vehicle.plateNumber}" error="${errors['plateNumber']}"/>

            <hr class="border-0 border-t border-gray-200"/>

            <my:stepNav prevHref="/signup/personal" primaryLabel="পরবর্তী"/>
        </form>
    </article>

    <script src="<c:url value='/js/uploads.js'/>" defer></script>
</section>
</my:layout>
