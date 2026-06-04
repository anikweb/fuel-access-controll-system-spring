<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="my" tagdir="/WEB-INF/tags" %>
<%@ attribute name="id" required="true" %>
<%@ attribute name="name" required="true" %>
<%@ attribute name="label" required="true" %>
<%@ attribute name="helper" required="false" %>
<%@ attribute name="accept" required="false" %>

<div class="flex flex-col gap-2">
    <label for="${id}"
           class="relative group flex flex-col items-center justify-center gap-2 rounded-lg border-2 border-dashed border-gray-300 bg-gray-50 px-6 py-10 min-h-[150px] cursor-pointer transition hover:border-gray-400 hover:bg-gray-100 overflow-hidden"
           data-upload-zone>

        <div class="flex flex-col items-center gap-2" data-upload-placeholder>
            <span class="text-gray-500 [&>svg]:w-6 [&>svg]:h-6"><my:icon name="upload"/></span>
            <span class="text-sm text-gray-600 text-center" data-upload-label>${label}</span>
            <c:if test="${not empty helper}">
                <span class="text-xs text-gray-400 text-center">${helper}</span>
            </c:if>
        </div>

        <img class="hidden absolute inset-0 w-full h-full object-contain p-2"
             alt="Preview" data-upload-preview/>

        <span class="hidden absolute inset-0 items-center justify-center bg-black/45 text-white text-xs font-medium opacity-0 group-hover:opacity-100 transition"
              data-upload-overlay>পরিবর্তন করুন</span>

        <input id="${id}" name="${name}" type="file" accept="${accept}"
               class="sr-only" data-upload-input/>
    </label>

    <button type="button"
            class="hidden self-end items-center gap-2 rounded-full bg-brand/10 text-brand px-4 py-2 text-xs font-semibold hover:bg-brand/15 active:scale-[0.97] transition focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand/30 [&>svg]:w-3.5 [&>svg]:h-3.5"
            data-upload-retake data-for="${id}">
        <my:icon name="refresh"/>
        <span>পুনরায় ছবি তুলুন</span>
    </button>
</div>
