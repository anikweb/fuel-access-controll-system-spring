<%@ page contentType="text/html;charset=UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<my:layout title="অ্যাকাউন্ট তৈরি করুন | FACS">
<section id="signup" class="w-full max-w-3xl mx-auto">

    <my:stepper items="${stepLabels}" currentIndex="${currentIndex}"/>

    <c:if test="${not empty uploadError}">
        <div class="mb-4 rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700" role="alert">${uploadError}</div>
    </c:if>

    <article class="bg-white border border-gray-200 rounded-xl shadow-[0_1px_2px_rgba(16,24,40,0.04),0_8px_24px_rgba(16,24,40,0.06)] p-6 sm:p-8">

        <form action="<c:url value='/signup/personal'/>" method="post" enctype="multipart/form-data" novalidate
              class="flex flex-col gap-6">
            <c:if test="${not empty _csrf}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            </c:if>

            <header class="flex flex-col items-center text-center">
                <my:avatarUpload id="photo" name="photo" initial="${draft.personal.photoRef}"/>
                <h1 class="mt-4 text-[20px] sm:text-[22px] font-bold text-gray-900 tracking-tight">
                    ড্রাইভিং লাইসেন্স ও ব্যক্তিগত তথ্য
                </h1>
                <p class="mt-1 text-sm text-gray-500">
                    সঠিক ভাবে রেজিস্ট্রেশন সম্পন্ন করার জন্য পরিষ্কার ছবি আপলোড করুন
                </p>
            </header>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <my:uploadZone id="licenseFront" name="licenseFront" label="ড্রাইভিং লাইসেন্স সামনের পাতা" accept="image/*"/>
                <my:uploadZone id="licenseBack" name="licenseBack" label="ড্রাইভিং লাইসেন্স পিছনের পাতা" accept="image/*"/>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <my:input id="name" name="name" type="text" label="নাম"
                          placeholder="লাইসেন্স থেকে শনাক্ত হবে"
                          autocomplete="name" value="${draft.personal.name}"
                          error="${errors['name']}"/>
                <my:input id="licenseNumber" name="licenseNumber" type="text" label="ড্রাইভিং লাইসেন্স নম্বর"
                          autocomplete="off" value="${draft.personal.licenseNumber}"
                          error="${errors['licenseNumber']}"/>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <my:input id="district" name="district" type="text" label="জেলা"
                          placeholder="যেমন: ঢাকা" autocomplete="off"
                          value="${draft.personal.district}" error="${errors['district']}"/>
                <my:input id="subDistrict" name="subDistrict" type="text" label="উপজেলা"
                          placeholder="যেমন: ধানমন্ডি" autocomplete="off"
                          value="${draft.personal.subDistrict}" error="${errors['subDistrict']}"/>
            </div>

            <my:textarea id="address" name="address" label="বিস্তারিত ঠিকানা"
                         value="${draft.personal.address}" rows="3"/>

            <my:input id="nidNumber" name="nidNumber" type="text" label="NID নম্বর (ঐচ্ছিক)"
                      autocomplete="off" value="${draft.personal.nidNumber}"
                      error="${errors['nidNumber']}"/>

            <div class="flex justify-end pt-2">
                <div class="w-40">
                    <my:button label="পরবর্তী" type="submit" variant="primary" trailingIcon="arrow"/>
                </div>
            </div>
        </form>
    </article>

    <script src="<c:url value='/js/uploads.js'/>" defer></script>
</section>
</my:layout>
